#!/bin/sh

crontab -l > crontab.tmp
if grep -F "@reboot   \"$INSTALL_PATH/run.sh\" start" crontab.tmp
then
	echo Found service in crontab, removing it...
	cat crontab.tmp | grep -v -F "@reboot   \"$INSTALL_PATH/run.sh\" start" - > crontab.tmp.new
	crontab crontab.tmp.new
fi
rm -f crontab.tmp crontab.tmp.new
