# Searches the simulation database to find the correct predictions.
# Arguments passed are Simulation SQLite db and the event table

use DBI;											# For working with SQLite
use Math::Interpolate qw(robust_interpolate);		# For interpolating the tables
use Getopt::Long;									# For taking command line inputs
use List::Util qw( min max );						# For sorting
use Data::Dump;										# For debugging

# Check for input arguments
my %args;
my $verbose = '';	# option variable to print everything.
my $gmpe = '';		# option variable to enable gmpe output

GetOptions(\%args,
           "sql=s",
           "tbl=s",
           "cf=s",
           "m=s",
			"stress=s",
           'verbose' => \$verbose,
           'gmpe' => \$gmpe,
           	
           ) or die "Invalid arguments!";
           
die "\nMissing arguments.\nUsage: $0 --sql [SQLITEFILE] --tbl [EVENT_TABLE]\nOR\t$0 --sql [SQLITEFILE] --m [scenario Mw] --stress [scenario stress]\n\n" unless (($args{tbl} && $args{sql}) || ($args{m} && $args{stress} && $args{sql}));

# Connect to the SQLite file
my $dbh = DBI->connect("dbi:SQLite:dbname=$args{sql}","","");
$dbh->{AutoCommit} = 0;  # enable transactions, for speed.


# Read correction factor file
my %cfact;
if ($args{cf}){

open (B, $args{cf}) or die "Cannot open correction factor file $args{tbl}: $!";

for (<B>){
	if (m|^\!|){next;}
	@f = split(/\s+/);
	
	$cfact{$f[0]+0}->[0] = $f[1];
	$cfact{$f[0]+0}->[1] = $f[2];
	$cfact{$f[0]+0}->[2] = $f[3];
	$cfact{$f[0]+0}->[3] = $f[4];
		
}
close (B);
}

my @Msim = @{$dbh->selectcol_arrayref("SELECT DISTINCT Mw FROM PSA1HZ ORDER BY Mw ASC")};
my @Rsim = @{$dbh->selectcol_arrayref("SELECT DISTINCT R FROM PSA1HZ ORDER BY R ASC")};
my @Ssim = @{$dbh->selectcol_arrayref("SELECT DISTINCT S FROM PSA1HZ ORDER BY S ASC")};
my @fsim = @{$dbh->selectcol_arrayref("SELECT DISTINCT f FROM ALL_F")};


my $Mw_eff;
my $S_eff;

# If the script is being used to get GMPE for scenario earthquakes
if ($args{m} && $args{stress}){
	$Mw_eff = $args{m};
	$S_eff = $args{stress};
	goto OUTPUTS;
}

# Open event table file
open (A, $args{tbl}) or die "Cannot open event table file $args{tbl}: $!";

# Load observations into arrays
my @dist, my @psa1, my @psa10;
 

if ($verbose) {print "===================================\nReading PSA table at 1Hz and 10Hz\nR\t1Hz\t10Hz\n\n";}

for (<A>){
	no warnings 'numeric';
	
	@f = split(/\s+/);
	
	if ($f[2] < 600 && $f[2] > 0 && $f[7] > 0 && $f[11] > 0 && $f[1] =~ m/z$/i){
		if ($verbose){	
			printf( "%2.2f\t%2.4f\t%2.4f\n",$f[2],$f[7],$f[11]);
		}
		push (@dist,$f[2]);
		push (@psa1,$f[7]);
		push (@psa10,$f[11]);
		
	}
}

die "Not enough data points\n" unless scalar @dist > 4;


my %intp_tbl;
my %res_rms_m;
my %res_rms_s;


$Mw_eff = get_Mw(600);
$S_eff =  get_S($Mw_eff);

OUTPUTS:
printf ("%20s: %2.1f\n","Mw",$Mw_eff);
printf ("%20s: %3.0f\n","Stress",$S_eff);
printf ("%20s: %2.5f\n","Average |residual|",$res_rms_m{$Mw_eff});


# If option to print GMPE table is selected	
if ($gmpe){
	print "GMPE Table for best-fit with SIMSIM simulations\n------------------------\n";
	
	my %table = getTables($Mw_eff,$S_eff);
	
	my $R_ref = $table{"r"};
	my @Rs = @$R_ref;
	
	printf("%13s","R");
	for (@fsim){
		if ($_ == -1){next;} #Skip PGV
		if ($_ == 999.99){printf("%13s","PGA"); next;}
		printf("%11sHz",$_);
		
	}
	print "\n";
	
	
	for my $i (0 .. $#Rs) {
		printf("%13s","$Rs[$i]");
		for (@fsim){
			if ($_ == -1){next;} #Skip PGV	
			my $a_ref = $table{$_};
			my @array = @$a_ref;			
			printf("%13.5e",$array[$i]);
		}
		print "\n";
	}	
}
	

$dbh->disconnect();

########################
##### Sub routines #####
########################

