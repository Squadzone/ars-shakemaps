use Attempt;
use DBI;
use DBD::SQLite;
use YAML::Tiny;
use Net::FTP::Recursive;
use Net::SSLeay;
use Net::IMAP::Simple::Gmail;
use Net::SMTP::SSL;
use Authen::SASL;		# Net::SMTP uses Authen::SASL internally to do the authentication.
use Email::Simple;
use Email::MIME::Encodings;
use MIME::QuotedPrint;
use MIME::Entity;
use Config::Auto; 
use Geo::Distance;
use Math::Interpolate qw(robust_interpolate);
use Time::HiRes qw(gettimeofday tv_interval);

use Data::Dump;


goto THEEND;

# Record stating time, for measuring processing times
my $start_time = [Time::HiRes::gettimeofday()];

# Read configuration file
my $yaml = YAML::Tiny->read( 'qkresp.cfg' );

# These users are autorized to use REPEAT/REPLACE flag
# A similar list can be used to authorize only certain people to use the script
my %auth_users = ('user1@uwo.ca', 1 , 'user2@uwo.ca',1 , 'user3@uwo.ca', 1 );

# Connect to mail server and read inbox
my $server = Net::IMAP::Simple::Gmail->new('imap.gmail.com');
#my $server = Net::IMAP::Simple::SSL->new('imap.uwo.ca');

attempt {
	$server->login( $yaml->[0]->{user}, $yaml->[0]->{pass} );
}tries => 10, delay => 2 or die "Didn\'t open mailbox, problem: " . $server->errstr . "\n";

$server->select( 'Inbox' );
@ids = $server->search("UNSEEN");

#
# Read each unread mail starts
#
for my $id (@ids){
	my $email = Email::Simple->new(join('', $server->get($id)));
	my $email_body = $email->body;
	
#	Some email clients, Gmail on android for example, encodes
#	the message body with base64, hence our program cannot read such emails.
#	the purpose of the following code is to check if the message is encoded,
#	and if it is, it decodes it before reading the parameters. 
	
	if ($email->header("Content-transfer-encoding") eq 'base64'){$email_body = Email::MIME::Encodings::decode(base64 => $email_body);}
    	$email_body=decode_qp($email_body);
                  
	my @lines = split('\n',$email_body);
	my $command = "";
	my $getparams=0;
	
	for my $line (@lines){
		if ($line =~ m|^\W*?begin|i){$getparams = 1; next;}
        if ($line =~ m|^\W*?end|i && $getparams == 1){last;}
        if ($getparams == 1) {$command .= $line."\n";}	
	}
	
	# If there was nothing between BEGIN and END commands in the email
	if (length($command) < 2){
		my $cmd->{from} = $email->header("From");
		$cmd->{error} = "Error\:\nCould not read request email\n";
		reportError($cmd);
	}
	else{
	
		$command = Config::Auto::parse($command,format => "space");

#	The Config::Auto module automatically parses all the commands into key=>value 
#	pairs (hashref),ie 'latitude 43.23' is parsed and stored as '$command{"latitude"} = 43.23'
#	I recommend, that space is replaced by '=' (equal) for failproof parsing, as spaces
#	have some chances of failing under unusual circumstances. So, proposed request email should look like:
#	
#	begin
#	date = 2014/01/15
#	time = 20:32:00
#	duration = 20
#	latitude = 45
#	longitude = -83
#	depth = 10.02
#	magnitude = 2.6
#	end
#	
#	and parsing will be done as
#	$command = Config::Auto::parse($command,format => "equal");


		$command->{from} = $email->header("From");
			
		# Validate the request
		$command = validate($command);		
	
		# If there was a problem with the request, it will have a error key
		if (exists $command->{error}){
			write2log("Could not validate request from $command->{from}");
			reportError($command);
		}
		else{
			write2log("Processing request from $command->{from}");
			$command = processesRequest($command);
			sendEmail($command->{from},$command->{cc},$command->{reply});
			write2log('----------process complete-----mail sent---------');
		}

	}			

}
#
# Read each unread mail ends
#

$server->quit();


THEEND:


#
# Subroutines
#


