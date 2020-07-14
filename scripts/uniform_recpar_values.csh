#!/bin/csh
#+
#  Name:
#     uniform_recpar_values.csh

#  Purpose:
#     Makes historic recipe-parameter files more uniform.

#  Language:
#     Unix C-shell

#  Invocation:
#     uniform_recpar_values.csh

#  Description:
#     This script runs a series of sed commands to make the COHRS
#     recipe-parameter files more uniform, editing them in situ.  In
#     particular it sets a common BASELINE_ORDER of 4 (uncommenting,
#     where necessary), disables REF_EMISSION_COMBINE_REFPOS, and
#     uses the current comment headers that divides the parameters
#     into related blocks.

#  Prior Requirments:
#     -  It must be run in the directory of the recipe-parameter files.

#  Authors:
#     MJC: Malcolm J. Currie (RAL)
#     {enter_new_authors_here}

#  History:
#     2020 February 26 (MJC):
#        Original version.
#     2020 February 28 (MJC):
#        Added BASELINE_ORDER uniformity.
#     {enter_further_changes_here}

#-

foreach f ( recpars-COHRS_0*.ini )
   sed -i 's/REF_EMISSION_COMBINE_REFPOS = 1/REF_EMISSION_COMBINE_REFPOS = 0/' $f

# Uniform baseline subtraction polynomial order.  Some of these were
# commented out (defaulting to first order).
   sed -i 's/BASELINE_ORDER = 1/BASELINE_ORDER = 4/' $f
   sed -i 's/BASELINE_ORDER = 3/BASELINE_ORDER = 4/' $f
   sed -i 's/BASELINE_ORDER = 5/BASELINE_ORDER = 4/' $f
   sed -i 's/#BASELINE_ORDER = 1/BASELINE_ORDER = 4/' $f
   sed -i 's/#BASELINE_ORDER = 2/BASELINE_ORDER = 4/' $f
   sed -i 's/#BASELINE_ORDER = 3/BASELINE_ORDER = 4/' $f
   sed -i 's/#BASELINE_ORDER = 4/BASELINE_ORDER = 4/' $f
   sed -i 's/#BASELINE_ORDER = 5/BASELINE_ORDER = 4/' $f
   sed -i 's/#BASELINE_ORDER = spline/BASELINE_ORDER = 4/' $f

# Insert the spaces for a consistent style.
   sed -i 's/HIGHFREQ_RINGING=0/HIGHFREQ_RINGING = 0/' $f

# Add a missing HIGHFREQ_INTERFERENCE_THRESH_CLIP.
   grep -qxF 'HIGHFREQ_INTERFERENCE_THRESH_CLIP = 4.0' $f || \
       sed -i 's/HIGHFREQ_RINGING = 0/HIGHFREQ_RINGING = 0\nHIGHFREQ_INTERFERENCE_THRESH_CLIP = 4.0/' $f

# Standardize to the current set of headings in the comments.
   sed -i 's/Bad-baseline filtering and flatfielding receptors/Bad-baseline filtering/' $f
   grep -qxF '# Flatfield receptors' $f || \
       sed -i 's/LOWFREQ_INTERFERENCE = 1/LOWFREQ_INTERFERENCE = 1\n#\n# Flatfield receptors\n#/' $f
   grep -qxF '# Bad-baseline filtering' $f || \
       sed -i 's/SPREAD_FWHM_OR_ZERO = 6/SPREAD_FWHM_OR_ZERO = 6\n#\n# Bad-baseline filtering\n#/' $f
end
