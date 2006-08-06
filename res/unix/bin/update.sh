#!/bin/bash
WHEREAMI="$(pwd)"
cd @path@
echo "Updating freenet"

# Attempt to use the auto-fetcher code, which will check the sha1sums.

if [[ "$1" != "debug" ]]
then
	THEMASK="-o /dev/null"
fi

# see https://bugs.freenetproject.org/view.php?id=223
# we can't afford a valid non-selfsigned SSL certificate :/
if [[ $(wget --version | head -n1 | cut -d" " -f3 | cut -d"." -f2) -ge 10 ]]
then
    NOCERT="--no-check-certificate "
fi

if [[ ! -x "$(which wget)" ]]
then
	WGET=0
	DOWNLOADER="curl --insecure -q -f -L -O "
	DOWNLOADER2="curl --insecure -q -f -L -O http://downloads.freenetproject.org/alpha/freenet-stable-latest.jar"
	DOWNLOADER3="curl --insecure -q -f -L -O "
else
	WGET=1
	DOWNLOADER="wget $THEMASK -N "
	DOWNLOADER2="wget $THEMASK -N -i freenet-stable-latest.jar.url"
	DOWNLOADER3="wget $THEMASK -N -O update2.sh $NOCERT "
fi

if [[ ! -s sha1test.jar ]]
then
	for x in 1 2 3 4 5
	do
		echo Downloading sha1test.jar utility jar which will download the actual update.
		if [[ $WGET -eq 1 ]]
		then
			$DOWNLOADER $NOCERT https://emu.freenetproject.org/sha1test.jar
		else
			$DOWNLOADER https://emu.freenetproject.org/sha1test.jar
		fi
		
		if [[ -s sha1test.jar ]]
		then
			break
		fi
	done
	if [[ ! -s sha1test.jar ]]
	then
		echo Could not download Sha1Test. The servers may be offline?
		exit
	fi
fi

cp freenet-stable-latest.jar freenet-stable-latest.jar.old
cp freenet-ext.jar freenet-ext.jar.old

if java -cp sha1test.jar Sha1Test freenet-stable-latest.jar
then
	echo Downloaded freenet-stable-latest.jar
else
	echo Could not download new freenet-stable-latest.jar.
	exit
fi

if java -cp sha1test.jar Sha1Test freenet-ext.jar
then
	echo Downloaded freenet-ext.jar
else
	echo Could not download new freenet-ext.jar.
	exit
fi

if [[ ! -x "$(which cmp)" ]]
then
	if [[ ! -x "$(which md5sum)" ]]
	then
		echo No cmp or md5sum utility detected
		echo Restarting the node as we cannot tell whether we need to.
		./run.sh restart
	else
		echo hmmm
		if [[ "$(md5sum freenet-stable-latest.jar)" != "$(md5sum freenet-stable-latest.jar.old)" ]]
		then
			echo Restarting node because freenet-stable-latest.jar updated.
			./run.sh restart
		elif [[ "$(md5sum freenet-ext.jar)" != "$(md5sum freenet-ext.jar.old)" ]]
		then
			echo Restarting node because freenet-ext.jar updated.
			./run.sh restart
		fi
	fi
else
	if cmp freenet-stable-latest.jar freenet-stable-latest.jar.old && cmp freenet-ext.jar freenet-ext.jar.old
	then
		echo Your node is up to date
	else
		echo Restarting node because freenet-stable-latest.jar or freenet-ext.jar updated.
		./run.sh restart
	fi
fi

$DOWNLOADER3 https://emu.freenetproject.org/svn/trunk/apps/installer/installclasspath/linux/update.sh
touch update.sh update2.sh
diff --brief update.sh update2.sh
if [[ $? -ne 0 ]]
then
	LOCATION="$(pwd | sed -e 's/\//\\\//g')"
	# we need to escape it, thanks to the_JinX for the hack
	WHAT="@pa"
	WHAT2="th@"
	if [[ $WGET -eq 0 ]]
	then
		cp update.sh update2.sh
	fi
	cat update2.sh |sed "s/$WHAT$WHAT2/$LOCATION/" > update.sh
	chmod +x update.sh
fi

cd $WHEREAMI