#This subroutine checks if the request is a valid one. 
sub validate{
	(my $cmd) = @_;
	
	# Convert all keys into lowercase for consistancy with this script
	%$cmd = map { lc $_ => $$cmd{$_} } keys %$cmd;
	
	
	# Break date into year, month and day
	if ($cmd->{date} =~ m|(\d{4})\/(\d{1,2})\/(\d{1,2})|){
		($cmd->{year},$cmd->{month},$cmd->{day}) = ($1,$2,$3);
		delete $cmd->{date};
	}
	
	
	# Break time into hour, min and sec
	if ($cmd->{time} =~ m|(\d{1,2})\:(\d{1,2})\:(\d{1,2})|){
		($cmd->{hour},$cmd->{minute},$cmd->{second}) = ($1,$2,$3);
		delete $cmd->{time};
	}
	
	
	# If lon was used instead of longitude, lat instead of latitude, 
	# dur instead of duration, mag insread of magnitude & dep instead of depth
	# Rename the keys for consistancy
	if (exists $cmd->{lon}){$cmd->{longitude} = $cmd->{lon}; delete $cmd->{lon};}
	if (exists $cmd->{lat}){$cmd->{latitude} = $cmd->{lat}; delete $cmd->{lat};}
	if (exists $cmd->{dur}){$cmd->{duration} = $cmd->{dur}; delete $cmd->{dur};}	
	if (exists $cmd->{mag}){$cmd->{magnitude} = $cmd->{mag}; delete $cmd->{mag};}
	if (exists $cmd->{dep}){$cmd->{depth} = $cmd->{dep}; delete $cmd->{depth};}
	
	
	# Name of directory qCorrect will produce for this event
	$cmd->{qCorrectDirectory} = sprintf ("%4d\.%02d\.%02d\.%02d\.%02d\.%02d\.000", 
										$cmd->{year},
										$cmd->{month},
										$cmd->{day},
										$cmd->{hour},
										$cmd->{minute},
										$cmd->{second});
	# Name of seed that is returned by al2seed
	$cmd->{seedfile} = sprintf"S%04d%02d%02d_%02d%02d%02d",
				$cmd->{year},$cmd->{month},$cmd->{day},$cmd->{hour},$cmd->{minute},$cmd->{second};

    
    	# Store current time for logging purposes
    	$cmd->{requestTime} = &curtim; 		# We don't actually need this


	#Check date,time lat,long,depth,mag
	my $err = "Error\:\n";
	
	# If NOT ((year is current year) or (year is previous year))
	if (!($cmd->{year} == (localtime)[5]+1900 || $cmd->{year} == (localtime)[5]+1900-1)){
        $err .= sprintf ("Year should be %d or %d\n",(localtime)[5]+1900,(localtime)[5]+1900-1);
		$cmd->{error} = $err;
	}
	
	# If month is not a number between 1 and 12
	if ($cmd->{month} < 1 || $cmd->{month} > 12){
        $err .= sprintf ("Month should be between 1 and 12\n");
		$cmd->{error} = $err;
	}
	
	# If day is not a number between 1 and 31
	if ($cmd->{day} < 1 || $cmd->{day} > 31){
        $err .= sprintf ("Day should be between 1 and 31\n");
		$cmd->{error} = $err;
	}
	
	# If hour is not a number between 0 and 23
	if ($cmd->{hour} < 0 || $cmd->{hour} > 23){
        $err .= sprintf ("Hour should be between 0 and 23\n");
		$cmd->{error} = $err;
	}

	# If minute is not a number between 0 and 59
	if ($cmd->{minute} < 0 || $cmd->{minute} > 59){
        $err .= sprintf ("Minute should be between 0 and 59\n");
		$cmd->{error} = $err;
	}

    	# If second is not a number between 0 and 59
	if ($cmd->{second} < 0 || $cmd->{second} > 59){
        $err .= sprintf ("Second should be between 0 and 59\n");
		$cmd->{error} = $err;
	}
	
	# If duration is too long
	if ($cmd->{duration} > 1200){
        $err .= sprintf ("Duration should be less than 20 minutes\n");
		$cmd->{error} = $err;
	}
	
	# Check latitude
	if (exists $cmd->{latitude}){		# Since it is optional
		if ($cmd->{latitude} < -90 || $cmd->{latitude} > 90){
			$err .= sprintf ("Value for latitude is incorrect\n");
			$cmd->{error} = $err;
		}
	}
	
	# Check longitude
	if (exists $cmd->{longitude}){		# Since it is optional
		if ($cmd->{longitude} < -360 || $cmd->{longitude} > 360){
			$err .= sprintf ("Value for longitude is incorrect\n");
			$cmd->{error} = $err;
		}
	}
	
	# Check magnitude
	if (exists $cmd->{magnitude}){		# Since it is optional
		if ($cmd->{magnitude} < 0 || $cmd->{magnitude} > 10){
			$err .= sprintf ("Magnitude should be between 0 and 10\n");
			$cmd->{error} = $err;
		}
	}
	
	
	# Check if optional parameters are passed, otherwise use default value for just processing.
	# if latitude, longitude, magnitude are not specified, shakemap won't generate.
	if (!exists $cmd->{latitude}){$cmd->{latitude} = 0; $cmd->{noShakemap} = 1;}
	if (!exists $cmd->{longitude}){$cmd->{longitude} = 0; $cmd->{noShakemap} = 1;}
	if (!exists $cmd->{magnitude}){$cmd->{magnitude} = 0; $cmd->{noShakemap} = 1;}
	if (!exists $cmd->{depth}){$cmd->{depth} = 10;}
	if (!exists $cmd->{duration}){$cmd->{duration} = 300;}
	
	
	return $cmd;
}


