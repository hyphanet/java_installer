#!/bin/sh

if test "X`id -u`" = "X0"
then
        echo "The installer isn\'t meant to be run as root"
	exit
fi

if test -f .isInstalled
then
	if test -s jvmerror
	then
		cat jvmerror
	fi
	echo "IllegalState: Delete the directory and re-unpack a fresh tarball"
fi

if test -s freenet.ini
then
	echo "This script isn\'t meant to be used more than once."
	rm -f bin/1run.sh
	exit
fi

if test ! -s bin/1run.sh
then
	echo 'This script should be started using ./bin/1run.sh!'
	exit
fi


CAFILE="startssl.pem"
JOPTS="-Djava.net.preferIPv4Stack=true"
OS="`uname -s`"

# Tweak freenet.ini before the first startup
echo "node.updater.enabled=true" > freenet.ini
echo "Enabling the auto-update feature"
echo "node.updater.autoupdate=true" >> freenet.ini

echo "Detecting tcp-ports availability..."
# Try to auto-detect the first available port for fproxy
FPROXY_PORT=8888
java -jar bin/bindtest.jar $FPROXY_PORT &>/dev/null
if test $? -ne 0
then
	FPROXY_PORT=8889
	echo "Can not bind fproxy to 8888: let's try $FPROXY_PORT instead."
	java -jar bin/bindtest.jar $FPROXY_PORT
	if test $? -ne 0
	then
		FPROXY_PORT=9999
		java -jar bin/bindtest.jar $FPROXY_PORT
		if test $? -ne 0
		then
			echo "Can not bind any socket on 127.0.0.1:"
			echo "		IT SHOULDN'T HAPPEN\!"
			echo ""
			echo "Make sure your loopback interface is properly configured. Delete Freenet\'s directory and retry."
			touch .isInstalled
			exit 1
		fi
	fi
fi
echo "fproxy.enabled=true" >> freenet.ini
echo "fproxy.port=$FPROXY_PORT" >> freenet.ini

# Try to auto-detect the first available port for fcp
FCP_PORT=9481
java -jar bin/bindtest.jar $FCP_PORT
if test $? -ne 0
then
	FCP_PORT=9482
	echo "Can not bind fcp to 9481: force it to $FCP_PORT instead."
fi
echo "fcp.enabled=true" >> freenet.ini
echo "fcp.port=$FCP_PORT" >> freenet.ini

echo "Downloading update.sh"
java $JOPTS -jar bin/sha1test.jar update.sh "." $CAFILE >/dev/null 2>jvmerror
if test -s jvmerror 
then
	echo "#################################################################"
	echo "It seems that you are using a buggy JVM..."
	echo "Most versions of OpenJDK, and most other fully open source Java implementations have bugs"
	echo "causing the installer to fail, and/or Freenet to break. Please install Sun Java 1.5 or 1.6"
	echo "to make the installer work. On ubuntu:"
	echo
	echo "apt-get install sun-java6-jre"
	echo "update-java-alternatives -s java-6-sun"
	echo "#################################################################"
	echo "You are currently using:"
	java -version
	echo "#################################################################"
	echo "The full error message is :"
	echo "#################################################################"
	cat jvmerror
	touch .isInstalled
	exit 1
fi
rm -f jvmerror
chmod a+rx "./update.sh"

echo "Downloading wrapper_$OS.zip"
java $JOPTS -jar bin/sha1test.jar wrapper_$OS.zip . "$CAFILE" > /dev/null
java $JOPTS -jar bin/uncompress.jar wrapper_$OS.zip . 2>&1 >/dev/null

# We need the exec flag on /bin
chmod u+x bin/* lib/*

echo "Downloading freenet-stable-latest.jar"
java $JOPTS -jar bin/sha1test.jar freenet-stable-latest.jar "." $CAFILE >/dev/null
ln -s freenet-stable-latest.jar freenet.jar
echo "Downloading freenet-ext.jar"
java $JOPTS -jar bin/sha1test.jar freenet-ext.jar "." $CAFILE >/dev/null

# Register plugins
mkdir -p plugins
echo "pluginmanager.loadplugin=JSTUN;UPnP" >> freenet.ini
echo "Downloading the JSTUN plugin"
java $JOPTS -jar bin/sha1test.jar JSTUN.jar plugins "$CAFILE" >/dev/null 2>&1
echo "Downloading the UPnP plugin"
java $JOPTS -jar bin/sha1test.jar UPnP.jar plugins "$CAFILE" >/dev/null 2>&1

echo "Downloading seednodes.fref"
java $JOPTS -jar bin/sha1test.jar seednodes.fref "." $CAFILE >/dev/null

if test -x `which crontab`
then
	echo "Installing cron job to start Freenet on reboot..."
	crontab -l 2>/dev/null > autostart.install
	echo "@reboot   \"$PWD/run.sh\" start 2>&1 >/dev/null #FREENET AUTOSTART - $FPROXY_PORT" >> autostart.install
	if crontab autostart.install
	then
		echo Installed cron job.
	fi
fi
cat bin/remove_cronjob.sh | sed "s/8888/$FPROXY_PORT/g" > remove_cronjob.sh
mv remove_cronjob.sh bin/remove_cronjob.sh

if test -s autostart.install
then
	rm -f autostart.install
else
	echo Cron appears not to be installed, you will have to run run.sh start manually to start Freenet after a reboot.
fi

# Starting the node up
./run.sh start

echo "Please visit http://127.0.0.1:$FPROXY_PORT/ to configure your node"
echo "Finished"

rm -f bin/1run.sh
touch .isInstalled
exit 0
