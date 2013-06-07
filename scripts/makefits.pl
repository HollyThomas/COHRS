#!/star/Perl/bin/perl

# ----------------------------------------------------------------------
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use NDF;
use Statistics::Descriptive;
use Astro::FITS::Header;
use Astro::FITS::Header::NDF;

# -------------------------------1---------------------------------------

#my $file = $ARGV[0];
#chomp $file;
#if (!-e $ARGV[0]){
#    print "Input file, please?:";
#    $file = <STDIN>;
#}

my $inlist = "in.txt";
open IN, "<$inlist"
    or die "Can't open inlist '$inlist' : $!";

foreach my $file (<IN>){
    chomp $file;

$file =~s/.sdf//;

my $outfile = join("_", ${file}, "out");
chomp $outfile;
print "naming outfile $outfile\n";

system("scp ${file}.sdf ${outfile}.sdf");
#print "Switching to azel\n";
#system("$ENV{KAPPA_DIR}/wcsattrib ${outfile} set system azel accept");
$outfile =~ s/.sdf//;
#print "rotating so azimuth is up\n";

#print "trimming to inner 5 arcmin\n";
system("$ENV{KAPPA_DIR}/ndfcopy ${file}\'(,,)\' out=${outfile} trimwcs trim");
#system("$ENV{KAPPA_DIR}/rotate ${file} angle=! out=${outfile}_2d accept");
print "making the axis coords\n";
system("$ENV{KAPPA_DIR}/setaxis ${outfile} mode=lin dim=1");
system("$ENV{KAPPA_DIR}/setaxis ${outfile} mode=lin dim=2");
#system("$ENV{KAPPA_DIR}/setaxis ${outfile}_2d mode=exp dim=1 expr=\"\'INDEX\'\" accept");
#system("$ENV{KAPPA_DIR}/setaxis ${outfile}_2d mode=exp dim=2 expr=\"\'INDEX\'\" accept");
system("$ENV{KAPPA_DIR}/erase ${outfile}.wcs ok=yes accept");
print "converting to fits...\n";
system("/star/bin/convert/ndf2fits ${outfile} out=!${outfile}.fits accept");

}
