#! /usr/bin/env python

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