#Subroutine which sends an email reporing the error in the request.
#Also suggests the correct syntax for the request.
sub reportError{
	(my $cmd) = @_;
	
	my $expectedCommand = <<EOF;
	
Proper request message format:

BEGIN
DATE       YYYY/MM/DD
TIME       hh:mm:ss
DURATION   sss.ss
LATITUDE    dd.ddd   (optional)
LONGITUDE  ddd.ddd   (optional)
DEPTH      ddd.ddd   (optional)
MAGNITUDE    d.d     (optional)
END

EOF

	$cmd->{error} = $cmd->{error}.$expectedCommand;
	
	my @cc = (); 		# Blank CC
	sendEmail($cmd->{from},\@cc,$cmd->{error});
}


#Subroutine for processing of a valid request
sub processesRequest{
	(my $cmd) = @_;
	
	if (-d "processed_data\/$cmd->{qCorrectDirectory}"){
		# This section means that a directory with the same parameters exist
		# Depending on the flag used, we can IGNORE/REPLACE/REPEAT
		
				
		# If REPLACE flag is used, and the sender is in the list of authorized users,
		# Clean the dir and reprocess
		if($cmd->{replace} && check_auth($cmd->{from})){ 
			# Clean directory
			system("rm -rf $cmd->{qCorrectDirectory}");
			goto PROCESS;
		}
		
		# If REPEAT flag is used, and the sender is in the list of authorized users,
		# Reprocess without cleaning
		if($cmd->{repeat} && check_auth($cmd->{from})){  
			# Don't clean directory, just reprocess
			goto PROCESS;	# This is not correctly implemented yet
			
		}
		
		# Else just return the link to processed data
		goto REPLY;
	}
	
	#
	# Normal processing
	#

	# Skip data processing for scenario shakemap
	if (!$cmd->{noShakemap} && $cmd->{scenario}){
		system("mkdir $cmd->{qCorrectDirectory}");
		goto SMAP;
	}	

PROCESS:
	# Call al2seed
	write2log("calling al2seed");	
	system (sprintf("al2seed\.pl %02d\/%02d\/%04d %02d\:%02d\:%02d %d",
				$cmd->{month},$cmd->{day},$cmd->{year},$cmd->{hour},$cmd->{minute},$cmd->{second},$cmd->{duration}));
	write2log("al2seed produced seed");
							
	# Call qCorrect
	write2log("calling qcorrect");
	system("rm -f ren_eve.b");
	system("\.\/qcorrect $cmd->{seedfile} $cmd->{year} $cmd->{month} $cmd->{day} $cmd->{hour} $cmd->{minute} $cmd->{second} $cmd->{latitude} $cmd->{longitude} $cmd->{depth} $cmd->{magnitude}");
	write2log("qcorrect finished processing");
	
SMAP:	
	# Call makeGmap	if possible
	if(!$cmd->{noShakemap}){
		write2log("starting to make shakemap");
		$cmd = makeGmap($cmd);
		write2log("making shakemap finished");
	}
	
	writeDB($cmd);
	
	# Push processed data to FTP
	
	write2log("starting FTP connection");
	system("cp -fr ars\.db to_ftp\/");
	system("mv $cmd->{qCorrectDirectory} to_ftp\/");
	chdir('to_ftp');
	$ftp = Net::FTP::Recursive->new("polaris4.es.uwo.ca", Debug => 0) or die "Cannot connect to Polaris: $@";
	$ftp->login($yaml->[0]->{ftp_user},$yaml->[0]->{ftp_pass}) or die "Cannot login to Polaris", $ftp->message;
	$ftp->cwd("/seismotoolbox/ars") or die "Cannot change to ars directory ", $ftp->message;
	$ftp->binary;
	$ftp->rput;
	system("mv $cmd->{qCorrectDirectory} \.\.\/processed_data\/");
	chdir('..');
	system("mv $cmd->{seedfile} seeds\/");
	write2log("pushing data to FTP finished");		

REPLY:	
	# CC to the people based on the recipent flag
	my @karen_list=('user4@uwo.ca', 'user5@uwo.ca');
	my @uwo_list=('user6@uwo.ca', 'user7@uwo.ca');
	my @opg_list=('abc@def.com','prq@xyz.com');
	my @bruce_list=('lmn@efg.com');
	my @emptyLst = ('');    

	$cmd->{cc} = \@karen_list;

	if ($cmd->{recipient} == 1){push(@{$cmd->{cc}},@uwo_list);}
	if ($cmd->{recipient} == 2){push(@{$cmd->{cc}},@uwo_list,@opg_list);}
	if ($cmd->{recipient} == 3){push(@{$cmd->{cc}},@uwo_list,@opg_list,@bruce_list);}
	if ($cmd->{recipient} == -1){$cmd->{cc} = \@emptyLst;}  


	# Attach the email text
	$cmd->{reply} = "The request details are:\n\n";
	$cmd->{reply}.=sprintf("Date       %04d\/%02d\/%02d\n",$cmd->{year}, $cmd->{month}, $cmd->{day});
	$cmd->{reply}.=sprintf("Time       %02d\:%02d\:%02d\n",$cmd->{hour}, $cmd->{minute}, $cmd->{second});
	$cmd->{reply}.=sprintf("Duration   %6.2f\n",$cmd->{duration});
	$cmd->{reply}.=sprintf("Latitude    %6.3f\n",$cmd->{latitude});
	$cmd->{reply}.=sprintf("Longitude  %7.3f\n",$cmd->{longitude});
	$cmd->{reply}.=sprintf("Depth      %7.3f\n",$cmd->{depth});
	$cmd->{reply}.=sprintf("Magnitude    %3.1f\n\n",$cmd->{magnitude});
	$cmd->{reply}.="\nThe processed data can be accessed at:\n";
	$cmd->{reply}.="http\:\/\/www\.seismotoolbox\.ca\/ars\/$cmd->{qCorrectDirectory}\n";

	return $cmd;
}



