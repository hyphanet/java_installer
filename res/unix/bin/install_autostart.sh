#!/bin/sh

. "$HOME/_install_toSource.sh"
cd "$INSTALL_PATH"

# FIXME if we are running as root, and they are installed use the LSB utilities, with crontab as a fallback.
# See here: 
# http://refspecs.linux-foundation.org/LSB_3.2.0/LSB-Core-generic/LSB-Core-generic/initsrcinstrm.html
# http://refspecs.linux-foundation.org/LSB_3.2.0/LSB-Core-generic/LSB-Core-generic/useradd.html
if test -e autostart.install
then
	echo "Enabling auto-start."
	if test -x `which crontab`
	then
		echo "Installing cron job to start Freenet on reboot..."
		crontab -l > autostart.install
		echo "@reboot   \"$INSTALL_PATH/run.sh\" start 2>&1 >/dev/null #FREENET AUTOSTART - 8888" >> autostart.install
		if crontab autostart.install
		then
			echo Installed cron job.
		else
			echo Could not install cron job, you will have to run run.sh start manually to start Freenet after a reboot.
		fi
	else
		echo Cron appears not to be installed, you will have to run run.sh start manually to start Freenet after a reboot.
	fi
else
	echo Auto-start is disabled, you will have to run run.sh start manually to start Freenet after a reboot.
fi
rm -f autostart.install
