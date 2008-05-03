#!/bin/sh

if test grep -c " #FREENET AUTOSTART - 8888$" -gt 0
then
	echo Found service in crontab, removing it...
	crontab -l | grep -v " #FREENET AUTOSTART - 8888$" | crontab -
fi
