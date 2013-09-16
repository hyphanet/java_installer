#!/bin/bash
#. "$HOME/_install_toSource.sh" || exit 0
#cd "$INSTALL_PATH"
if test ! -f /etc/os-release; then exit; fi
source /etc/os-release
if test "$NAME" = "Gentoo" || test "$NAME" = "Arch Linux"; then
	echo Working around wrapper bug on Gentoo...
	sed -i "s/^wrapper.java.command=.*$/wrapper.java.command=\/etc\/java-config-2\/current-system-vm\/bin\/java/" wrapper.conf
fi
