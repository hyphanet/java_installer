#!/bin/sh
WHEREAMI="`pwd`"
JOPTS="-Djava.net.preferIPv4Stack=true"
echo "Updating freenet"

# Attempt to use the auto-fetcher code, which will check the sha1sums.

if test "$#" -gt 0
then
	if test "$1" = "testing"
	then
		RELEASE="testing"
		echo "WARNING! you're downloading an UNSTABLE snapshot version of freenet."
	else
		RELEASE="stable"
	fi
else
	RELEASE="stable"
fi

# We need to download the jars to temporary locations, check whether they are different,
# and if necessary shutdown the node before replacing, because java may do wierd things
# otherwise.

mkdir -p download-temp

if test -d download-temp
then
	echo Created temporary download directory.
else
	echo Could not create temporary download directory.
	exit
fi

# see https://bugs.freenetproject.org/view.php?id=223
# we can't afford a valid non-selfsigned SSL certificate :/
if test `wget --version | head -n1 | cut -d" " -f3 | cut -d"." -f2` -ge 10
then
    NOCERT="--no-check-certificate "
fi

if test ! -x "`which wget`"
then
	WGET=0
	DOWNLOADER="curl --insecure -q -f -L -O "
else
	WGET=1
	DOWNLOADER="wget -o /dev/null -N "
fi

if test ! -s sha1test.jar
then
	for x in 1 2 3 4 5
	do
		echo Downloading sha1test.jar utility jar which will download the actual update.
		if test $WGET -eq 1
		then
			$DOWNLOADER $NOCERT http://get.freenetproject.org/sha1test.jar
		else
			$DOWNLOADER http://get.freenetproject.org/sha1test.jar
		fi
		
		if test -s sha1test.jar
		then
			break
		fi
	done
	if test ! -s sha1test.jar
	then
		echo Could not download Sha1Test. The servers may be offline?
		exit
	fi
fi

if java $JOPTS -cp sha1test.jar Sha1Test update/update.sh
then
	echo "Downloaded update.sh"
	chmod +x update.sh

	touch update.sh update2.sh
	if cmp update.sh update2.sh >/dev/null 2>&1
	then
		echo "Your update.sh is up to date"
	else
		cp update.sh update2.sh
		exec ./update.sh $RELEASE
		exit
	fi
else
	echo "Could not download new update.sh."
	exit
fi

if java $JOPTS -cp sha1test.jar Sha1Test freenet-$RELEASE-latest.jar download-temp
then
	echo Downloaded freenet-$RELEASE-latest.jar
else
	echo Could not download new freenet-$RELEASE-latest.jar.
	exit
fi

if java $JOPTS -cp sha1test.jar Sha1Test freenet-ext.jar download-temp
then
	echo Downloaded freenet-ext.jar
else
	echo Could not download new freenet-ext.jar.
	exit
fi

cat wrapper.conf | sed 's/freenet-cvs-snapshot/freenet/g' | sed 's/freenet-stable-latest/freenet/g' | sed 's/freenet.jar.new/freenet.jar/g' | sed 's/freenet-ext.jar.new/freenet-ext.jar/g' > wrapper2.conf
mv wrapper2.conf wrapper.conf

if test ! -x "`which cmp`"
then
	if test ! -x "`which md5sum`"
	then
		echo No cmp or md5sum utility detected
		echo Restarting the node as we cannot tell whether we need to.
		./run.sh stop
		mv download-temp/freenet-$RELEASE-latest.jar freenet-$RELEASE-latest.jar
		rm freenet.jar
		ln -s freenet-$RELEASE-latest.jar freenet.jar
		mv download-temp/freenet-ext.jar freenet-ext.jar
		./run.sh start
	else
		if test "`md5sum freenet.jar | cut -d ' ' -f1`" != "`md5sum download-temp/freenet-$RELEASE-latest.jar | cut -d ' ' -f1`"
		then
			echo Restarting node because freenet-$RELEASE-latest.jar updated.
			./run.sh stop
			mv download-temp/freenet-$RELEASE-latest.jar freenet-$RELEASE-latest.jar
			rm freenet.jar
			ln -s freenet-$RELEASE-latest.jar freenet.jar
			mv download-temp/freenet-ext.jar freenet-ext.jar
			./run.sh start
		elif test "`md5sum freenet-ext.jar | cut -d ' ' -f 1`" != "`md5sum download-temp/freenet-ext.jar | cut -d ' ' -f1`"
		then
			echo Restarting node because freenet-ext.jar updated.
			./run.sh stop
			mv download-temp/freenet-ext.jar freenet-ext.jar
			./run.sh restart
		else
			echo Your node is up to date.
		fi
	fi
else
	if cmp freenet.jar download-temp/freenet-$RELEASE-latest.jar
	then
		# freenet.jar is up to date
		if cmp download-temp/freenet-ext.jar freenet-ext.jar
		then
			echo Your node is up to date
		else
			echo Restarting node because freenet-ext.jar updated.
			./run.sh stop
			mv download-temp/freenet-ext.jar freenet-ext.jar
			./run.sh start
		fi
	else
		echo Restarting node because freenet-$RELEASE-latest.jar updated
		./run.sh stop
		mv download-temp/freenet-$RELEASE-latest.jar freenet-$RELEASE-latest.jar
		rm freenet.jar
		ln -s freenet-$RELEASE-latest.jar freenet.jar
		mv download-temp/freenet-ext.jar freenet-ext.jar
		./run.sh start
	fi
fi

rm -f download-temp/freenet-$RELEASE-latest.jar* download-temp/freenet-ext.jar*
rmdir download-temp

cd $WHEREAMI
