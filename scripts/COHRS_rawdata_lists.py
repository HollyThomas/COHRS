#! /usr/bin/env python
import os
import math

def readdata( filename ):
    f = open( filename )
    for line in f:
        if not ( line.startswith( " obsname" ) or line in ['\n', '\r\n'] ):
            yield line


def longlat( string ):

# Extract co-ordinates from the compound string.
   cols = string.split( '_' )

   long = "{0:06.2f}".format( float( cols[1] ) )
   lat = "{0:+05.2f}".format( float( cols[2] ) )

   return [long, lat]   


def tilename( long, lat ):
   long = long.replace( ".", "p" )
   lat = lat.replace( ".", "p" )

   return 'gal_' + long + '_' + lat + '.list'


# Here we only need the first three columns: tile name, the utdate, and
# number of the observation.  Still read in all the data for
# convenience.
data = [line.strip().split() for line in readdata( "allobsbyposition.txt" )]

# Create a text file for the tile.  The first column contains the
# co-ordinate and part of the UT date.  Extract the co-ordinates
# and format to two decimals with a leading sign for latitude, and
# substitute p for the decimal point.
tile = data[0][0]
coord = longlat( tile )
long = float ( coord[0] )
lat = float ( coord[1] )
prevlong = long
prevlat = lat

filename = tilename( coord[0], coord[1] )
f = open( filename, 'w' )

for i in range( len( data ) ):
    coord = longlat( data[i][0] )
    long = float ( coord[0] )
    lat = float ( coord[1] )
    if ( long <> prevlong or lat <> prevlat ):

# Switch to the next tile.
        f.close()

        prevlong = long
        prevlat = lat
        tile = data[i][0]
        coord = longlat( tile )
        long = float ( coord[0] )
        lat = float ( coord[1] )

# Do not want offset test positions.
        if ( math.fabs( lat ) > 1.0 ):
            continue

# Want most inner regions to be 0.0 latitude.  There are some with
# negative subtiles that are listed first and hence would name the
# tile incorrectly.
        if lat < 0.0 and lat > -0.01:
            coord[1] = "-0.00"
        filename = tilename( coord[0], coord[1] )
        f = open( filename, 'w' )

    utdate = data[i][1]
    obsnum = data[i][2]

# Write the filenames by search the directory.
    directory = '/jcmtdata/raw/acsis/spectra/' + data[i][1] + '/' + obsnum
    rawfiles = os.listdir( directory )
    for file in rawfiles:
        f.write( directory + '/' + file + '\n' )

f.close()