#Simple subroutine to send eMails.
#NOTE: It takes the array reference of CC list as an input, not the array itself.
sub sendEmail{
	(my $to, my $cc, my $body) = @_;

	my $from = $yaml->[0]->{user};
    	my $subject = 'SOSN data request auto response';
    	my $mime = MIME::Entity->build(Type  => 'multipart/alternative',
		Encoding => '-SUGGEST',
        From => $from,
        To => $to,
        Subject => $subject
        );
	
	$mime->attach(Type => 'text/plain',
                  Encoding =>'-SUGGEST',
                  Data => $body);
		
	# Open a connection to the Gmail smtp server
    	my $smtp = Net::SMTP::SSL->new('smtp.gmail.com',
						Port=> 465,
						Timeout => 20,
						Debug=>0);
    
    	# Authenticate
    	$smtp->auth( $yaml->[0]->{user}, $yaml->[0]->{pass});
    
    	# Send the rest of the SMTP stuff to the server
    	$smtp->mail($from);
    	$smtp->to($to);
    	$smtp->cc(@$cc);
    	$smtp->data($mime->stringify);
    	$smtp->quit();
	
}


# This subroutine checks if the sender of the request email is in the hash of
# authorized users ( %auth_users ) and returns 1, returns 0 otherwise.
sub check_auth{
	(my $sender) = @_;
	foreach $authorized_user (keys %auth_users)
	{
		if($sender =~ m/.$authorized_user.*/i ){return 1;}
	}
	
	return 0;
}


