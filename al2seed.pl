#!/usr/bin/perl -w
#----------------------------------------
# $Id: al2seed.pl,v 1.2 2013/06/17 21:29:59 bdunn Exp bdunn $
#----------------------------------------

use strict;
use warnings;

# Need these modules
use Time::Local;
use Getopt::Long;
use Pod::Usage;
use Env qw(ALT_RESPONSE_FILE);

#  Assume these for ArcLink server
my $alcmd = "arclink_fetch";

# Assume this
my $netcode = "WU";
my $usagestr = "Usage:  al2seed.pl  mm/dd[/yyyy] hh:mm[:ss] ddd\n\n";
my $padlen = 1;

# Global parallel arrays filled in by read_stationlist sunroutine
my @station;
my @lat;
my @lon;
my @elev;
my @nseismometers;
my @uwoid1;
my @uwoid2;

# Assume these command line options
my $address = "europe";
my $port = "18001";
my $user = "sysop";
my $stationfile = "/usr/local/lib/ontario.cfg";
my $altresfile = "/usr/local/lib/WU.dataless";
my $cleanup = 1;
my $verbose = 0;
my $help;
my $man;

# Process command line
GetOptions( "address|a=s"    => \$address,
            "port|p=s"       => \$port,
	    "user|u=s"       => \$user,
            "station|s=s"    => \$stationfile,
	    "response|r=s"   => \$altresfile,
            "cleanup|c!"     => \$cleanup,
            "verbose|v!"     => \$verbose,
            "help|h"         => \$help,
            "man"            => \$man
)
	     or pod2usage( "Try '$0 --help' for more information.");
	     
pod2usage( -verbose => 1 ) if $help;
pod2usage( -verbose => 2)  if $man;		      

# Need this for rdseed utility
$ALT_RESPONSE_FILE = $altresfile;
die "Dataless MINISEED file not found: $altresfile\n" if !(-e $altresfile);

#  Event information from command line
if ( scalar( @ARGV) != 3 )  {
   printf STDERR $usagestr;    
   exit -1;
}

#  Convert date from first arg: mm/dd[/yyyy]
(my $month,my $mday, my$year) = split('/',$ARGV[0]);

if( !defined($month) || !defined($mday) ) {
    printf STDERR $usagestr;
    exit -1;
}

# assume this year if not given
if (!defined($year)) {
   my @today = localtime;
   $year = $today[5] + 1900;
}

if (checkdate($year,$month,$mday) ) {
    printf STDERR $usagestr;
    exit -1;
}

# Convert time from second arg: hh:mm[:ss]
(my $hours,my $mins,my $secs) = split(':',$ARGV[1]);

if (!defined($hours) || !defined($mins)) {
    printf STDERR $usagestr;
    exit -1;
}

# can assume secs = 0 if not given
if (!defined($secs)) {
    $secs = 0;
}

if (checktime($hours,$mins,$secs) ) {
    printf STDERR $usagestr;
    exit -1;
}

# length of time window in seconds from 3rd command line arg
my $duration = $ARGV[2];
if( $duration <= 0 ) {
   printf STDERR $usagestr;
   exit -1;
}

# start time in seconds since 1970
my $startsecs = timegm($secs,$mins,$hours,$mday,$month-1,$year-1900 );
if( $startsecs == -1) {
   printf STDERR $usagestr;
   exit -1;
}

# get start time into correct form for arclink_fetch
($secs,$mins,$hours,$mday,$month,$year) = gmtime( $startsecs-$padlen);
$year += 1900;
$month += 1;
my $starttimstr = sprintf "%04d,%02d,%02d,%02d,%02d,%02d",
    $year, $month, $mday, $hours, $mins, $secs;

# get start time in correct form for rdseed
(my $rsecs1,my $rmins1,my $rhours1,my $rmday1,my $rmonth1,my $ryear1) =
    gmtime( $startsecs);
$ryear1 += 1900;
$rmonth1 += 1;
my $rdseedstart = sprintf "%04d/%02d/%02d,%02d:%02d:%02d",
    $ryear1, $rmonth1, $rmday1, $rhours1, $rmins1, $rsecs1;
    
# get end time into correct form for arclink_fetch
(my $secs2,my $mins2,my $hours2,my $mday2,my $month2,my $year2) =
    gmtime( $startsecs+$duration+$padlen);
$year2 += 1900;
$month2 += 1;
my $endtimstr = sprintf "%04d,%02d,%02d,%02d,%02d,%02d",
    $year2, $month2, $mday2, $hours2, $mins2, $secs2;
   
# get end time into correct form for rdseed
(my $rsecs2,my $rmins2,my $rhours2,my $rmday2,my $rmonth2,my $ryear2) =
    gmtime( $startsecs+$duration);
$ryear2 += 1900;
$rmonth2 += 1;
my $rdseedend = sprintf "%04d/%02d/%02d,%02d:%02d:%02d",
    $ryear2, $rmonth2, $rmday2, $rhours2, $rmins2, $rsecs2;

