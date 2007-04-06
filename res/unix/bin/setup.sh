#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"

cd "$INSTALL_PATH"

if test -s freenet.ini
then
	echo "This script isn't meant to be used more than once. I will rename your freenet.ini to freenet.old.ini and go on, but don't complain if it breaks\!"
	mv freenet.ini freenet.old.ini
fi

# Hack to use a generic template for plugins
touch plug

# We need the exec flag on /bin
chmod u+x bin/*sh bin/wrapper-* lib/* &>/dev/null
