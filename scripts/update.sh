#!/bin/sh

# help output
if test "$#" -gt 0
then
	if test "$1" = "--help"
		then echo "freenet update script."
		echo "Usage: ./update.sh [--help] [testing]"
		exit
	fi
fi

WHEREAMI="`pwd`"
CAFILE="startssl.pem"
JOPTS="-Djava.net.preferIPv4Stack=true"
SHA1_Sha1Test="ec6877a2551065d954e44dc6e78502bfe1fe6015"
echo "Updating freenet"

# Set working directory to Freenet install directory so that the script can
# work when started from elsewhere.
installation_dir=`dirname "$0"`
cd "$installation_dir"

if test -x pre-update.sh
then
	echo "Running the pre-update script:"
	./pre-update.sh
	echo "Returning from the pre-update script"
fi

invert_return_code () {
        $*
        if test $? -ne 0
        then
                return 0
        else
                return 1
        fi
}

# Test if two files exist: return 0 if they *both* exist
file_exist () {
	if test -n "$1" -a -n "$2"
	then
		if test -f "$1" -a -f "$2"
		then
			return 0
		fi
	fi

	return 1
}

# Return the hash of a file in the HASH variable
file_hash () {
	if test -n "$1" -a -f "$1"
	then
		HASH="`openssl md5 -sha1 \"$1\" | awk '{print $2;}'`"
	else
		HASH="NOT FOUND"
	fi
}

# Two functions used to compare files: return 0 if it matches
file_comp () {
	if file_exist "$1" "$2"
	then
		file_hash "$1"
		HASH_FILE1="$HASH"
		file_hash "$2"
		HASH_FILE2="$HASH"
		test "$HASH_FILE1" = "$HASH_FILE2"
		return
	else
		return 1
	fi
}

if test ! -x "`which openssl`"
then
	echo "No openssl utility detected; Please install it"
	exit 1
fi

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
	cp -f freenet-$RELEASE-latest.jar freenet-ext.jar freenet-$RELEASE-latest.jar.sha1 freenet-ext.jar.sha1 download-temp
else
	echo Could not create temporary download directory.
	exit
fi

# Bundle the CA
if test ! -f $CAFILE
then
# Delete the existing sha1test.jar: we want a new one to be downloaded
rm -f sha1test.jar
fi
cat >$CAFILE << EOF
-----BEGIN CERTIFICATE-----
MIIDdTCCAl2gAwIBAgILBAAAAAABFUtaw5QwDQYJKoZIhvcNAQEFBQAwVzELMAkG
A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jv
b3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw05ODA5MDExMjAw
MDBaFw0yODAxMjgxMjAwMDBaMFcxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
YWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYDVQQDExJHbG9iYWxT
aWduIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDaDuaZ
jc6j40+Kfvvxi4Mla+pIH/EqsLmVEQS98GPR4mdmzxzdzxtIK+6NiY6arymAZavp
xy0Sy6scTHAHoT0KMM0VjU/43dSMUBUc71DuxC73/OlS8pF94G3VNTCOXkNz8kHp
1Wrjsok6Vjk4bwY8iGlbKk3Fp1S4bInMm/k8yuX9ifUSPJJ4ltbcdG6TRGHRjcdG
snUOhugZitVtbNV4FpWi6cgKOOvyJBNPc1STE4U6G7weNLWLBYy5d4ux2x8gkasJ
U26Qzns3dLlwR5EiUWMWea6xrkEmCMgZK9FGqkjWZCrXgzT/LCrBbBlDSgeF59N8
9iFo7+ryUp9/k5DPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0B
AQUFAAOCAQEA1nPnfE920I2/7LqivjTFKDK1fPxsnCwrvQmeU79rXqoRSLblCKOz
yj1hTdNGCbM+w6DjY1Ub8rrvrTnhQ7k4o+YviiY776BQVvnGCv04zcQLcFGUl5gE
38NflNUVyRRBnMRddWQVDf9VMOyGj/8N7yy5Y0b2qvzfvGn9LhJIZJrglfCm7ymP
AbEVtQwdpf5pLGkkeB6zpxxxYu7KyJesF12KwvhHhm4qxFYxldBniYUr+WymXUad
DKqC5JlR3XC321Y9YeRq4VzW9v493kHMB65jUr9TU/Qr6cf9tveCX4XSQRjbgbME
HMUfpIBvFSDJ3gyICh3WZlXi/EjJKSZp4A==
-----END CERTIFICATE-----
EOF

if test -x "`which curl`"
then
	# Pin the certificate file.
	# Curl will use the system --capath if we don't specify one.
	# FIXME --capath / is safe (there shouldn't be any certs in it, regular users can't write to it, etc), /var/empty would be more obvious but might break if some future curl checks existence?
	DOWNLOADER="curl --capath / --cacert $CAFILE -q -f -L -O "
else
	DOWNLOADER="wget -o /dev/null --ca-certificate $CAFILE -N "
fi

# check if sha1sum.jar is up to date
file_hash sha1test.jar
case "$HASH" in 
	$SHA1_Sha1Test) echo "The SHA1 of sha1test.jar matches";;
	*) echo "sha1test.jar needs to be updated"; rm -f sha1test.jar;;
esac