# Miniseed file name in form "yyyymmdd_hhmmss.mseed"
# delete existing file
my $msname = sprintf "%04d%02d%02d_%02d%02d%02d.mseed",
    $year, $month, $mday, $hours, $mins, $secs;
if (-e $msname ) {
   if ($verbose)  {
       print "Miniseed file already exists: $msname, deleting\n";
   }
   unlink( "$msname" ) or warn "Failed to delete Miniseed file: $msname";
}

# FULL SEED file name in form "Syyyymmdd_hhmmss"
# delete existing file
my $seedname = sprintf "S%04d%02d%02d_%02d%02d%02d",
    $ryear1, $rmonth1, $rmday1, $rhours1, $rmins1, $rsecs1;
if (-e $seedname ) {
   if ($verbose)  {
       print "FULL SEED file already exists: $seedname, deleting\n";
   }
   unlink( "$seedname" ) or warn "Failed to delete FULL SEED file: $seedname";
}

# Read station file
read_stationlist($stationfile) ||
    die "Error reading station file: $stationfile\n";

# make request file
make_arclink_request($starttimstr,$endtimstr,$netcode);

# command to extract miniseed data from arclinkserver using
# arclink_fetch (SeisComp3 utility)
my $extractcmd;
if ($verbose) {
    $extractcmd = $alcmd.
     " -a ".$address.":".$port." -u ".$user." -o ".$msname." -p -v req.txt";
}
else {
    $extractcmd = $alcmd.
     " -a ".$address.":".$port." -u ".$user." -o ".$msname." -p -q req.txt";
}

#system $extractcmd || die "arclink_fetch failed";
open(AL_CMD, "$extractcmd |") or die "arclink_fetch failed";
while(<AL_CMD>) {
   if( $verbose ) { printf STDOUT"$_"; }
}

# convert to full seed using rdseed
my $convertcmd = "rdseed -d -o 5 -g ".$altresfile." -f ".$msname;
system $convertcmd || die "rdseed failed";

# rename full seed output file
my $mvcmd = "mv seed.rdseed ".$seedname;
system $mvcmd || die "mv failed";

# cleanup files
if ( $cleanup ) {   
    if ( -e "req.txt" ) { unlink("req.txt"); }
    if ( -e "rdseed.inp" ) { unlink("rdseed.inp"); }
    if ( -e "rdseed.err_log" ) { unlink("rdseed.err_log"); }
    if ( -e $msname ) { unlink($msname); }
    if ( -e "seed.rdseed" ) { unlink("seed.rdseed"); }
}

#  That's All Folks
exit 0;

# ----------------------------------------------------------
#   Function: checkdate
#
#   Purpose: Checks that date is valid.
#
#   Arguments:
#      year,    year.  Range 1970-2038.
#      month,   month of year.  Range 1-12.
#      mday,    day of month.  Range 1-31.
#
#   Returns:
#       0,      Date is valid.
#      -1,      Date is invalid.
#
# --------------------------------------------------------
sub checkdate {

    my $maxmday;
    my $ret = 0;

   if( $_[1] < 1  ||  $_[1] > 12 )  {       # check month
      $ret = -1;
   }
   else  {
      $maxmday = 31;                       # check days in month
      if( $_[1] == 4  || $_[1] == 6 ||  $_[1] == 9 ||  $_[1] == 11 ) {
          $maxmday = 30;
      }

      if( $_[1] == 2 )  {                  # leap years
         $maxmday = 28;
         if( ($_[0]%4) == 0 )  {
             $maxmday = 29;
             if( (($_[0]%100) == 0) && (($_[0]%400) != 0) ) {
                $maxmday = 28;
             }
        }
      }

      if( ($_[2] < 1)  ||  ($_[2] > $maxmday) )  {
         $ret = -1;
      }
      else {                              # check year
         if( ($_[0] < 1970) || ($_[0] > 2038) ) {
            $ret = -1;
         }
      }
   }
   return $ret;

} # end sub checkdate

# ----------------------------------------------------------
# Function:  checktime
#
# Purpose:  Checks the time is valid.
#
# Parameters:  hour min sec
#
# Returns:  0, on success
#          -1, on failure. Bad time.
#
# ---------------------------------------------------------
sub checktime {

   my $ret = 0;
                   # check parameters
   if( ($_[0] < 0)  ||  ($_[0] > 23) ||
          ($_[1] < 0)  ||  ($_[1] > 59)  ||
             ($_[2] < 0)  ||  ($_[2] > 59) )  {
      $ret = -1;
   }

   return $ret;

} # End of checktime

