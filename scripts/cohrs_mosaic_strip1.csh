#!/bin/csh -v

#+
#  Name:
#     cohrs_mosaic_strips1.csh

#  Purpose:
#     Forms a mosaic of a single COHRS tile

#  Language:
#     Unix C-shell

#  Invocation:
#     cohrs_mosaic_strips1.csh <tile>.

#  Description:
#     This script runs a single group of COHRS position-position-
#     velocity (PPV) cubes through the PICARD recipe MOSAIC_JCMT_IMAGES
#     to form a mosaic.  Along the way it also ensures that the mosaic is
#     aligned in the LSRK Standard of Rest.

#  Arguments:
#     tile -- the name of the mosaic, e.g. inner1, middle2.

#  Prior Requirments:
#     - The COHRS environment variables COHRS_FILELISTS, COHRS_REDUCED,
#     COHRS_SCRIPTS, and COHRS_TILED must be defined and point to the
#     appropriate locations.
#     - $COHRS_FILELISTS should contain the lists of PPV cubes to tile
#     in each mosaic and have names ending "mosaic.txt".
#     - $COHRS_REDUCED should contain (or have softlink to) the PPV cubes
#     to be mosaicked.
#     - $COHRS_SCRIPTS should contain mosaic.ini, which sets the
#     recipe parameters for the PICARD recipe MOSAIC_JCMT_IMAGES.
#     - $COHRS_TILED is the destination directory for the resultant mosaic.

#   Notes:
#     - The velocity range extracted is -64 to 186 km/s.

#  Output:
#     All output is created in $COHRS_TILED.
#     - A mosaic for $COHRS_FILELISTS/<tile>mosaic.txt given the same
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
#     2017 October 4 (MJC)
#        Extend velocity limits from those of Release 1 for Release 2.
#     2018 August 28 (MJC):
#        Add explanation of roles of $COHRS_REDUCED and $COHRS_SCRIPTS
#        environmental variables in Prior Requirements.
#     {enter_further_changes_here}

#-

cd $COHRS_TILED
setenv ORAC_DATA_OUT $COHRS_TILED
kappa >>/dev/null

#  Check that there is an argument present.
set args = ($argv[1-])
if ( $#args == 0 ) then
   echo "Usage:  cohrs_mosaic_strip1.csh <tilename>"
   exit
endif

\rm -f alignedlist.txt
set mosaiclist = "$COHRS_FILELISTS/${1}mosaic.txt"
set suffix = "_trim"

# The list of PPV NDFs to combine into which mosaics are given in the
# filelists like inner3mosaic.txt, middle2mosaic.txt, and outer1mosaic.txt.
foreach f ( `cat $mosaiclist` )
   echo $f

# To avoid confusion over the PPV NDFs' origin times, apply trimming and
# alter the alignment Standard of Rest on copied NDFs.  Take care to
# avoid appending suffix used by the PICARD recipe, such as _al.
   set suffix = "_trim"
   ndfcopy in=$COHRS_REDUCED/$f"(,,-64.0:186.0)" out=$COHRS_TILED/\*$suffix
end

# Create a new list of files to process.
sed -e s/.sdf/${suffix}.sdf/ $mosaiclist > alignedlist.txt

# Although all the COHRS PPV cubes are in LSRK standard of rest, WCSMOSAIC
# by default uses Heliocentric Standard of Rest for alignment.  [This
# offset in line velocity was reported by Yangsu 2014 November 11 and
# the cause identified by MJC.]  This SoR gives rise to progressively
# shifted line velocities the further from the spaitial centre of the
# first contributing cube a spectrum is located.
wcsattrib ndf=^alignedlist.txt mode=set name=AlignStdOfRest newval=LSRK

# Now form the mosaics also evaluating the EXP_TIME and EFF_TIME arrays.
picard --recpars $COHRS_SCRIPTS/mosaic.ini -log f MOSAIC_JCMT_IMAGES `cat alignedlist.txt`

# Find the name of the mosaic just created.
set mosname = `ls -1t $COHRS_TILED/*_mos.sdf | head -n 1`

# Form output PPV cube name, removing COHRS_FILELISTS's path.
set outname = `echo $mosaiclist:t | sed -e s/.txt/.sdf/`

# Rename the PPV mosaic to the name actually wanted.
mv $mosname $outname

# Tidy up.
rm `cat alignedlist.txt` alignedlist.txt
