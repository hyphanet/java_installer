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

# avoid changing the running script (the shell sticks to the inode)
mv "$0" "$0".old && cp -p "$0".old "$0"

WHEREAMI="`pwd`"
CAFILE="startssl.pem"
JOPTS="-Djava.net.preferIPv4Stack=true"
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
		# echo "WARNING! you're downloading an UNSTABLE snapshot version of freenet."
		echo "ERROR! downloading testing versions is currently broken."
		exit 1
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
-----BEGIN CERTIFICATE-----
MIIDQTCCAimgAwIBAgITBmyfz5m/jAo54vB4ikPmljZbyjANBgkqhkiG9w0BAQsF
ADA5MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6
b24gUm9vdCBDQSAxMB4XDTE1MDUyNjAwMDAwMFoXDTM4MDExNzAwMDAwMFowOTEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv
b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj
ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM
9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw
IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6
VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L
93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm
jgSubJrIqg0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AYYwHQYDVR0OBBYEFIQYzIU07LwMlJQuCFmcx7IQTgoIMA0GCSqGSIb3DQEBCwUA
A4IBAQCY8jdaQZChGsV2USggNiMOruYou6r4lK5IpDB/G/wkjUu0yKGX9rbxenDI
U5PMCCjjmCXPI6T53iHTfIUJrU6adTrCC2qJeHZERxhlbI1Bjjt/msv0tadQ1wUs
N+gDS63pYaACbvXy8MWy7Vu33PqUXHeeE6V/Uq2V8viTO96LXFvKWlJbYK8U90vv
o/ufQJVtMVT8QtPHRh8jrdkPSHCa2XV4cdFyQzR1bldZwgJcJmApzyMZFo6IQ6XU
5MsI+yMRQ+hDKXJioaldXgjUkK642M4UwtBV8ob2xJNDd2ZhwLnoQdeXeGADbkpy
rqXRfboQnoZsG4q5WTP468SQvvG5
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIFQTCCAymgAwIBAgITBmyf0pY1hp8KD+WGePhbJruKNzANBgkqhkiG9w0BAQwF
ADA5MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6
b24gUm9vdCBDQSAyMB4XDTE1MDUyNjAwMDAwMFoXDTQwMDUyNjAwMDAwMFowOTEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv
b3QgQ0EgMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK2Wny2cSkxK
gXlRmeyKy2tgURO8TW0G/LAIjd0ZEGrHJgw12MBvIITplLGbhQPDW9tK6Mj4kHbZ
W0/jTOgGNk3Mmqw9DJArktQGGWCsN0R5hYGCrVo34A3MnaZMUnbqQ523BNFQ9lXg
1dKmSYXpN+nKfq5clU1Imj+uIFptiJXZNLhSGkOQsL9sBbm2eLfq0OQ6PBJTYv9K
8nu+NQWpEjTj82R0Yiw9AElaKP4yRLuH3WUnAnE72kr3H9rN9yFVkE8P7K6C4Z9r
2UXTu/Bfh+08LDmG2j/e7HJV63mjrdvdfLC6HM783k81ds8P+HgfajZRRidhW+me
z/CiVX18JYpvL7TFz4QuK/0NURBs+18bvBt+xa47mAExkv8LV/SasrlX6avvDXbR
8O70zoan4G7ptGmh32n2M8ZpLpcTnqWHsFcQgTfJU7O7f/aS0ZzQGPSSbtqDT6Zj
mUyl+17vIWR6IF9sZIUVyzfpYgwLKhbcAS4y2j5L9Z469hdAlO+ekQiG+r5jqFoz
7Mt0Q5X5bGlSNscpb/xVA1wf+5+9R+vnSUeVC06JIglJ4PVhHvG/LopyboBZ/1c6
+XUyo05f7O0oYtlNc/LMgRdg7c3r3NunysV+Ar3yVAhU/bQtCSwXVEqY0VThUWcI
0u1ufm8/0i2BWSlmy5A5lREedCf+3euvAgMBAAGjQjBAMA8GA1UdEwEB/wQFMAMB
Af8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQWBBSwDPBMMPQFWAJI/TPlUq9LhONm
UjANBgkqhkiG9w0BAQwFAAOCAgEAqqiAjw54o+Ci1M3m9Zh6O+oAA7CXDpO8Wqj2
LIxyh6mx/H9z/WNxeKWHWc8w4Q0QshNabYL1auaAn6AFC2jkR2vHat+2/XcycuUY
+gn0oJMsXdKMdYV2ZZAMA3m3MSNjrXiDCYZohMr/+c8mmpJ5581LxedhpxfL86kS
k5Nrp+gvU5LEYFiwzAJRGFuFjWJZY7attN6a+yb3ACfAXVU3dJnJUH/jWS5E4ywl
7uxMMne0nxrpS10gxdr9HIcWxkPo1LsmmkVwXqkLN1PiRnsn/eBG8om3zEK2yygm
btmlyTrIQRNg91CMFa6ybRoVGld45pIq2WWQgj9sAq+uEjonljYE1x2igGOpm/Hl
urR8FLBOybEfdF849lHqm/osohHUqS0nGkWxr7JOcQ3AWEbWaQbLU8uz/mtBzUF+
fUwPfHJ5elnNXkoOrJupmHN5fLT0zLm4BwyydFy4x2+IoZCn9Kr5v2c69BoVYh63
n749sSmvZ6ES8lgQGVMDMBu4Gon2nL2XA46jCfMdiyHxtN/kHNGfZQIG6lzWE7OE
76KlXIx3KadowGuuQNKotOrN8I1LOJwZmhsoVLiJkO/KdYE+HvJkJMcYr07/R54H
9jVlpNMKVv/1F2Rs76giJUmTtt8AF9pYfl3uxRuw0dFfIRDH+fO6AgonB8Xx1sfT
4PsJYGw=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIBtjCCAVugAwIBAgITBmyf1XSXNmY/Owua2eiedgPySjAKBggqhkjOPQQDAjA5
MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6b24g
Um9vdCBDQSAzMB4XDTE1MDUyNjAwMDAwMFoXDTQwMDUyNjAwMDAwMFowOTELMAkG
A1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJvb3Qg
Q0EgMzBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCmXp8ZBf8ANm+gBG1bG8lKl
ui2yEujSLtf6ycXYqm0fc4E7O5hrOXwzpcVOho6AF2hiRVd9RFgdszflZwjrZt6j
QjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQWBBSr
ttvXBp43rDCGB5Fwx5zEGbF4wDAKBggqhkjOPQQDAgNJADBGAiEA4IWSoxe3jfkr
BqWTrBqYaGFy+uGh0PsceGCmQ5nFuMQCIQCcAu/xlJyzlvnrxir4tiz+OpAUFteM
YyRIHN8wfdVoOw==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIB8jCCAXigAwIBAgITBmyf18G7EEwpQ+Vxe3ssyBrBDjAKBggqhkjOPQQDAzA5
MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6b24g
Um9vdCBDQSA0MB4XDTE1MDUyNjAwMDAwMFoXDTQwMDUyNjAwMDAwMFowOTELMAkG
A1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJvb3Qg
Q0EgNDB2MBAGByqGSM49AgEGBSuBBAAiA2IABNKrijdPo1MN/sGKe0uoe0ZLY7Bi
9i0b2whxIdIA6GO9mif78DluXeo9pcmBqqNbIJhFXRbb/egQbeOc4OO9X4Ri83Bk
M6DLJC9wuoihKqB1+IGuYgbEgds5bimwHvouXKNCMEAwDwYDVR0TAQH/BAUwAwEB
/zAOBgNVHQ8BAf8EBAMCAYYwHQYDVR0OBBYEFNPsxzplbszh2naaVvuc84ZtV+WB
MAoGCCqGSM49BAMDA2gAMGUCMDqLIfG9fhGt0O9Yli/W651+kI0rz2ZVwyzjKKlw
CkcO8DdZEv8tmZQoTipPNU0zWgIxAOp1AE47xDqUEpHJWEadIRNyp4iciuRMStuW
1KyLa2tJElMzrdfkviT8tQp21KW8EA==
-----END CERTIFICATE-----
EOF