# ----------------------------------------------------------
# Subroutine:  read_stationlist
#
# Purpose:  Reads the station list file.
#
# Parameters:  Name of station list file.
#
# Globals: station, lat, lon, elev, nseismometers, uwoID1, uwoID2
#          Parallel arrays created reading stationlist.
#
# Returns: n, no lines read
#          0, failure
#
# ---------------------------------------------------------
sub read_stationlist {
    my @line;

    open(STATIONS, $_[0]) || return 0;
    
    # process each line of station file in form (1 or 2 instruments),
    #  station  lat  long  elev  hub  1  uwoid1
    #  station  lat  long  elev  hub  2  uwoid1  uwoid2
    
    while( <STATIONS> ) {
    
       chop;
       @line = split;
       if( @line < 6 ) {
           printf STDERR "Error reading station file: $_\n";
           next;
       }
    
       if(($line[4] == 2)  &&  ( @line < 7 )) {
           printf STDERR "Error reading station file: $_\n";
           next;
       }
    
       # save station in list
       push(@station,$line[0]);
       push(@lat,$line[1]);
       push(@lon,$line[2]);
       push(@elev,$line[3]);
       push(@nseismometers,$line[4]);
       push(@uwoid1,$line[5]);
       if( $line[4] == 2 ) {
          push(@uwoid2,$line[6]);
       }
       else  {
          push(@uwoid2,0);
       }

    } # while
    
    close(STATIONS);
    return @station;
}

# ----------------------------------------------------------
# Subroutine:  make_arclink_request
#
# Purpose:  Makes a request file for arclinktool.
#
# Parameters:  Start time string in form yyyy,mm,dd,hh,mm,ss.
#              End   time string in form yyyy,mm,dd,hh,mm,ss.
#              Network string like CN.
#
# Globals: station, nseismometers.
#          Parallel arrays created from station list file.
#
# Returns:  0, success
#          -1, failure
#
# ---------------------------------------------------------
sub make_arclink_request {

    open( REQFILE, ">req.txt") || die "Failed to create req.txt";
    
    for(my $i=0; $i <= $#station; $i++) {
       
       printf REQFILE "%s %s %s %s %s\n",
            $_[0], $_[1], $_[2], $station[$i], "HH*";
       
       if ($nseismometers[$i] == 2) {
           printf REQFILE "%s %s %s %s %s\n",
               $_[0], $_[1], $_[2], $station[$i], "HN*";
       }      
    }
    
    close REQFILE;
    return 0;
}
__END__

=head1 NAME

al2seed.pl - Request data from an ArcLink server and convert it to
a FULL SEED Volume.

=head1 SYNOPSIS

al2seed.pl [options] mm/dd[/yyyy] hh:mm[:ss] ddd

=head1 DESCRIPTION

al2seed.pl connects to an ArcLink server and requests data for a
given time window and duration.  A list of stations is requested from the
server and the data is returned in MiniSEED format.  The data is then
converted to FULL SEED using the Iris rdseed program.  A dataless MiniSEED
file will all the station instrument and response information is required
by the rdseed program to correctly convert the data to FULL SEED format.

=head1 ARGUMENTS

=over 8

=item B<mm/dd[/yyyy] hh:mm[:ss] ddd>

The first argument is the start date of data to fetch where B<mm> is month of
year, B<dd> is day of month and B<yyyy> is year.  The year is optional and
the current year is the default if not given.

The second argument is the start time of data to fetch where B<hh> is the hour,
B<mm> is the minute and B<ss> is the seconds.  Seconds is optional and the
default is 0 if not given.

The third argument is the duration of data to fetch where B<ddd> is the number
of seconds.

=back

=head1 OPTIONS

=over 8

=item B<--address=name || -a name>

IP address or computer I<name> of the ArcLink server to connect to.  Default is
B<europe>.

=item B<--port=nnnn || -p nnn>

Port I<number> the ArcLink server is listening on. Default is B<18001>.

=item B<--user=name || -u name>

The name of the I<user> to connect to the ArcLink server. Default is B<sysop>.

=item B<--station=filename || -s filename>

The list of stations to fetch data from in the file called I<filename>.
Default is called B<ontario.cfg> in the B</usr/local/lib> directory.

=item B<--response=filename || -r filename>

The dataless MiniSeed file called I<filename> with all the station and
instrument responses needed for the rdseed program.  Default is called
B<WU.dataless> in the B</usr/local/lib> directory.

=item B<--cleanup || -c || --no-cleanup>

Remove or cleanup intermediate files with I<--cleanup (or -c)> or do not
cleanup files with I<--no-cleanup>.  Default is B<--cleanup>.

=item B<--verbose || -v || --no-verbose>

Print more verbose with messages with I<--verbose (or -v)> or be quiter with
I<--no-verbose>. Default is B<--no-verbose>. 

=item B<--help || -h>

Prints the help message and exits.

=item B<--manual || -m>

Prints the manual page and exits.

=back

=head1 SEE ALSO

archlink_fetch, rdseed

=head1 AUTHOR

Bernie Dunn,
Earth Sciences,
Western University of Canada

=cut
