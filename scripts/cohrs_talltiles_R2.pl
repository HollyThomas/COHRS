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
my $long = 9.5;

while ( $long < 62.5 ) {

# Set latitude limits for the north (n) and south (s) tiles.
   my $lat_1 = -0.55;
   my $lat_2 = 0.55;

# Set the longitudes, ensuring that the values are floating point, not
# integer as they will be used as NDF bounds.
   my $long_1 = sprintf( "%0.2f", $long - 0.5 * $inc_long );
   my $long_2 = sprintf( "%0.2f", $long + 0.5 * $inc_long );

# Generate output name.
   my $name_1 = sprintf( "%0.2f", $long );
   $name_1 =~ s/\./p/;
   $outfile = join( "", "$ENV{COHRS_TILED}", "/COHRS_", $name_1, "_0p00_CUBE_T3T2_", $version );

# Find the input filename from the various mosaics.
    if ( $long > 9.4 && $long < 14.1 ) {
       $infile = "$ENV{COHRS_TILED}/14mosaic_R2n";

    } elsif ( $long > 13.9 && $long < 18.1 ) {
       $infile = "$ENV{COHRS_TILED}/18mosaic_R2n";

    } elsif ( $long > 17.9 && $long < 22.1 ) {
       $infile = "$ENV{COHRS_TILED}/22mosaic_R2n";

    } elsif ( $long > 21.9 && $long < 26.1 ) {
       $infile = "$ENV{COHRS_TILED}/26mosaic_R2n";

    } elsif ( $long > 25.9 && $long < 30.1 ) {
       $infile = "$ENV{COHRS_TILED}/31mosaic_R2n";

    } elsif ( $long > 29.9 && $long < 34.1 ) {
       $infile = "$ENV{COHRS_TILED}/34mosaic_R2n";

    } elsif ( $long > 33.9 && $long < 38.1 ) {
       $infile = "$ENV{COHRS_TILED}/38mosaic_R2n";

    } elsif ( $long > 37.9 && $long < 42.1 ) {
       $infile = "$ENV{COHRS_TILED}/42mosaic_R2n";

    } elsif ( $long > 41.9 && $long < 46.1 ) {
       $infile = "$ENV{COHRS_TILED}/46mosaic_R2n";

    } elsif ( $long > 45.9 && $long < 49.1 ) {
       $infile = "$ENV{COHRS_TILED}/49mosaic_R2n";

    } elsif ( $long > 48.9 && $long < 52.1 ) {
       $infile = "$ENV{COHRS_TILED}/52mosaic_R2n";

    } elsif ( $long > 51.9 && $long < 56.1 ) {
       $infile = "$ENV{COHRS_TILED}/56mosaic_R2n";

    } elsif ( $long > 55.9 && $long < 59.1 ) {
       $infile = "$ENV{COHRS_TILED}/59mosaic_R2n";

    } elsif ( $long > 58.9 && $long < 62.1 ) {
       $infile = "$ENV{COHRS_TILED}/63mosaic_R2n";
    }

# Extract the tiles.
    print "$long $lat_1 $lat_2 $long_1 $long_2 $name_1 $outfile\n";
    system( "$ENV{KAPPA_DIR}/ndfcopy in=$infile\'($long_1:$long_2,$lat_1:$lat_2,-200.0:300.0)\' out=$outfile exten" );

    $long += 0.5;
}
