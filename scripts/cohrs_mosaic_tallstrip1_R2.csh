#!/bin/csh

#+
#  Name:
#     cohrs_mosaic_tallstrips1_R2.csh

#  Purpose:
#     Forms a mosaic of a single COHRS tile for Release 2.

#  Language:
#     Unix C-shell

#  Invocation:
#     cohrs_mosaic_tallstrips1.csh <tile>.

#  Description:
#     This script runs a single group of COHRS position-position-
#     velocity (PPV) cubes through the PICARD recipe MOSAIC_JCMT_IMAGES
#     to form a mosaic.  Along the way it also ensures that the mosaic is
#     aligned in the LSRK Standard of Rest.

#  Arguments:
#     tile -- the name of the mosaic, e.g. inner1, middle2.
#     llong -- the lower limit in longitude, defaulting to no constraint
#     ulong -- the upper limit in longitude, defaulting to no constraint

#  Prior Requirments:
#     - The COHRS environment variables COHRS_FILELISTS, COHRS_REDUCED,
#     COHRS_SCRIPTS, and COHRS_TILED must be defined and point to the
#     appropriate locations. The script postprocess.csh will do this.
#     - $COHRS_FILELISTS should contain the lists of PPV cubes to tile
#     in each mosaic and have names ending "mosaic_R2n.txt".
#     - $COHRS_REDUCED should contain (or have softlink to) the PPV cubes
#     to be mosaicked.
#     - $COHRS_SCRIPTS should contain mosaic.ini, which sets the
#     recipe parameters for the PICARD recipe MOSAIC_JCMT_IMAGES.
#     - $COHRS_TILED is the destination directory for the resultant mosaic.

#   Notes:
#     - The velocity range extracted is -200 to +300 km/s.
#     - The latitude range extracted is -0.501 to +0.501 degrees.
#     - The pre-2018 data were taken in upper side band.  The later
#     observations under CHIMPS2 auspices were observed in the lower
#     side band.  The latter are flipped along the spectral axis before
#     mosaic formation.

#  Output:
#     All output is created in $COHRS_TILED.
#     - A mosaic for $COHRS_FILELISTS/<tile>mosaic_Rn.txt given the same
#     name except the file extension changes from "txt" to "sdf".  For example,
#     1mosaic_R2n.txt would generate a PPV mosaic called 1mosaic_R2n.sdf.
#     - A PICARD .picard<XXXX> log for each mosaic.

#  Authors:
#     MJC: Malcolm J. Currie (RAL)
#     {enter_new_authors_here}

#  History:
#     2022 September 9  (MJC):
#        Original version based upon cohrs_mosaic_strip1_R2.csh.
#     {enter_further_changes_here}

#-

cd $COHRS_TILED
setenv ORAC_DATA_OUT $COHRS_TILED
kappa >>/dev/null

