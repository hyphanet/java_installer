#!/bin/sh

if test `crontab -l 2>/dev/null | grep -c " #FREENET AUTOSTART - 8888"` -gt 0
then
	echo Found service in crontab, removing it...
	crontab -l 2>/dev/null | grep -v " #FREENET AUTOSTART - 8888" | crontab -
fi
