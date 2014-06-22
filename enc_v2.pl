use warnings;
use Net::IMAP::Simple::SSL;
use Email::Simple;
use Email::MIME::Encodings;
use Net::FTP::Recursive;
use YAML::Tiny;
use Net::SMTP::SSL;
use MIME::Entity;
use MIME::QuotedPrint;
use Date::Parse;
use Date::Format;


# Read configuration file:
my $yaml = YAML::Tiny->read( 'qkresp.cfg' );

# Connect to mail server:
my $imap = Net::IMAP::Simple::SSL->new($yaml->[0]->{smtps}) or die "Didn\'t connect to server";
#my $imap = Net::IMAP::Simple::SSL->new($yaml->[0]->{smtps}) or die "Didn\'t connect to server, problem: $Net::IMAP::Simple::SSL::errstr\n";

# Log in to mail account:
my $gotin = $imap->login($yaml->[0]->{kuser},$yaml->[0]->{kpass}) or die "Didn\'t open mailbox, problem: " . $imap->errstr . "\n";

# Select specified folder containing messages of interest:
my $nm=$imap->select('GSC_notification') or die "Didn\'t select folder, problem: " . $imap->errstr . "\n";

# Count the total number of messages in the folder:
my $num_messages = $imap->status('GSC_notification');

# Find unseen message numbers:
my @ids=$imap->search("UNSEEN");

# Don't need to print the number of messages to the log. -Arpit
#print "$num_messages @ids\n";

# If there are 
if(scalar @ids > 0)
      {
      foreach $e_id (@ids)
            {
            my @datetime=(0)x6;
            my @coord=(0)x3;
            my $mag=0;
            my @message = $imap->get($e_id);
            my $tmp_email=join '',@message;
            my $email=Email::Simple->new($tmp_email);
            $body=$email->body;
            $body=decode_qp($body);
            my @lines=split /\n/,$body; 
            my @lines_rng;
            foreach $count (0..scalar @lines -1)
                {
                if ($lines[$count] eq $lines[0])
                    {
                    push @lines_rng, $count;
                    }
                }
            if (scalar @lines_rng ==1) {push @lines_rng, scalar @lines};
            foreach ($lines_rng[0]..$lines_rng[1]-1)
                {
                if ($lines[$_] =~ m/date\W*?(\d{1,4})\/(\d{1,2})\/(\d{1,2})/i)
                    {
                    @datetime[0..2] = ($1, $2, $3);
                    }
                if ($lines[$_] =~ m/time\W*?(\d{1,4}):(\d{1,2}):(\d{1,2})/i)
                    {
                    @datetime[3..5] = ($1, $2, $3);
                    }
                if ($lines[$_] =~ m/latitude\W*?(\d*\.\d*)/i)
                    {
                    $coord[0]= $1;
                    }
                if ($lines[$_] =~ m/longitude\W*?(\d*\.\d*)/i)
                    {
                    $coord[1]= $1;
                    }
                if ($lines[$_] =~ m/magnitude\W*?(\d*\.\d*)/i)
                    {
                    $mag=$1;
                    }
                }
            $req_body=
                "begin\n".
                "date $datetime[0]\/$datetime[1]\/$datetime[2] \n".
                "time $datetime[3]:$datetime[4]:00 \n".
                "duration 240 \n".
                "latitude $coord[0]\n".
                "longitude -$coord[1]\n".
                "depth 10.0\n".
                "magnitude $mag\n".
                "recipient 3\n".
                "replace 1\n".
                "end";
            print "$req_body \n";

#           Send the email
            my $from = 'gsc@gsc.com';
#           my $to = 'karenassatourians@yahoo.com';
            my $to = 'toARS@ARS.com';
            my @cc;
            my $subject = 'Response to GSC Earthquake Notification';
            my $mime = MIME::Entity->build(Type  => 'multipart/alternative',
                 Encoding => '-SUGGEST',
                 From => $from,
                 To => $to,
                 Subject => $subject
                 );
            $mime->attach(Type => 'text/plain',
                 Encoding =>'-SUGGEST',
                 Data => $req_body);

#           Open a connection to the Gmail smtp server
            my $smtp = Net::SMTP::SSL->new('smtp.uwo.ca',
                 Port=> 465,
                 Timeout => 20);
#           Authenticate
            $smtp->auth( $yaml->[0]->{kuser}, $yaml->[0]->{kpass} );
#           Send the rest of the SMTP stuff to the server
            $smtp->mail($from);
            $smtp->to($to);
            $smtp->cc(@cc);
            $smtp->data($mime->stringify);
            $smtp->quit();
            }
      }
#
$imap->quit;
#