#  Check that there is an argument present.
set args = ($argv[1-])
if ( $#args == 0 ) then
   echo "Usage:  cohrs_mosaic_strip1_R2.csh <tilename>"
   exit
else if ( $#args >= 1 ) then

#  Process each of the arguments to the script.
   set tile = $args[1]

   set llon = ""
   set ulon = ""
   if ( $#args == 3 ) then
      set llon = $args[2]
      set ulon = $args[3]
   endif
endif

\rm -f alignedlist.txt
\rm -f abridgedlist.txt
set mosaiclist = "$COHRS_FILELISTS/${1}mosaic_R2n.txt"
set suffix = "_trim"
set fsuffix = "_flip"
set abridged = ()

# The list of PPV NDFs to combine into which mosaics are given in the
# filelists like 40mosaic_R2n.txt and 15mosaic_R2n.txt.
foreach f ( `cat $mosaiclist` )
   echo $f
   set ndf = $f:r

# Obtain the longitude bounds.
   ndftrace $COHRS_REDUCED/$ndf >> /dev/null
   set flbnd = `parget flbnd ndftrace`
   set fubnd = `parget fubnd ndftrace`

# Set the lower and upper longitude bands so as to not widen
# the extent of each tessera.  So for one not at the longitudinal
# ends, the bounds are unchanged.  The trimming occurs at the ends.
   set lonvalid = 1
   set lonrange = ""
   if ( $llon != "" ) then
      set flonlb = `calc exp="180.0*$flbnd[1]/pi" prec=_double`
      set flonub = `calc exp="180.0*$fubnd[1]/pi" prec=_double`

      set fulllon = `calc exp="'qif(($flonlb>$llon)&&($flonub<$ulon),1,0)'" prec=_double`
      if ( $fulllon == 0 ) then
         set lonvalid = `calc calc exp="'qif(($flonlb>$ulon)||($flonub<$llon),0,1)'" prec=_double`
         if ( $lonvalid == 1 ) then
            set lonlb = `calc exp="max($llon,$flonlb)" prec=_double`
            set lonub = `calc exp="min($ulon,$flonub)" prec=_double`

            set lonrange = "${lonlb}d:${lonub}d"
         endif
      endif
   endif

# Set the lower and upper latitude bands so as to not widen
# the extent of each tessera.  So for one not at the latitudinal
# ends, the bounds are unchanged.  The trimming occurs at the north
# and south.
   set latrange = ""
   set latvalid = 1
   set flatlb = `calc exp="180.0*($flbnd[2])/pi" prec=_double`
   set flatub = `calc exp="180.0*($fubnd[2])/pi" prec=_double`
   set llat = -0.55
   set ulat = 0.55

   set fulllat = `calc exp="'qif((($flatlb)>($llat))&&($flatub<$ulat),1,0)'" prec=_double`
   if ( $fulllat == 0 ) then
      set latvalid = `calc exp="'qif((($flatlb)>$ulat)||($flatub<($llat)),0,1)'" prec=_double`
      if ( $latvalid == 1 ) then
         set latlb = `calc exp="max($llat,$flatlb)" prec=_double`
         set latub = `calc exp="min($ulat,$flatub)" prec=_double`

         set latrange = "${latlb}d:${latub}d"
      endif
   endif

   if ( $lonvalid == 1 && $latvalid == 1 ) then

# Obtain the side band.
      set sideband = `fitsval $COHRS_REDUCED/$ndf OBS_SB`

# Reverse the spectral axis for the lower side band.
      if ( "$sideband" == "LSB" ) then
         set flipped = ${ndf}${fsuffix}
         flip in=$COHRS_REDUCED/$ndf out=$flipped dim=3

# To avoid confusion over the PPV NDFs' origin times, apply trimming and
# alter the alignment Standard of Rest on copied NDFs.  Take care to
# avoid appending suffix used by the PICARD recipe, such as _al.
         ndfcopy in=$flipped"($lonrange,$latrange,-200.0:300.0)" out=$COHRS_TILED/\*"|$fsuffix|$suffix|" trim trimwcs
         rm ${flipped}.sdf
      else
         ndfcopy in=$COHRS_REDUCED/$ndf"($lonrange,$latrange,-200.0:300.0)" out=$COHRS_TILED/\*$suffix trim trimwcs
      endif

      set outndf = `echo "$ndf$suffix"`
      set abridged = ( $abridged $outndf )
   endif
end

# Create an abridged list of files to process.
set abrfile = "abridgedlist.txt"
touch $abrfile
set i = 1
while ( $i <= $#abridged )
   echo $abridged[$i]".sdf" >> abridgedlist.txt
   @ i++
end

# Although all the COHRS PPV cubes are in LSRK standard of rest, WCSMOSAIC
# by default uses Heliocentric Standard of Rest for alignment.  [This
# offset in line velocity was reported by Yangsu 2014 November 11 and
# the cause identified by MJC.]  This SoR gives rise to progressively
# shifted line velocities the further from the spatial centre of the
# first contributing cube a spectrum is located.
wcsattrib ndf=^abridgedlist.txt mode=set name=AlignStdOfRest newval=LSRK

# Now form the mosaics also evaluating the EXP_TIME and EFF_TIME arrays.
picard --recpars $COHRS_SCRIPTS/mosaic.ini -debug -log f MOSAIC_JCMT_IMAGES `cat abridgedlist.txt`

# Find the name of the mosaic just created.
set mosname = `ls -1t $COHRS_TILED/*_mos.sdf | head -n 1`

# Form output PPV cube name, removing COHRS_FILELISTS's path.
set outname = `echo $mosaiclist:t | sed -e s/.txt/.sdf/`

# Rename the PPV mosaic to the name actually wanted.
mv $mosname $outname

# Tidy up.
#rm `cat abridgedlist.txt` abridgedlist.txt