if test -x "`which curl`"
then
	# Pin the certificate file.
	# Curl will use the system --capath if we don't specify one.
	# FIXME --capath / is safe (there shouldn't be any certs in it, regular users can't write to it, etc), /var/empty would be more obvious but might break if some future curl checks existence?
	DOWNLOADER="curl --capath / --cacert $CAFILE -q -f -L -o "
else
	DOWNLOADER="wget -o /dev/null --ca-certificate $CAFILE -N -O "
fi

# FIXME: re-activate updating of the update script. Currently this
#        only works over Freenet. Needs to be implemented without
#        relying on the lost infrastructure. Ideally go to TUF.

# ### delicate: updating the update script itself ###
# # emergency rescue: on erroneous EXIT recover update.sh from a tmp-file
# # (only replaces the file if a tmp-file exists)
# recover_update_sh () {
# 	cp update_tmp.sh "$0"
# }
# trap recover_update_sh EXIT
# # rename the current script to ensure that we do not override what we are executing
# mv -- "$0" update_tmp.sh && cp -- update_tmp.sh "$0"
# # update update.sh
# # FIXME: use new downloader
# if java $JOPTS -cp sha1test.jar Sha1Test update.sh ./ $CAFILE
# then
# 	echo "Downloaded update.sh"
# 	chmod +x update.sh
# 
# 	touch update.sh update2.sh
# 	if file_comp update.sh update2.sh >/dev/null
# 	then
# 		echo "Your update.sh is up to date"
# 	else
# 		cp update.sh update2.sh
# 		exec ./update.sh $RELEASE
# 		exit
# 	fi
# else
# 	echo "Could not download new update.sh."
# 	exit
# fi
# # replace the exit trap by a trap which removes the tmp-file
# remove_update_tmp_sh () {
# 	if test -s update.sh; then # safe to kill the tempfile
# 		rm update_tmp.sh
# 	fi
# }
# trap remove_update_tmp_sh EXIT
# ### / updating the update script ###

