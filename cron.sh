#! /bin/bash

# See if the previous job is still running by the presense of lock file
if [ -f /home/eqk/ARS/lock.x ] ; then
	echo "..."
else
	# Create the lock file
  	echo 1 > /home/eqk/ARS/lock.x

	# Enable cpan minus for its module use
	eval `perl -I /home/eqk/perl5/lib/perl5 -Mlocal::lib`
  	cd /home/eqk/ARS/
 	# Define the PATH for the cronjob 	
	PATH=.:/home/eqk/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/eqk/bin:/usr/local/sac/bin
	# Run the script  	
        perl enc_v2.pl
	perl ars_v4.pl
        #perl ars_v3.pl
	#perl ars.pl
  	# Remove the lock file, to allow the next job
  	rm -f /home/eqk/ARS/lock.x
fi

