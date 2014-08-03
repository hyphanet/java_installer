#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0

cd "$INSTALL_PATH"

# Some distros, such as Gentoo, have a script for Java on the path.
if ! readelf -h "`which java`" > /dev/null 2>&1 && readelf -h "/etc/java-config-2/current-system-vm/bin/java" > /dev/null 2>&1; then
	echo "The Java on the path is not an executable; setting Java command to underlying executable."
	sed -i "s/^wrapper.java.command=.*$/wrapper.java.command=\/etc\/java-config-2\/current-system-vm\/bin\/java/" wrapper.conf
fi
