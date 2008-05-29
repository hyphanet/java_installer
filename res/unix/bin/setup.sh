#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"
echo '#!/bin/sh' > "$HOME/_install_toSource.sh"
echo INSTALL_PATH=\"$INSTALL_PATH\" >> "$HOME/_install_toSource.sh"
echo JOPTS=\" -Djava.net.preferIPv4Stack=true \" >> "$HOME/_install_toSource.sh"
echo ISO3_LANG=\"$ISO3_LANG\" >> "$HOME/_install_toSource.sh"
echo "if test -f \"$INSTALL_PATH/.isInstalled\"; then exit 1; fi" >> "$HOME/_install_toSource.sh"
chmod 755 "$HOME/_install_toSource.sh"
alias .=

cd "$INSTALL_PATH"

if test -s freenet.ini
then
	echo "The installer isn\'t meant to run more than once in the same directory"
	touch .isInstalled
	exit 0
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
