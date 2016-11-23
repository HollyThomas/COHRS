#!/usr/bin/env perl

=head1 NAME

cohrs_tiles.pl - Creates the 0.5-degree tiles from COHRS mosaics.

=head1 DESCRIPTION

This extracts 0.5-degree longitude by 1-degree latitude sections
from mosaics created by cohrs_strips.csh.

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
my $long = 10.0;

while ( $long < 62.5 ) {

   my $lat_1 = 0.5;
   my $lat_2 = -0.5;

   my $long_1 = $long - 0.5 * $inc_long;
   my $long_2 = $long + 0.5 * $inc_long;

# Generate output name.
   my $name_1 = sprintf( "%0.2f", $long );
   $name_1 =~ s/\./p/;
   $outfile = join( "", "$ENV{COHRS_TILED}", "/COHRS_", $name_1, "_0p00_CUBE_REBIN_", $version );

# Find the input filename from the various msoaics. 
    if ( $long > 9.9 && $long < 18.1 ) {
       $infile = "$ENV{COHRS_TILED}/inner1mosaic";

    } elsif ( $long > 17.9 && $long < 25.1 ) {
       $infile = "$ENV{COHRS_TILED}/inner2mosaic";

    } elsif ( $long > 24.9 && $long < 32.1 ) {
       $infile = "$ENV{COHRS_TILED}/inner3mosaic";

    } elsif ( $long > 31.9 && $long < 39.1 ) {
       $infile = "$ENV{COHRS_TILED}/middle1mosaic";

    } elsif ( $long > 38.9 && $long < 46.1 ) {
       $infile = "$ENV{COHRS_TILED}/middle2mosaic";

    } elsif ( $long > 45.9 && $long < 54.1 ) {
       $infile = "$ENV{COHRS_TILED}/outer1mosaic";

    } elsif ( $long > 53.9 && $long < 62.1 ) {
       $infile = "$ENV{COHRS_TILED}/outer2mosaic";
    }

    print "$long $lat_1 $lat_2 $long_1 $long_2 $name_1 $outfile\n";

    system( "$ENV{KAPPA_DIR}/ndfcopy in=$infile\'($long_1:$long_2,$lat_1:$lat_2,)\' out=$outfile exten" );

    $long += 0.5;
}