sub get_Mw{
	(my $S) = @_;
	my @PSAsim; my @Rsim;

	my $sth = $dbh->prepare("SELECT Mw,R,A FROM PSA1HZ WHERE S = $S");
	$sth->execute;
	my $hash = $sth->fetchall_arrayref();
	
	for my $m (@Msim){
		for my $row (@$hash){
			if ($m == $$row[0]) {
				push (@Rsim,	$$row[1]);
				push (@PSAsim,  correct($m,1)*$$row[2]); 
			}
		}
		
		$psa_at_dist = interpolate (\@dist,\@Rsim,\@PSAsim);
		@Rsim = (); @PSAsim=();
		@psa = @$psa_at_dist;
		
		@res = map { log10($psa[$_]) - log10($psa1[$_]) } 0 .. $#psa;
	
		$res_rms_m{$m} = rms( @res );
	}
	
	return (sort {$res_rms_m{$a} <=> $res_rms_m{$b}} keys %res_rms_m)[0];
}


sub get_S{
	(my $M) = @_;

	my @Rsim, my @PSAsim;
	
	my $sth = $dbh->prepare("SELECT S,R,A FROM PSA10HZ WHERE Mw = $M");
	$sth->execute;
	my $hash = $sth->fetchall_arrayref();
	
		
	for my $s (@Ssim){
		for my $row (@$hash){
			if ($s == $$row[0]) {
				push (@Rsim,	$$row[1]);
				push (@PSAsim,	correct($m,10)*$$row[2]);
			}
		}
		$psa_at_dist = interpolate (\@dist,\@Rsim,\@PSAsim);
		@Rsim = (); @PSAsim=();
		@psa = @$psa_at_dist;
		
		$intp_tbl{$s} = [@psa];
				
		@res = map { log10($psa[$_]) - log10($psa10[$_]) } 0 .. $#psa;
	
		$res_rms_s{$s} = rms( @res );
	}
	
	return (sort {$res_rms_s{$a} <=> $res_rms_s{$b}} keys %res_rms_s)[0];
}



sub getTables{
	(my $m, my $s) = @_;


	my %gmpe_table;
	
	for (@fsim){
		$gmpe_table{$_} = $dbh->selectcol_arrayref("SELECT ".correct($m,$_)."*A FROM ALL_F WHERE Mw = $m AND S = $s AND f = $_") or die "Problem with reading db\n";
	}

	$gmpe_table{"r"} = $dbh->selectcol_arrayref("SELECT R FROM ALL_F WHERE Mw = $m AND S = $s AND f = 1") or die "Problem with reading db\n";
	
	return %gmpe_table;
}


sub interpolate{
	(my $xUnknown_ref, my $xKnown_ref, my $yKnown_ref) = @_;
	my @vals;
		
	for (@$xUnknown_ref){
		($a, $b) = robust_interpolate($_, $xKnown_ref, $yKnown_ref);
		push(@vals,$a);
	}
	return \@vals;
}


sub correct{
	(my $m, my $f) = @_;
		
	#If correction factor not available for this frequency, interpolate.
	if (!(exists $cfact{$f})) {
			
		if ($f == 999.99 || $f == -1){return 1;}
		
		my @freq; my @c1; my @c2; my @c3; my @c4;
		foreach my $key (sort keys %cfact) {
			push (@freq,	$key);
			push (@c1,	$cfact{$key}->[0]);
			push (@c2,	$cfact{$key}->[1]);
			push (@c3,	$cfact{$key}->[2]);
			push (@c4,	$cfact{$key}->[3]);
		}
		
		if (scalar @freq < 2){return 1;}
		
		( $cfact{$f}->[0],) = robust_interpolate($f, \@freq, \@c1); 
		( $cfact{$f}->[1],) = robust_interpolate($f, \@freq, \@c2);
		( $cfact{$f}->[2],) = robust_interpolate($f, \@freq, \@c3);
		( $cfact{$f}->[3],) = robust_interpolate($f, \@freq, \@c4);
	}
	
	if ($cfact{$f}->[0] == 0 || $cfact{$f}->[2] == 0){return 1;}
	
	if ($m <= $cfact{$f}->[0]){return 10**($cfact{$f}->[1]);} 
	if ($m >= $cfact{$f}->[2]){return 10**$cfact{$f}->[3];}
	
	if ($m > $cfact{$f}->[0] && $m < $cfact{$f}->[2]){
		return 10**(       $cfact{$f}->[1]   +     ($m-$cfact{$f}->[0])*($cfact{$f}->[3]-$cfact{$f}->[1])/($cfact{$f}->[2]-$cfact{$f}->[0])                            );
	}
	
	return 1;
}

sub log10 {
	my $n = shift;
	return log($n)/log(10);
}


sub rms{
	my $r = 0;
    #$r += $_**2 for @_;
    #return sqrt( $r/@_ );
	
	# RMS gives more weight to outliers, changing to first order, absolute sum of residuals
	$r += abs($_) for @_;
    return ( $r/@_ );
	
}
