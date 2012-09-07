#!/star/Perl/bin/perl

=head1 NAME

database.pl: prompts for observation information and places into reference-able database.

=head1 DESCRIPTION


=head1 OPTIONS

=head1 NOTES

=cut

use strict;
use warnings;
use NDF;
use Getopt::Long;
use Pod::Usage;
use Astro::FITS::Header;
use Astro::FITS::Header::NDF;
use DateTime;
use Astro::Coords;
#-------------------------------------

my $answer;

my $infile = $ARGV[0];

if (!defined($ARGV[0])){
    print "No existing database? Do you wish to start a new one? (Y/N)";
  $answer = <STDIN>;
}

if ($answer =~/Y/i){
    $infile = "newdatabase.txt";
} elsif($answer =~/N/i){
    print "Please enter name of database:";
    $infile=<STDIN>;
}

open OUT, ">>$infile"
or die "Can't open outfile '$infile' :$!";



printf OUT ("%8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s\n", "obsname", "dateobs", "obsnum", "tauav", "tsysav", "inttime", " tracksys", "mapheight", "mapwidth" ,"project", "notes");


LINE:loop();

print "Do you wish to input another entry?";
 $answer = <STDIN>;
if ($answer =~/Y/i){
    goto LINE;
} elsif($answer =~/N/i){
    print "Ok, bye!";
}


sub loop {
print "obsname?";
my $obsname = <STDIN>;
  print "dateobs?";
my $dateobs = <STDIN>;
chomp($dateobs);
print "obsnum?";
my $obsnums = <STDIN>;
chomp($obsnums);
my @obsnum = split(",", $obsnums);

foreach (@obsnum){
my $obsnum = sprintf("%05d", $_);


my $dirlink = "/jcmtdata/raw/acsis/spectra/${dateobs}/${obsnum}/a${dateobs}_${obsnum}_01_0001.sdf";
system("ls ${dirlink}");

    my $hdr = new Astro::FITS::Header::NDF( File => $dirlink);
 
my $tauav = $hdr ->value( "WVMTAUST");
if (!defined $tauav){
    $tauav = "UNDEF";
}
my $tsysav = $hdr ->value( "MEDTSYS" );
if (!defined $tsysav){
    $tsysav = "UNDEF";
}
my $inttime = $hdr ->value ( "INT_TIME");
if (!defined $inttime){
    $inttime = "UNDEF";
}
my $tracksys = $hdr ->value ( "TRACKSYS" );
if (!defined $tracksys){
    $tracksys= "UNDEF";
}
my $mapheight = $hdr ->value ( "MAP_HGHT" );
if (!defined $mapheight){
    $mapheight = "UNDEF";
}
my $mapwidth = $hdr ->value ( "MAP_WDTH" );
if (!defined $mapwidth){
    $mapwidth = "UNDEF";
}
my $project = $hdr ->value ( "PROJECT" );
if (!defined $project){
    $project = "UNDEF";
}
my $basec1 = $hdr ->value ( "BASEC1" );
if (!defined $basec1){
    $basec1 = "UNDEF";
}
my $basec2 = $hdr ->value ( "BASEC2" );
if (!defined $basec2){
    $basec2 = "UNDEF";
}

my $c = new Astro::Coords ( ra   => '$basec1',
			    dec  => '$basec2',
			    type => 'J2000',
			    units => 'degrees');


my ($long, $lat) = $c->glonglat;
print "$long $lat\n";

#printf OUT ("%8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s %8.8s\n", $obsname, $dateobs, $obsnum, $tauav, $tsysav, $inttime, $tracksys, $mapheight, $mapwidth, $project, $notes);
}
}