sub makeGmap{
	(my $cmd) = @_;
	
	my @epi = ($cmd->{longitude},$cmd->{latitude});
	# Latitude coverage; shakemap's height. (Function of earthquake size)
	my $delta_lat = 4;
	if ($cmd{magnitude} >= 3) { $delta_lat = 5; }
	if ($cmd{magnitude} >= 4) { $delta_lat = 8; }
	if ($cmd{magnitude} >= 5) { $delta_lat = 9; }
	if ($cmd{magnitude} >= 6) { $delta_lat = 10; }
	if ($cmd{magnitude} >= 7) { $delta_lat = 11; }

	my $aspect_ratio = 16/9;		# ratio of Width to Height of the produced map.
	my @n_tiles = (4,1); 			# Rows, Column for the tile grid.

	my $delta_lon = $delta_lat * $aspect_ratio;

	#
	#Calculate ground motions, and write XYZ grid file
	#

	#Call to findTable.pl which estimates Mw, Stress, and the GMP table
	if ($cmd->{scenario}){
		system("perl findTable.pl --sql sim.sqlite --stress 600 --m ".$cmd->{magnitude}." > GMP.tbl");
	}	
	else
	{
		system("perl findTable.pl --sql sim.sqlite --tbl ".$cmd->{qCorrectDirectory}."\/summary.txt > GMP.tbl");
	}

	#Read GMP.tbl

	open (GMPE,"GMP.tbl");

	<GMPE>;       			#Skip first line
	my $m = <GMPE>; $m =~ s/Mw:\s+//g; chomp($m);
	my $s = <GMPE>; $s =~ s/Stress:\s+//g; chomp($s);

	$cmd->{Mw} = $m;
	$cmd->{stress} = $s;	

	<GMPE>;<GMPE>;<GMPE>;		#Skip 3 more lines

	my @_r,my @_10p0, my @_5p0, my @_2p0, my @_1p0, my @_0p5, my @_0p3, my @_0p2, my @_0p1, my @_0p05, my @_0p033, my @_0p02, my @pga, my @pgv;
	for (<GMPE>){
		no warnings 'numeric';
	
		@f = split(/\s+/);
	
		push (@_r,$f[1]);
		push (@_10p0,$f[2]);
        	push (@_5p0,$f[3]);
		push (@_2p0,$f[4]);	
		push (@_1p0,$f[5]);
		push (@_0p5,$f[6]);
		push (@_0p3,$f[7]);
		push (@_0p2,$f[8]);
		push (@_0p1,$f[9]);
		push (@_0p05,$f[10]);
		push (@_0p033,$f[11]);
		push (@_0p02,$f[112]);
		push (@pga,$f[13]);
		push (@pgv,$f[14]);

	}
	close (GMPE);


	my $geo = new Geo::Distance;

	# i_max defines the size of grid over which the ground motions are calculated.
	my $i_max = 10;
	open (A,">shake.xyz");

	my $resolution_scale = 20;
	for $lat (($epi[1] - $i_max)*$resolution_scale .. ($epi[1] + $i_max)*$resolution_scale){
		for $lon (($epi[0] - $i_max)*$resolution_scale .. ($epi[0] + $i_max)*$resolution_scale){
			$r = $geo->distance( 'kilometer', $epi[0],$epi[1] => $lon/$resolution_scale,$lat/$resolution_scale );
			if ($r > 0){		
				#$psa = (1.496) + (0.899 * ($M_rep-4)) + (0.029 * ($M_rep-4)**2) - (1.268*log($r)) - (0.0000915*$r);
				($t1, $t2) = robust_interpolate($r, \@_r, \@_1p0);			
				$psa = $t1;
				$mmi;
				if (log10($psa) <= 1/65){$mmi =  2.5 + 1.51 * log10($psa)}
				else{$mmi =  0.2 + 2.9 * log10($psa)};	
			}
				
			print A (360 + $lon/20);
			print A "\t";
			print A ($lat/20);
			print A "\t";
			print A ($mmi);
			print A "\n";
		}
	}
	close (A);

	##### GENERATE PNG TILES + gMap.ctl


	# Define latitude longitude bounds (from NW to SE)
	my $gmapCtl = YAML::Tiny->new;

	$gmapCtl->[0]->{M_rep} = $cmd{magnitude};
	$gmapCtl->[0]->{Mw} = $m;
	$gmapCtl->[0]->{stress} = $s;
	$gmapCtl->[0]->{Epicenter} = [$epi[1],$epi[0]];
	$gmapCtl->[0]->{nTiles} = ($n_tiles[1]*$n_tiles[0]);
	
	system("mkdir tiles");

	# ai loops over latitudes.
	# aj loops over longitudes.

	$i = 0;
	for $ai  (0..$n_tiles[0]-1){
		for $aj (0..$n_tiles[1]-1){
			$gmapCtl->[1]->{"tile".$i}->{latN} =    (($epi[1]-$delta_lat/2) + ($ai * ($delta_lat/$n_tiles[0])));
			$gmapCtl->[1]->{"tile".$i}->{latS} =    (($epi[1]-$delta_lat/2) + (($ai+1) * ($delta_lat/$n_tiles[0]))); 
		
			$gmapCtl->[1]->{"tile".$i}->{lonW} =    (($epi[0]-$delta_lon/2) + ($aj * ($delta_lon/$n_tiles[1]))); 
			$gmapCtl->[1]->{"tile".$i}->{lonE} =    (($epi[0]-$delta_lon/2) + (($aj+1) * ($delta_lon/$n_tiles[1])));
	
			# Call to GMT script to make the PNG tile, defined by these lat lon bounds.		
			system ("/bin/sh genSmap.gmt ".($gmapCtl->[1]->{"tile".$i}->{lonW} + 360)." ".($gmapCtl->[1]->{"tile".$i}->{lonE} + 360)." ".$gmapCtl->[1]->{"tile".$i}->{latN}." ".$gmapCtl->[1]->{"tile".$i}->{latS});
			# Rename to tile's ID and move to \tiles subdir. 
			system ("mv temp.png tiles\/tile$i.png"); $i++;
		}
	}


	# Write the .ctl file which will be read by the server to produce the google map.
	system("rm -f gMap.ctl");	
	$gmapCtl->write( 'gMap.ctl' );

	system("mv tiles $cmd->{qCorrectDirectory}\/ ");
	system("mv gMap.ctl $cmd->{qCorrectDirectory}\/ ");
	system("mv GMP.tbl $cmd->{qCorrectDirectory}\/ ");				

	return $cmd;
}


