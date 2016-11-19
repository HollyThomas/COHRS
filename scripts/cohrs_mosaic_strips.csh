#!/bin/csh

#+
#  Name:
#     cohrs_mosaic_strips.csh

#  Purpose:
#     Forms mosaics of COHRS tiles

#  Language:
#     Unix C-shell

#  Invocation:
#     cohrs_mosaic_strips.csh

#  Description:
#     This script runs a series of groups of COHRS position-position-
#     velocity (PPV) cubes through the PICARD recipe MOSAIC_JCMT_IMAGES
#     to form a series of mosaics.  Along the way it also ensures that
#     the mosaics are alligned in the LSRK Standard of Rest.

#  Prior Requirments:
#     - The COHRS environment variables COHRS_FILELISTS, COHRS_SCRIPTS,
#     COHRS_REDUCED, and COHRS_TILED must be defined and point to the
#     appropriate locations.
#     - $COHRS_FILELISTS should contain the lists of PPV cubes to tile
#     in each mosaic and have names ending "mosaic.txt".
#     - $COHRS_TILED should contain the PPV cubes to be mosaicked.

#  Output:
#     All output is created in $COHRS_TILED.
#     - A mosaic for each $COHRS_FILELISTS/*mosaic.txt given the same
#     name except the file extension changes from "txt" to "sdf".  For example,
#     inner1mosaic.txt would generate a PPV mosaic called inner1mosaic.sdf.
#     - A PICARD .picard<XXXX> log for each mosaic.

#  Authors:
#     MJC: Malcolm J. Currie (RAL)
#     {enter_new_authors_here}

#  History:
#     2016 April 25 (MJC):
#        Original version.
#     2016 April 27 (MJC):
#        Form the velocity trimmed tiles.  This saves an extra NDFCOPY
#        per NDF.  Use *mosaic.txt file lists instead of the *trim.txt,
#        which list the untrimmed files.  Then make the trimmed file
#        lists on the fly.
#     {enter_further_changes_here}

#-

cd $COHRS_TILED
setenv ORAC_DATA_OUT $COHRS_TILED
kappa >>/dev/null

\rm -f alignedlist.txt

# The list of PPV NDFs to combine into which mosaics are given in the
# filelists like inner3mosaic.txt, middle2mosaic.txt, and outer1mosaic.txt.
foreach f ( `ls -1 $COHRS_FILELISTS/*mosaic.txt` )
   echo $f

# To avoid confusion over the PPV NDFs' origin times, apply trimming and
# alter the alignment Standard of Rest on copied NDFs.  Take care to
# avoid appending suffix used by the PICARD recipe, such as _al.
# Loop rather than use indirection file because we want to restricti
# the velocity range.
   set suffix = "_trim"
   foreach file ( `cat $f` )
      set ndf = $file:r
      ndfcopy in=$COHRS_REDUCED/$ndf"(,,-64.0:186.0)" out=./\*$suffix
   end

# Create a new list of files to process.
   sed -e s/.sdf/${suffix}.sdf/ $f > alignedlist.txt

# Although all the COHRS PPV cubes are in LSRK standard of rest, WCSMOSAIC
# by default uses Heliocentric Standard of Rest for alignment.  [This
# offset in line velocity was reported by Yangsu 2014 November 11 and
# the cause identified by MJC.]  This SoR gives rise to progressively
# shifted line velocities the further from the spatial centre of the
# first contributing cube a spectrum is located.
   wcsattrib ndf=^alignedlist.txt mode=set name=AlignStdOfRest newval=LSRK

# Now form the mosaics also evaluating the EXP_TIME and EFF_TIME arrays.
   picard --recpars $COHRS_SCRIPTS/mosaic.ini -log f MOSAIC_JCMT_IMAGES `cat alignedlist.txt`

# Find the name of the mosaic just created.
   set mosname = `ls -1t $COHRS_TILED/*_mos.sdf | head -n 1`

# Form output PPV cube name, removing COHRS_FILELISTS's path.
   set outname = `echo $f:t | sed -e s/.txt/.sdf/`

# Rename the PPV mosaic to the name actually wanted.
   mv $mosname $outname

# Tidy up.
   rm `cat alignedlist.txt` alignedlist.txt
end
