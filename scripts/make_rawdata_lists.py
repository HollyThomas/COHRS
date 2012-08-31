#! /usr/bin/env python
#+
#  Name:
#     make_rawdata_lists.py

#  Purpose:
#     Create filelists from the list of raw data observations.

#  Language:
#     Python

#  Invocation:
#     make_rawdata_lists.py

#  Description:
#     This reads the master list of raw data, provided by Jess, and
#     creates a text file for each COHRS tile containing
#     the paths and filenames for each raw file used to make
#     the reduced tile.

#  Notes:
#     -  The path names are in /jcmtdata/raw/acsis/spectra/<utdate>/<obs>,
#     where <utdate> is the UT date in YYYYMMDD format and <obs> is the
#     five-digit observation number containing up to four leading
#     zeroes.
#     -  The information used yto create the lists is in README_obs.db.

#  Output:
#     -  A series of text files called gal_<l>_<b>.list, one for each
#     COHRS tile observed as of 2012 August, where L<l>and <b> are the 
#     galactic longitude and latitude respectively.  The longitude is
#     formatted 6.2f, and latitude <sign>5.2f, where <sign> is + or -.
#     Both co-ordinates include leading zeroes and both have "p" 
#     substituted for the decimal point.  An example is
#     gal_017p50_-0p37.list.

#  Copyright:
#     Copyright (C) 2012 Science and Technology Facilities Council.
#     All Rights Reserved.

#  Licence:
#     This program is free software; you can redistribute it and/or
#     modify it under the terms of the GNU General Public License as
#     published by the Free Software Foundation; either Version 2 of
#     the License, or (at your option) any later version.
#
#     This program is distributed in the hope that it will be
#     useful, but WITHOUT ANY WARRANTY; without even the implied
#     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#     PURPOSE. See the GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#     02110-1301, USA.

#  Authors:
#     MJC: Malcolm J. Currie (JAC)
#     {enter_new_authors_here}

#  History:
#     2012 August 31 (MJC):
#        Original version.

#-

def readdata( filename ):
    f = open( filename )
    for line in f:
        if not ( line.startswith( " obsname" ) or line in ['\n', '\r\n'] ):
            yield line


# Here we only need the first three columns: tile name, the utdate and
# number of the observation.  Still read in all the data for
# convenience.
data = [line.strip().split() for line in readdata( "README_obs.db" )]

# Create a text file for the tile.
tile = data[0][0]
filename = tile + '.list'
f = open( filename, 'w' )

for i in range( len( data ) ):
    if data[i][0] != tile:

# Switch to the next tile.
        f.close()

        tile = data[i][0]
        filename = tile + '.list'
        f = open( filename, 'w' )

    utdate = data[i][1]
    obsnum = data[i][2]

# Write the filenames (assuming there are three subfiles).  Some may
# be different, but the database does not provide this information.
    for j in range( 3 ):
        buffer = '/jcmtdata/raw/acsis/spectra/' + data[i][1] + '/' + \
                 obsnum + '/a' + utdate + '_' + obsnum + '_01_' + \
                 str( j + 1 ).zfill( 4 ) + '.sdf\n'
        f.write( buffer )

f.close()
