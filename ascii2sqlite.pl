# Writes the SMSIM TD Simulations to a SQLite file.
# Arguments passed are the name of simulated table file, and the name of sqlite file.

scrict;
use warnings;
use DBI;								# For SQLite transactions
use Getopt::Long;						# For taking inputs from the command line

# Check for input arguments
my $in = '';		# option variable for input SMSIM simulation table (.col)
my $out = '';		# option variable for output SQLite database

GetOptions(
           "in=s" => \$in,
           "out=s" => \$out
           ); 
           
           
if ($in eq "" || $out eq ""){ 
	die "Missing arguments.\nUsage: $0 --in [.COL file] --out [SQLite file]\n
	[.COL file] is the simulation table from SMSIM.
	[SQLite file] is the filename for the output sqlite databse.\n";
}


# Open SOURCE_FILE
open (A, $in) or die "cannot open $in: $!\n";


# Create the SQLite file
my $dbh = DBI->connect("dbi:SQLite:dbname=$out","","");
$dbh->{AutoCommit} = 0;  # enable transactions, for speed.


# Make tables

makeTable("PSA0p20HZ");
makeTable("PSA0p33HZ");
makeTable("PSA0p50HZ");
makeTable("PSA1HZ");
makeTable("PSA2HZ");
makeTable("PSA3p33HZ");
makeTable("PSA5HZ");
makeTable("PSA10HZ");
makeTable("PSA20HZ");
makeTable("PGA");
makeTable("PGV");
makeTable("ALL_F");



# Make handles
my $s_PSA0p20HZ = makeStatementHandle("PSA0p20HZ");
my $s_PSA0p33HZ = makeStatementHandle("PSA0p33HZ");
my $s_PSA0p50HZ = makeStatementHandle("PSA0p50HZ");
my $s_PSA1HZ = makeStatementHandle("PSA1HZ");
my $s_PSA2HZ = makeStatementHandle("PSA2HZ");
my $s_PSA3p33HZ = makeStatementHandle("PSA3p33HZ");
my $s_PSA5HZ = makeStatementHandle("PSA5HZ");
my $s_PSA10HZ = makeStatementHandle("PSA10HZ");
my $s_PSA20HZ = makeStatementHandle("PSA20HZ");
my $s_PGA = makeStatementHandle("PGA");
my $s_PGV = makeStatementHandle("PGV");
my $s_ALL_F = makeStatementHandle("ALL_F");


# Read the COL file and write to the database
for (<A>){
	@feilds = split(" ");

	# Note on feild numbers (This depends on SMSIM output format)
	# This works for the output of TD LOOP SIMULATOR
	
	# $feild[0] is damp
	# $feild[1] is period
	# $feild[1] is freq
	# $feild[3] is Mw
	# $feild[4] is Rjb
	# $feild[10] is Stress
	# $feild[11] is Amplitude (cgs)
	
	# If the format differs, please adjust
	
	if ($_ =~ m|^\s0\.050|){		# This test makes sure that the row is valid (Mw is a positive number)
				
		
		if ($feilds[2] > .19 && $feilds[2] < 0.21)	{$s_PSA0p20HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > .32 && $feilds[2] < 0.34)	{$s_PSA0p33HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > .49 && $feilds[2] < 0.52)	{$s_PSA0p50HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > .9 && $feilds[2] < 1.1)	{$s_PSA1HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > 1.9 && $feilds[2] < 2.1)	{$s_PSA2HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > 3.32 && $feilds[2] < 3.34)	{$s_PSA3p33HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > 4.9 && $feilds[2] < 5.2)	{$s_PSA5HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > 9.9 && $feilds[2] < 10.2)	{$s_PSA10HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] > 19.9 && $feilds[2] < 20.5)	{$s_PSA20HZ->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] == 999.99)					{$s_PGA->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		if ($feilds[2] == -1)						{$s_PGV->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;}
		
		
		$s_ALL_F->execute($feilds[2],$feilds[3],$feilds[4],$feilds[10],$feilds[11]) or die $DBI::errstr;
	}
}




$s_PSA0p20HZ->finish;
$s_PSA0p33HZ->finish;
$s_PSA0p50HZ->finish;
$s_PSA1HZ->finish; 
$s_PSA2HZ->finish; 
$s_PSA3p33HZ->finish;
$s_PSA5HZ->finish; 
$s_PSA10HZ->finish;
$s_PSA20HZ->finish;
$s_PGA->finish; 
$s_PGV->finish;
$s_ALL_F->finish;

$dbh->commit or die $DBI::errstr;

close (A);



sub makeTable
{
(my $f) = @_;
	
my $sql = <<EOF;
   CREATE TABLE IF NOT EXISTS `$f` (
   `id` INTEGER UNIQUE PRIMARY KEY,
   `f` DOUBLE NOT NULL,
   `Mw` DOUBLE NOT NULL,
   `R` DOUBLE NOT NULL,
   `S` DOUBLE NOT NULL,
   `A` DOUBLE NOT NULL
	)
EOF

my $sth = $dbh->prepare($sql);
$sth->execute() or die $DBI::errstr;
$sth->finish();
	
return;	
}


sub makeStatementHandle
{
	(my $f) = @_;
	                     
	return $dbh->prepare("INSERT INTO $f (f, Mw, R, S, A)
                        values
                       (?,?,?,?,?)");;
}
