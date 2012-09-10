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

my $infile = "obsfilelist.txt";
open IN, "<$infile"
    or die "Can't open infile $infile :$!";

my $outfile = "testout.txt"; 
open OUT, ">$outfile"
or die "Can't open outfile '$outfile' :$!";

my %blah;

foreach my $line (<IN>){
    next if ($line =~ /^\#/);
    chomp $line;
    $line =~ s/^\s+//;
    my ($date, $obsnum, $proj) = split(/\s+/, $line, 3);
    last if (!defined $date);
    $obsnum = sprintf("%05d", $obsnum);
    my $datadir = "/jcmtdata/raw/acsis/spectra/${date}/${obsnum}";
    chomp(my $file = `ls $datadir/*_0001.sdf*`);
    print "$file\n";

    my $fileis;
    if ($file =~ m/.gz$/){
	my $filegz = "a${date}_${obsnum}_01_0001.sdf.gz";
	system("cp ${file} ${filegz}");
	system("ls ${filegz}");
	system("gunzip $filegz");
	$fileis = "a${date}_${obsnum}_01_0001.sdf";
	system("ls ${fileis}");
    }else{
	$fileis = $file;
    }


    my $hdr = eval{new Astro::FITS::Header::NDF( File => $fileis)};
    
    my $tauav = $hdr ->value( "WVMTAUST");
    if (!defined $tauav){
	print "Not writing obs $date $obsnum because no tauav\n";
	next;
	$tauav = "UNDEF";
    }
    my $tsysav = $hdr ->value( "MEDTSYS" );
    if (!defined $tsysav){
	print "Not writing obs $date $obsnum because no medtsys\n";
	next;
	$tsysav = "UNDEF";
    }
    my $inttime = $hdr ->value ( "INT_TIME");
    if (!defined $inttime){
	print "Not writing obs $date $obsnum because no int_time\n";
	next;
	$inttime = "UNDEF";
    }
    my $mapheight = $hdr ->value ( "MAP_HGHT" );
    if (!defined $mapheight){
	print "no mapheight setting to 9999\n";
#	next;
	$mapheight = "9999";
    }
    my $mapwidth = $hdr ->value ( "MAP_WDTH" );
    if (!defined $mapwidth){
	print "No mapwidth setting to 9999\n";
#	next;
	$mapwidth = "9999";
    }
    my $project = $hdr ->value ( "PROJECT" );
    if (!defined $project){
	print "Not writing obs $date $obsnum because no project\n";
	next;
	$project = "UNDEF";
    }
    my $basec1 = $hdr ->value ( "BASEC1" );
    if (!defined $basec1){
	print "Not writing obs $date $obsnum because no basec1\n";
	next;
	$basec1 = "UNDEF";
    }
    my $basec2 = $hdr ->value ( "BASEC2" );
    if (!defined $basec2){
	print "Not writing obs $date $obsnum because no basec2\n";
	next;
	$basec2 = "UNDEF";
    }
    my $tracksys = $hdr ->value ( "TRACKSYS" );
    if (!defined $tracksys){
	print "Not writing obs $date $obsnum because no tracksys\n";
	next;
	$tracksys = "UNDEF";
    }
    my $molecule = $hdr ->value ( "MOLECULE" );
    if (!defined $molecule){
	print "Not writing obs $date $obsnum because no molecule\n";
	next;
	$molecule = "UNDEF";
    }
    my $trans = $hdr ->value ( "TRANSITI" );
    if (!defined $trans){
	print "Not writing obs $date $obsnum because no transition\n";
	next;
	$trans= "UNDEF";
    }
    
    $trans =~ s/\s+//g;
    my $transition = join("", $molecule, $trans);


    my $c;
    if ($tracksys =~ /GAL/){
	$tracksys = "galactic";
	$c = new Astro::Coords ( long   => $basec1,
				 lat  => $basec2,
				 type => $tracksys,
				 units => 'degrees');
	
	
    }elsif ($tracksys =~ /J2000/){
	$c = new Astro::Coords ( ra   => $basec1,
				 dec  => $basec2,
				 type => $tracksys,
				 units => 'degrees');
    }

    my $long = sprintf("%0.2f", $c->glong(format => 'deg'));
    if ($long > 180){
	$long = sprintf("%0.2f", 360.00 - $long);
    }
    my $lat = sprintf("%0.2f", $c->glat(format => 'deg'));
    my ($ra, $dec) = $c->radec();
    my $key = join("_", "gal", $long, $lat, $date, $obsnum);
    my %ref;
    
    print "$date $obsnum $long $lat $transition\n";

    $ref{ "date" } = $date;
    $ref{ "obsnum" } = $obsnum;	
    $ref{ "long" } = $long;
    $ref{ "lat" } = $lat;
    $ref{ "tracksys" } = $tracksys;
    $ref{ "mapheight" } = $mapheight;
    $ref{ "mapwidth"} = $mapwidth;
    $ref{ "tsys" } = $tsysav;
    $ref{ "project"} = $project;
    $ref{ "transition"} = $transition;
    
    $blah{$key} = { %ref };
    
    if ($fileis =~ /^a/){
	system("rm $fileis");
    }
    
    
}

foreach my $key (sort keys %blah){
#    print $key;
    printf OUT ("%-5.20s %8d %05d %0.2f %0.2f %6s %6s %10s %4d %4d ", $key, $blah{$key}{"date"}, $blah{$key}{"obsnum"}, $blah{$key}{"long"}, $blah{$key}{"lat"}, $blah{$key}{"transition"}, $blah{$key}{"tracksys"}, $blah{$key}{"project"}, $blah{$key}{"mapheight"}, $blah{$key}{"mapwidth"});
#    foreach my $key2 (keys %{ $blah{$key}}){
#	print "  ";
#	print $blah{$key}{$key2};
 #  }
    print OUT "\n";
}
