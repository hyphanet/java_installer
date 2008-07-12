#!/bin/sh

INSTALL_PATH="${INSTALL_PATH:-$PWD}"
CAFILE="$INSTALL_PATH/startssl.pem"
JOPTS=" -Djava.net.preferIPv4Stack=true "
OS="`uname -s`"

cd "$INSTALL_PATH"

rm -f "$HOME/_install_toSource.sh"
if test -e "$HOME/_install_toSource.sh"
then
	echo "Please delete the freenet directory and the file \"$HOME/_install_toSource.sh\" before restarting the installer."
	touch .isInstalled
	exit 0
fi

echo '#!/bin/sh' > "$HOME/_install_toSource.sh"
echo INSTALL_PATH=\"$INSTALL_PATH\" >> "$HOME/_install_toSource.sh"
echo CAFILE=\"$CAFILE\" >> "$HOME/_install_toSource.sh"
echo JOPTS=\"$JOPTS\" >> "$HOME/_install_toSource.sh"
echo ISO3_LANG=\"$ISO3_LANG\" >> "$HOME/_install_toSource.sh"
echo "if test -f \"$INSTALL_PATH/.isInstalled\"; then exit 1; fi" >> "$HOME/_install_toSource.sh"
chmod 755 "$HOME/_install_toSource.sh"
alias .=

if test -s freenet.ini
then
	echo "The installer isn\'t meant to run more than once in the same directory"
	touch .isInstalled
	rm -f "$HOME/_install_toSource.sh"
	exit 0
fi

if test "X`id -u`" = "X0"
then
	echo "The installer isn\'t meant to be run as root"
	touch .isInstalled
	rm -f "$HOME/_install_toSource.sh"
	exit 0
fi

# Hack to use a generic template for plugins
touch plug

# Are we in offline mode ?
if test -e offline
then
	echo "Offline installation mode"
else
	echo "Online installation mode"
	echo "Downloading the wrapper binaries"
	java $JOPTS -jar bin/sha1test.jar wrapper_$OS.zip . "$CAFILE" 2>jvmerror >/dev/null
fi

if test -s jvmerror 
then
	echo "#################################################################"
	echo "It seems that you are using a buggy JVM..."
	echo "The installer will refuse to run until you switch to a decent one"
	echo "#################################################################"
	echo "You are currently using:"
	java -version
	echo "#################################################################"
	echo "The full error message is :"
	echo "#################################################################"
	cat jvmerror
	touch .isInstalled
	rm -f "$HOME/_install_toSource.sh"
	exit 0
fi
rm -f jvmerror

java $JOPTS -jar bin/uncompress.jar wrapper_$OS.zip . 2>&1 >/dev/null
# We need the exec flag on /bin
chmod u+x bin/* lib/*
