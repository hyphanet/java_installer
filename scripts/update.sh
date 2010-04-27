#!/bin/sh
WHEREAMI="`pwd`"
CAFILE="startssl.pem"
JOPTS="-Djava.net.preferIPv4Stack=true"
SHA1_Sha1Test="16bfa2d0e1f8bd7b2be79b2c26d88f47ea2164ca"
echo "Updating freenet"

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
cat >$CAFILE << EOF
-----BEGIN CERTIFICATE-----
MIIHyTCCBbGgAwIBAgIBATANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQGEwJJTDEW
MBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNh
dGlvbiBBdXRob3JpdHkwHhcNMDYwOTE3MTk0NjM2WhcNMzYwOTE3MTk0NjM2WjB9
MQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMi
U2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3Rh
cnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUA
A4ICDwAwggIKAoICAQDBiNsJvGxGfHiflXu1M5DycmLWwTYgIiRezul38kMKogZk
pMyONvg45iPwbm2xPN1yo4UcodM9tDMr0y+v/uqwQVlntsQGfQqedIXWeUyAN3rf
OQVSWff0G0ZDpNKFhdLDcfN1YjS6LIp/Ho/u7TTQEceWzVI9ujPW3U3eCztKS5/C
Ji/6tRYccjV3yjxd5srhJosaNnZcAdt0FCX+7bWgiA/deMotHweXMAEtcnn6RtYT
Kqi5pquDSR3l8u/d5AGOGAqPY1MWhWKpDhk6zLVmpsJrdAfkK+F2PrRt2PZE4XNi
HzvEvqBTViVsUQn3qqvKv3b9bZvzndu/PWa8DFaqr5hIlTpL36dYUNk4dalb6kMM
Av+Z6+hsTXBbKWWc3apdzK8BMewM69KN6Oqce+Zu9ydmDBpI125C4z/eIT574Q1w
+2OqqGwaVLRcJXrJosmLFqa7LH4XXgVNWG4SHQHuEhANxjJ/GP/89PrNbpHoNkm+
Gkhpi8KWTRoSsmkXwQqQ1vp5Iki/untp+HDH+no32NgN0nZPV/+Qt+OR0t3vwmC3
Zzrd/qqc8NSLf3Iizsafl7b4r4qgEKjZ+xjGtrVcUjyJthkqcwEKDwOzEmDyei+B
26Nu/yYwl/WL3YlXtq09s68rxbd2AvCl1iuahhQqcvbjM4xdCUsT37uMdBNSSwID
AQABo4ICUjCCAk4wDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAa4wHQYDVR0OBBYE
FE4L7xqkQFulF2mHMMo0aEPQQa7yMGQGA1UdHwRdMFswLKAqoCiGJmh0dHA6Ly9j
ZXJ0LnN0YXJ0Y29tLm9yZy9zZnNjYS1jcmwuY3JsMCugKaAnhiVodHRwOi8vY3Js
LnN0YXJ0Y29tLm9yZy9zZnNjYS1jcmwuY3JsMIIBXQYDVR0gBIIBVDCCAVAwggFM
BgsrBgEEAYG1NwEBATCCATswLwYIKwYBBQUHAgEWI2h0dHA6Ly9jZXJ0LnN0YXJ0
Y29tLm9yZy9wb2xpY3kucGRmMDUGCCsGAQUFBwIBFilodHRwOi8vY2VydC5zdGFy
dGNvbS5vcmcvaW50ZXJtZWRpYXRlLnBkZjCB0AYIKwYBBQUHAgIwgcMwJxYgU3Rh
cnQgQ29tbWVyY2lhbCAoU3RhcnRDb20pIEx0ZC4wAwIBARqBl0xpbWl0ZWQgTGlh
YmlsaXR5LCByZWFkIHRoZSBzZWN0aW9uICpMZWdhbCBMaW1pdGF0aW9ucyogb2Yg
dGhlIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5IFBvbGljeSBhdmFp
bGFibGUgYXQgaHR0cDovL2NlcnQuc3RhcnRjb20ub3JnL3BvbGljeS5wZGYwEQYJ
YIZIAYb4QgEBBAQDAgAHMDgGCWCGSAGG+EIBDQQrFilTdGFydENvbSBGcmVlIFNT
TCBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTANBgkqhkiG9w0BAQUFAAOCAgEAFmyZ
9GYMNPXQhV59CuzaEE44HF7fpiUFS5Eyweg78T3dRAlbB0mKKctmArexmvclmAk8
jhvh3TaHK0u7aNM5Zj2gJsfyOZEdUauCe37Vzlrk4gNXcGmXCPleWKYK34wGmkUW
FjgKXlf2Ysd6AgXmvB618p70qSmD+LIU424oh0TDkBreOKk8rENNZEXO3SipXPJz
ewT4F+irsfMuXGRuczE6Eri8sxHkfY+BUZo7jYn0TZNmezwD7dOaHZrzZVD1oNB1
ny+v8OqCQ5j4aZyJecRDjkZy42Q2Eq/3JR44iZB3fsNrarnDy0RLrHiQi+fHLB5L
EUTINFInzQpdn4XBidUaePKVEFMy3YCEZnXZtWgo+2EuvoSoOMCZEoalHmdkrQYu
L6lwhceWD3yJZfWOQ1QOq92lgDmUYMA0yZZwLKMS9R9Ie70cfmu3nZD0Ijuu+Pwq
yvqCUqDvr0tVk+vBtfAii6w0TiYiBKGHLHVKt+V9E9e4DGTANtLJL4YSjCMJwRuC
O3NJo2pXh5Tl1njFmUNj403gdy3hZZlyaQQaRwnmDwFWJPsfvw55qVguucQJAX6V
um0ABj6y6koQOdjQK/W/7HW/lwLFCRsI3FU34oH7N4RDYiDK51ZLZer+bMEkkySh
NOsF/5oirpt9P/FlUQqmMGqz9IgcgA38corog14=
-----END CERTIFICATE-----
EOF
fi

if test -x "`which curl`"
then
	DOWNLOADER="curl --cacert $CAFILE -q -f -L -O "
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
		$DOWNLOADER https://checksums.freenetproject.org/latest/sha1test.jar
		
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

# Make sure the new files will be used (necessary to prevent 
# the node's auto-update to play us tricks)
cat wrapper.conf | \
	sed 's/freenet-cvs-snapshot/freenet/g' | \
	sed 's/freenet-stable-latest/freenet/g' | \
	sed 's/freenet.jar.new/freenet.jar/g' | \
	sed 's/freenet-ext.jar.new/freenet-ext.jar/g' \
	> wrapper2.conf
mv wrapper2.conf wrapper.conf

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