if test ! -s sha1test.jar
then
	for x in 1 2 3 4 5
	do
		echo Downloading sha1test.jar utility jar which will download the actual update.
		$DOWNLOADER https://downloads.freenetproject.org/latest/sha1test.jar
		
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

if java $JOPTS -cp sha1test.jar Sha1Test update.sh ./ $CAFILE
then
	echo "Downloaded update.sh"
	chmod +x update.sh

	touch update.sh update2.sh
	if file_comp update.sh update2.sh >/dev/null
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

if java $JOPTS -cp sha1test.jar Sha1Test freenet-$RELEASE-latest.jar download-temp $CAFILE
then
	echo Downloaded freenet-$RELEASE-latest.jar
else
	echo Could not download new freenet-$RELEASE-latest.jar.
	exit
fi

if java $JOPTS -cp sha1test.jar Sha1Test freenet-ext.jar download-temp $CAFILE
then
	echo Downloaded freenet-ext.jar
else
	echo Could not download new freenet-ext.jar.
	exit
fi

if test ! -s bcprov-jdk15on-154.jar
then
	echo Downloading bcprov-jdk15on-154.jar
	if ! java $JOPTS -cp sha1test.jar Sha1Test bcprov-jdk15on-154.jar . $CAFILE
	then
		echo Could not download bcprov-jdk15on-154.jar needed for new jar
		exit
	fi
fi

if test ! -s wrapper.jar
then
	echo Downloading wrapper.jar
	if ! java $JOPTS -cp sha1test.jar Sha1Test wrapper.jar . $CAFILE
	then
		echo Could not download wrapper.jar needed for new jar
		exit
	fi
fi

dos2unix wrapper.conf > /dev/null 2>&1

# Make sure the new files will be used (necessary to prevent 
# the node's auto-update to play us tricks)
cat wrapper.conf | \
	sed 's/freenet-cvs-snapshot/freenet/g' | \
	sed 's/freenet-stable-latest/freenet/g' | \
	sed 's/freenet.jar.new/freenet.jar/g' | \
	sed 's/freenet-ext.jar.new/freenet-ext.jar/g' \
	> wrapper2.conf
mv wrapper2.conf wrapper.conf

if ! grep bcprov-jdk15on-154.jar wrapper.conf > /dev/null
then
	if grep bcprov-jdk15on wrapper.conf > /dev/null; then
		echo Updating wrapper.conf to bouncycastle 1.54
		cat wrapper.conf | sed 's/bcprov-jdk15on-[0-9]*/bcprov-jdk15on-154/g' > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	else
		echo Adding bcprov-jdk15on-154.jar to wrapper.conf
		echo "wrapper.java.classpath.3=bcprov-jdk15on-154.jar" >> wrapper.conf
	fi
else
	echo wrapper.conf contains up to date bouncycastle jar v1.54
	if grep bcprov-jdk15on-147.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 147 and 154, deleting 147
		cat wrapper.conf | sed "/bcprov-jdk15on-147/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
	if grep bcprov-jdk15on-149.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 149 and 154, deleting 149
		cat wrapper.conf | sed "/bcprov-jdk15on-149/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
	if grep bcprov-jdk15on-151.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 151 and 154, deleting 151
		cat wrapper.conf | sed "/bcprov-jdk15on-151/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
	if grep bcprov-jdk15on-152.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 152 and 154, deleting 152
		cat wrapper.conf | sed "/bcprov-jdk15on-152/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
fi

if ! grep wrapper.jar wrapper.conf > /dev/null
then
	echo Adding wrapper.jar to wrapper.conf
	if (((echo wrapper.jar; cat wrapper.conf | grep "wrapper.java.classpath." | sed "s/^wrapper.java.classpath.[0-9]*=//") | (y=0; while read x; do y=$((y+1)); echo "wrapper.java.classpath.$y=$x"; done); cat wrapper.conf | sed "/wrapper.java.classpath.[0-9]*=/d") > wrapper.conf.new) && mv wrapper.conf.new wrapper.conf
	then
		echo Successfully added wrapper.jar to wrapper.conf
	else
		echo Failed to update your wrapper.conf
		echo Please manaully add wrapper.java.classpath.1=wrapper.jar to the beginning of your wrapper.conf and renumber the other similar lines
		echo Then re-run the script.
		echo This might be caused by not having sed installed
		exit 
	fi
fi
	

if ! file_exist freenet-ext.jar freenet-$RELEASE-latest.jar
then
	cp download-temp/freenet-*.jar* .
	rm -f freenet.jar
	ln -s freenet-$RELEASE-latest.jar freenet.jar
fi

if invert_return_code file_comp freenet.jar download-temp/freenet-$RELEASE-latest.jar >/dev/null
then
	echo Restarting node because freenet-$RELEASE-latest.jar updated.
	./run.sh stop
	cp download-temp/*.jar download-temp/*.sha1 .
	rm freenet.jar
	ln -s freenet-$RELEASE-latest.jar freenet.jar
	./run.sh start
elif invert_return_code file_comp freenet-ext.jar download-temp/freenet-ext.jar >/dev/null
then
	echo Restarting node because freenet-ext.jar updated.
	./run.sh stop
	cp download-temp/freenet-ext.jar* .
	rm freenet.jar
	./run.sh restart
else
	echo Your node is up to date.
fi

rm -rf download-temp

cd $WHEREAMI