# This subroutine writes the event processing specific information to a sqlite database,
# which is read by the seismotoolbox website to render the event specific pages
sub writeDB{
	(my $cmd) = @_;
	my $dbh = DBI->connect(          
		"dbi:SQLite:dbname=ars.db", 
		"",		# No Username required
		"",		# No Password required
		{ RaiseError => 1}
	) or die $DBI::errstr;

$dbh->do("CREATE TABLE IF NOT EXISTS `events` (
  `id`  INTEGER PRIMARY KEY ,
  `process_time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  `year` int(11) NOT NULL,
  `month` int(11) NOT NULL,
  `day` int(11) NOT NULL,
  `hr` int(11) NOT NULL,
  `min` int(11) NOT NULL,
  `sec` int(11) NOT NULL,
  `lat` double,
  `lon` double,
  `depth` double,
  `m_reported` double,
  `m_estimated` double,
  `stress` int(11),
  `qcorrect_dir` text NOT NULL,
  `shakemap` int(11),
  `show_on_toolbox` int(11) default '1',
  `scenario` int(11) default '0'
)");

$dbh->do('INSERT INTO events (year, month, day, hr, min, sec, lat, lon, depth, m_reported, m_estimated, stress, qcorrect_dir, shakemap,scenario ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)',
undef,
$cmd->{year}, $cmd->{month}, $cmd->{day}, $cmd->{hour}, $cmd->{minute}, $cmd->{second}, $cmd->{latitude}, $cmd->{longitude}, $cmd->{depth}, $cmd->{magnitude}, $cmd->{Mw}, $cmd->{stress}, $cmd->{qCorrectDirectory}, !$cmd->{noShakemap}, $cmd->{scenario});

$dbh->disconnect();
	
}



#Gets current date and time. Leaving it unchanged as Karen used it,
#but i suggest the use of UNIX command `date` instead, as it is only used for logging.
sub curtim{
    my @dt=localtime;
    $dt[5]+=1900;
    my $datetime=sprintf "%4d\/%02d\/%02d %02d:%02d:%02d", reverse(@dt[0..5]);
    return $datetime;
}


sub write2log{
	(my $text) = @_;

	my $elapsed_time = Time::HiRes::tv_interval($start_time);

	my $now = localtime(time);
	open (LOG, ">>ars.log");
	print LOG "$now\t$text\, took $elapsed_time secs\n";
	close (LOG)
}


sub log10 {
	my $n = shift;
	return log($n)/log(10);
}
