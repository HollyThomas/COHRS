#!/bin/csh

#+
#  Name:
#     cohrs_mosaic_strips_R2.csh

#  Purpose:
#     Forms mosaics of COHRS tiles for Release 2

#  Language:
#     Unix C-shell

#  Invocation:
#     cohrs_mosaic_strips.csh

#  Description:
#     This script runs a series of groups of COHRS position-position-
#     velocity (PPV) cubes through the PICARD recipe MOSAIC_JCMT_IMAGES
#     to form a series of mosaics.  Along the way it also ensures that
#     the mosaics are aligned in the LSRK Standard of Rest.

#  Prior Requirments:
#     - The COHRS environment variables COHRS_FILELISTS, COHRS_REDUCED,
#     COHRS_SCRIPTS, and COHRS_TILED must be defined and point to the
#     appropriate locations.  The script postprocess.csh will do this.
#     - $COHRS_FILELISTS should contain the lists of PPV cubes to tile
#     in each mosaic and have names ending "mosaic_R2.txt".
#     - $COHRS_REDUCED should contain (or have softlink to) the PPV cubes
#     to be mosaicked.
#     - $COHRS_SCRIPTS should contain mosaic.ini, which sets the
#     recipe parameters for the PICARD recipe MOSAIC_JCMT_IMAGES.
#     - $COHRS_TILED is the destination directory for the resultant mosaic.

#   Notes:
#     - The velocity range extracted is -200 to +300 km/s.
#     - The latitude range extracted is -0.51 to +0.51 degrees.
#     - The pre-2018 data were taken in upper side band.  The later
#     observations under CHIMPS2 auspices were observed in the lower
#     side band.  The latter are flipped along the spectral axis before
#     mosaic formation.

#  Output:
#     All output is created in $COHRS_TILED.
#     - A mosaic for each $COHRS_FILELISTS/*mosaic_R2n.txt given the same
#     name except the file extension changes from "txt" to "sdf".  For example,
#     15mosaic_R2n.txt would generate a PPV mosaic called 15mosaic_R2n.sdf.
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
#        Flip the spectral axis for USB side band.
#        Add explanation of roles of $COHRS_REDUCED and $COHRS_SCRIPTS
#        environmental variables in Prior Requirements.
#     2020 May 13 (MJC):
#        Adapted from the original cohrs_mosaic_strips.csh, having a
#        wider velocity range and restricted latitude range for Release 2.
#     {enter_further_changes_here}

#-

cd $COHRS_TILED
setenv ORAC_DATA_OUT $COHRS_TILED
kappa >>/dev/null

\rm -f alignedlist.txt

# The list of PPV NDFs to combine into which mosaics are given in the
# filelists like inner3mosaic.txt, middle2mosaic.txt, and outer1mosaic.txt.
foreach f ( `ls -1 $COHRS_FILELISTS/*mosaic_R2n.txt` )
   echo $f

   set suffix = "_trim"
   foreach file ( `cat $f` )
      set ndf = $file:r
      echo "   $ndf"

# Obtain the side band.
      set sideband = `fitsval $COHRS_REDUCED/$ndf OBS_SB`

# Reverse the spectral axis for the lower side band.
      if ( "$sideband" == "LSB" ) then
         flip in=$COHRS_REDUCED/$ndf out=\*_flip dim=3

# To avoid confusion over the PPV NDFs' origin times, apply trimming and
# alter the alignment Standard of Rest on copied NDFs.  Take care to
# avoid appending suffix used by the PICARD recipe, such as _al.
# Loop, rather than use the indirection file, because we want to restrict
# the velocity range.
         ndfcopy in=$COHRS_REDUCED/${ndf}_flip\(,-0.51:0.51,-200.0:300.0\) out=$COHRS_TILED/"*|_flip|$suffix|"
         rm $COHRS_REDUCED//${ndf}_flip.sdf
      else
         ndfcopy in=$COHRS_REDUCED/$ndf"(,-0.51:0.51,-200.0:300.0)" out=$COHRS_TILED/\*$suffix
      endif
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
