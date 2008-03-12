#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"
cd "$INSTALL_PATH"

echo '#!/bin/sh' > _install_toSource.sh
echo INSTALL_PATH=\"$INSTALL_PATH\" >> _install_toSource.sh
echo JOPTS=\" -Djava.net.preferIPv4Stack=true \" >> _install_toSource.sh
chmod 755 _install_toSource.sh
alias .=

if test -s freenet.ini
then
	echo "This script isn't meant to be used more than once. I will rename your freenet.ini to freenet.old.ini and go on, but don't complain if it breaks\!"
	mv freenet.ini freenet.old.ini
fi

# Hack to use a generic template for plugins
touch plug

# We need the exec flag on /bin
chmod u+x bin/*sh bin/wrapper-* lib/* >/dev/null 2>&1

# Are we in offline mode ?
if test -e offline
then
	echo "Offline installation mode"
else
	echo "Online installation mode"
fi
