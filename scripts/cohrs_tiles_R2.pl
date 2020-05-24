#!/usr/bin/env perl

=head1 NAME

cohrs_tiles_R2.pl - Creates the 0.5 x 1.0-degree tiles from COHRS mosaics.

=head1 DESCRIPTION

This extracts 0.5-degree longitude by 1,0-degree latitude sections
from mosaics created by cohrs_mosaic_strip1_R2.csh.

=head1 OPTIONS

=head1 NOTES

=cut

use strict;
use warnings;
use Getopt::Long;

my $version = "R2";
GetOptions( 'version=s', \$version );

my ( $infile, $outfile );

my $inc_long = 0.5;
my $long = 9.75;

while ( $long < 62.5 ) {

# Set latitude limts for the north (n) and south (s) tiles.
   my $lat_1 = -0.5;
   my $lat_2 = 0.5;

# Set the longitudes, ensuring that the values are floating point, not
# integer as they will be used as NDF bounds.
   my $long_1 = sprintf( "%0.2f", $long - 0.5 * $inc_long );
   my $long_2 = sprintf( "%0.2f", $long + 0.5 * $inc_long );

# Generate output name.
   my $name_1 = sprintf( "%0.2f", $long );
   $name_1 =~ s/\./p/;
   $outfile = join( "", "$ENV{COHRS_TILED}", "/COHRS_", $name_1, "_0p00_CUBE_3T2_", $version );

# Find the input filename from the various mosaics. 
    if ( $long > 9.7 && $long < 15.1 ) {
       $infile = "$ENV{COHRS_TILED}/15mosaic_R2n";

    } elsif ( $long > 14.9 && $long < 20.1 ) {
       $infile = "$ENV{COHRS_TILED}/20mosaic_R2n";

    } elsif ( $long > 19.9 && $long < 25.1 ) {
       $infile = "$ENV{COHRS_TILED}/25mosaic_R2n";

    } elsif ( $long > 24.9 && $long < 30.1 ) {
       $infile = "$ENV{COHRS_TILED}/30mosaic_R2n";

    } elsif ( $long > 29.9 && $long < 35.1 ) {
       $infile = "$ENV{COHRS_TILED}/35mosaic_R2n";

    } elsif ( $long > 34.9 && $long < 40.1 ) {
       $infile = "$ENV{COHRS_TILED}/40mosaic_R2n";

    } elsif ( $long > 39.9 && $long < 45.1 ) {
       $infile = "$ENV{COHRS_TILED}/45mosaic_R2n";

    } elsif ( $long > 44.9 && $long < 50.1 ) {
       $infile = "$ENV{COHRS_TILED}/50mosaic_R2n";

    } elsif ( $long > 49.9 && $long < 55.1 ) {
       $infile = "$ENV{COHRS_TILED}/55mosaic_R2n";

    } elsif ( $long > 54.9 && $long < 60.1 ) {
       $infile = "$ENV{COHRS_TILED}/60mosaic_R2n";

    } elsif ( $long > 59.9 && $long < 62.1 ) {
       $infile = "$ENV{COHRS_TILED}/62mosaic_R2n";
    }

# Extract the tiles.
    print "$long $lat_1 $lat_2 $long_1 $long_2 $name_1 $outfile\n";
    system( "$ENV{KAPPA_DIR}/ndfcopy in=$infile\'($long_1:$long_2,$lat_1:$lat_2,)\' out=$outfile exten" ); 

    $long += 0.5;
}