# Download a fred update
download_fred_update () {
    ## TODO: Replace with clean TUF setup. This is just a bandaid and can
    ##       be broken by changes in Github at any time.
    LATEST_RELEASE_URL="`curl -w "%{url_effective}\n" -I -L -s -S https://github.com/freenet/fred/releases/latest -o /dev/null`"
    LATEST_TAG="`echo ${LATEST_RELEASE_URL} | sed s,.*/,,`"
    LATEST_DOWNLOAD_URL="https://github.com/freenet/fred/releases/download/${LATEST_TAG}/freenet-${LATEST_TAG}.jar"
    wget -N -O download-temp/freenet-$RELEASE-latest.jar.sig "${LATEST_DOWNLOAD_URL}".sig || curl -q -f -L -o download-temp/freenet-$RELEASE-latest.jar.sig "${LATEST_DOWNLOAD_URL}".sig
    wget -N -O download-temp/freenet-$RELEASE-latest.jar "${LATEST_DOWNLOAD_URL}" || curl -q -f -L -o download-temp/freenet-$RELEASE-latest.jar "${LATEST_DOWNLOAD_URL}"
}

# if java $JOPTS -cp sha1test.jar Sha1Test freenet-$RELEASE-latest.jar download-temp $CAFILE
if download_fred_update
then
	echo Downloaded freenet-$RELEASE-latest.jar
else
	echo Could not download new freenet-$RELEASE-latest.jar.
	exit 1
fi

# FIXME: re-implement updating of other components without the lost infrastructure
# if java $JOPTS -cp sha1test.jar Sha1Test freenet-ext.jar download-temp $CAFILE
# then
# 	echo Downloaded freenet-ext.jar
# else
# 	echo Could not download new freenet-ext.jar.
# 	exit 1
# fi
# 
# if test ! -s bcprov-jdk15on-154.jar
# then
# 	echo Downloading bcprov-jdk15on-154.jar
# 	if ! java $JOPTS -cp sha1test.jar Sha1Test bcprov-jdk15on-154.jar . $CAFILE
# 	then
# 		echo Could not download bcprov-jdk15on-154.jar needed for new jar
# 		exit
# 	fi
# fi
# 
# if test ! -s wrapper.jar
# then
# 	echo Downloading wrapper.jar
# 	if ! java $JOPTS -cp sha1test.jar Sha1Test wrapper.jar . $CAFILE
# 	then
# 		echo Could not download wrapper.jar needed for new jar
# 		exit
# 	fi
# fi

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

if ! grep jna-4.2.2.jar wrapper.conf > /dev/null
then
   echo Adding jna-4.2.2.jar to wrapper.conf
   echo "wrapper.java.classpath.5=jna-4.2.2.jar" >> wrapper.conf
fi

if ! grep jna-platform-4.2.2.jar wrapper.conf > /dev/null
then
   echo Adding jna-platform-4.2.2.jar to wrapper.conf
   echo "wrapper.java.classpath.6=jna-platform-4.2.2.jar" >> wrapper.conf
fi

if ! grep bcprov-jdk15on-159.jar wrapper.conf > /dev/null
then
	if grep bcprov-jdk15on wrapper.conf > /dev/null; then
		echo Updating wrapper.conf to bouncycastle 1.59
		cat wrapper.conf | sed 's/bcprov-jdk15on-[0-9]*/bcprov-jdk15on-159/g' > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	else
		echo Adding bcprov-jdk15on-159.jar to wrapper.conf
		echo "wrapper.java.classpath.3=bcprov-jdk15on-159.jar" >> wrapper.conf
	fi
else
	echo wrapper.conf contains up to date bouncycastle jar v1.59
	if grep bcprov-jdk15on-147.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 147 and 159, deleting 147
		cat wrapper.conf | sed "/bcprov-jdk15on-147/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
	if grep bcprov-jdk15on-149.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 149 and 159, deleting 149
		cat wrapper.conf | sed "/bcprov-jdk15on-149/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
	if grep bcprov-jdk15on-151.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 151 and 159, deleting 151
		cat wrapper.conf | sed "/bcprov-jdk15on-151/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
	if grep bcprov-jdk15on-152.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 152 and 159, deleting 152
		cat wrapper.conf | sed "/bcprov-jdk15on-152/d" > wrapper.conf.new
		mv wrapper.conf.new wrapper.conf
	fi
	if grep bcprov-jdk15on-154.jar wrapper.conf > /dev/null; then
		echo wrapper.conf contains both bouncycastle 154 and 159, deleting 154
		cat wrapper.conf | sed "/bcprov-jdk15on-154/d" > wrapper.conf.new
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
