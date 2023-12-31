#!/bin/sh

#
# Copyright (c) 1999, 2006 Tanuki Software Inc.
#
# Java Service Wrapper sh script.  Suitable for starting and stopping
#  wrapped Java applications on UNIX platforms.
#

#-----------------------------------------------------------------------------
# These settings can be modified to fit the needs of your application

# Application
APP_NAME="Freenet"
APP_LONG_NAME="Freenet 0.7"

# Wrapper
WRAPPER_CMD="./bin/wrapper"
WRAPPER_CONF="./wrapper.conf"

# Priority at which to run the wrapper.  See "man nice" for valid priorities.
#  nice is only used if a priority is specified.

# Note that Freenet will scale its usage within the specifed niceness, some
# threads will have a lower priority (higher nice value) than this. Also please
# don't renice Freenet once it's started.
PRIORITY=10

# Location of the pid file.
PIDDIR="."

# If uncommented, causes the Wrapper to be shutdown using an anchor file.
#  When launched with the 'start' command, it will also ignore all INT and
#  TERM signals.
IGNORE_SIGNALS=true

# If specified, the Wrapper will be run as the specified user.
# IMPORTANT - Make sure that the user has the required privileges to write
#  the PID file and wrapper.log files.  Failure to be able to write the log
#  file will cause the Wrapper to exit without any way to write out an error
#  message.
# NOTE - This will set the user which is used to run the Wrapper as well as
#  the JVM and is not useful in situations where a privileged resource or
#  port needs to be allocated prior to the user being changed.
#RUN_AS_USER=

# The following two lines are used by the chkconfig command. Change as is
#  appropriate for your application.  They should remain commented.
# chkconfig: 2345 20 80
# description: @app.long.name@

# Do not modify anything beyond this point
#-----------------------------------------------------------------------------

if [ "X`id -u`" = "X0" -a -z "$RUN_AS_USER" ]
then
    echo "Do not run this script as root."
    exit 1
fi

# Get the fully qualified path to the script
case $0 in
    /*)
        SCRIPT="$0"
        ;;
    *)
        PWD=`pwd`
        SCRIPT="$PWD/$0"
        ;;
esac

# Resolve the true real path without any sym links.
CHANGED=true
while [ "X$CHANGED" != "X" ]
do
    # Change spaces to ":" so the tokens can be parsed.
    SCRIPT=`echo $SCRIPT | sed -e 's; ;:;g'`
    # Get the real path to this script, resolving any symbolic links
    TOKENS=`echo $SCRIPT | sed -e 's;/; ;g'`
    REALPATH=
    for C in $TOKENS; do
        REALPATH="$REALPATH/$C"
        while [ -h "$REALPATH" ] ; do
            LS="`ls -ld "$REALPATH"`"
            LINK="`expr "$LS" : '.*-> \(.*\)$'`"
            if expr "$LINK" : '/.*' > /dev/null; then
                REALPATH="$LINK"
            else
                REALPATH="`dirname "$REALPATH"`""/$LINK"
            fi
        done
    done

    # Change ":" chars back to spaces.
    REALPATH="`echo $REALPATH | sed -e 's;:; ;g'`"
    SCRIPT="`echo $SCRIPT | sed -e 's;:; ;g'`"

    if [ "$REALPATH" = "$SCRIPT" ]
    then
        CHANGED=""
    else
        SCRIPT="$REALPATH"
    fi
done

# Change the current directory to the location of the script
cd "`dirname \"$REALPATH\"`"
REALDIR="`pwd`"

# Resolve the os
DIST_OS=`uname -s | tr [:upper:] [:lower:] | tr -d " \t\r\n"`
case "$DIST_OS" in
    'sunos')
        DIST_OS="solaris"
        ;;
    'hp-ux' | 'hp-ux64')
        DIST_OS="hpux"
        ;;
    'darwin' | 'oarwin')
        DIST_OS="macosx"
        ;;
    'unix_sv')
        DIST_OS="unixware"
        ;;
    'freebsd' | 'openbsd' | 'netbsd')
        DIST_OS="freebsd"
        ;;
esac

if [ "$DIST_OS" = "macosx" ]
then
	# If there's a modern (9+) JVM, use that...
	JAVA_HOME="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/"
	if ! test -e "$JAVA_HOME/bin/java"
	then
		# otherwise hope for the best
		JAVA_HOME="`/usr/libexec/java_home -v 1.6+`"
	fi
fi

JAVA_REAL_IMPL="java"
# Attempt to second-guess the user and find a JRE we can actually use...
# The wrapper needs an ELF binary... some distros are using a shell wrapper
# see bug #6217
#
# /usr/lib64/jvm/jre-1.7.0-openjdk/bin/java SuSE
# /usr/lib/jvm/java-7-openjdk/jre/bin/java Debian (old)
# /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java Debian (new)
# /usr/local/openjdk7/jre/bin/java FreeBSD
DEB_ARCH="amd64 i386"
DEB_CANDIDATES=""
for version in 18 17 16 15 14 13 12 11 10 9; do DEB_CANDIDATES="$DEB_CANDIDATES /usr/lib/jvm/java-$version-openjdk/jre/bin/java"; for arch in $DEB_ARCH; do DEB_CANDIDATES="$DEB_CANDIDATES /usr/lib/jvm/java-$version-openjdk-$arch/jre/bin/java";done;done
CANDIDATES="$JAVA_HOME/bin/java `which java` /etc/java-config-2/current-system-vm/bin/java /usr/lib/jvm/java-default-runtime/bin/java $DEB_CANDIDATES /usr/lib64/jvm/jre-1.8.0-openjdk/bin/java /usr/lib64/jvm/jre-1.7.0-openjdk/bin/java /usr/local/openjdk8/jre/bin/java /usr/local/openjdk7/jre/bin/java"
for candidate in $CANDIDATES
do
	if test -s "$candidate"
	then
		if head -1 "$candidate"|grep '^#' >/dev/null 2>&1
		then
			echo "Your java executable at $candidate is a script... looking for alternatives..."
		elif echo "$candidate"|grep -i 'gcj' >/dev/null 2>&1
		then
			echo "Freenet won't work well with GCJ, ignoring $candidate"
		else
			if test -n "$JAVA_HOME" -a "$JAVA_HOME/bin/java" != "$candidate"
			then
				echo "Your JAVA_HOME seems to be incompatible with your PATH, ignoring it."
				unset JAVA_HOME
			fi
			echo "Your java executable at $candidate seems suitable"
			ESCAPED_CANDIDATE=`echo "$candidate"|sed 's/\(\/\)/\\\\\1/g'`
			sed "s/^wrapper.java.command=.*$/wrapper.java.command=$ESCAPED_CANDIDATE/" "$REALDIR/wrapper.conf" > "$REALDIR/wrapper.conf.bak"
			mv "$REALDIR/wrapper.conf.bak" "$REALDIR/wrapper.conf"
			JAVA_REAL_IMPL="$candidate"
			break
		fi
	fi
done

# and get java implementation too, Sun JDK or Kaffe
JAVA_IMPL=`$JAVA_REAL_IMPL -version 2>&1 | head -n 1 | cut -f1 -d' '`


if test ! -s freenet.ini
then
	exec ./bin/1run.sh
	exit
fi

# If the PIDDIR is relative, set its value relative to the full REALPATH to avoid problems if
#  the working directory is later changed.
FIRST_CHAR="`echo $PIDDIR | cut -c1,1`"
if [ "$FIRST_CHAR" != "/" ]
then
    PIDDIR="$REALDIR/$PIDDIR"
fi
# Same test for WRAPPER_CMD
FIRST_CHAR="`echo $WRAPPER_CMD | cut -c1,1`"
if [ "$FIRST_CHAR" != "/" ]
then
    WRAPPER_CMD="$REALDIR/$WRAPPER_CMD"
fi
# Same test for WRAPPER_CONF
FIRST_CHAR="`echo \"$WRAPPER_CONF\" | cut -c1,1`"
if [ "$FIRST_CHAR" != "/" ]
then
    WRAPPER_CONF="$REALDIR/$WRAPPER_CONF"
fi

# Process ID
ANCHORFILE="$PIDDIR/$APP_NAME.anchor"
PIDFILE="$PIDDIR/$APP_NAME.pid"
LOCKDIR="$REALDIR"
LOCKFILE="$LOCKDIR/$APP_NAME"
pid=""

# Resolve the architecture
DIST_ARCH=`uname -m | tr [:upper:] [:lower:] | tr -d " \t\r\n"`
case "$DIST_ARCH" in
    'amd64' | 'ia32' | 'i386' | 'i486' | 'i586' | 'i686' | 'x86_64')
        DIST_ARCH="x86"
        ;;
    'ia64' | 'ia-64')
	DIST_ARCH="ia64"
	;;
    'ip27' | 'mips')
        DIST_ARCH="mips"
        ;;
    'powermacintosh' | 'power' | 'powerpc' | 'power_pc' | 'ppc64')
        DIST_ARCH="ppc"
        ;;
    'pa_risc' | 'pa-risc')
        DIST_ARCH="parisc"
        ;;
    'sun4u' | 'sparcv9')
        DIST_ARCH="sparc"
        ;;
    '9000/800')
        DIST_ARCH="parisc"
        ;;
    'aarch64')
        DIST_ARCH="arm"  # 64 bit ARM
		;;
    armv*)
        if [ -z "`readelf -A /proc/self/exe | grep Tag_ABI_VFP_args`" ] ; then
            DIST_ARCH="armel"
        else
            DIST_ARCH="armhf"
        fi
        ;;
esac

# Check if we are running on 64bit platform, seems like a workaround for now...
DIST_BIT=`uname -m | tr [:upper:] [:lower:] | tr -d " \t\r\n"`
case "$DIST_BIT" in
    'amd64' | 'ia64' | 'x86_64' | 'ppc64')
        DIST_BIT="64"
        ;;
#    'pa_risc' | 'pa-risc') # Are some of these 64bit? Least not all...
#       BIT="64"
#        ;;
    'sun4u' | 'sparcv9') # Are all sparcs 64?
        DIST_BIT="64"
        ;;
#    '9000/800')
#       DIST_BIT="64"
#        ;;
    'aarch64')
        DIST_BIT="64"
        ;;
    *) # In any other case default to 32
        DIST_BIT="32"
        ;;
esac

# Decide on the wrapper binary to use.
# 64bit wrapper by default on 64bit platforms, because
# they might not have 32bit emulation libs installed.
# For macosx, we also want to look for universal binaries.

WRAPPER_TEST_CMD="$WRAPPER_CMD-$DIST_OS-$DIST_ARCH-$DIST_BIT"

if [ -x "$WRAPPER_TEST_CMD" ]
then
    WRAPPER_CMD="$WRAPPER_TEST_CMD"
else
    if [ "$DIST_OS" = "macosx" ] # Some osx weirdness, someone please check that this still works
    then
        WRAPPER_TEST_CMD="$WRAPPER_CMD-$DIST_OS-universal-$DIST_BIT"
        if [ -x "$WRAPPER_TEST_CMD" ]
        then
            WRAPPER_CMD="$WRAPPER_TEST_CMD"
        else
            WRAPPER_TEST_CMD="$WRAPPER_CMD-$DIST_OS-$DIST_ARCH-$DIST_BIT"
            if [ -x "$WRAPPER_TEST_CMD" ]
            then
                WRAPPER_CMD="$WRAPPER_TEST_CMD"
            else
                WRAPPER_TEST_CMD="$WRAPPER_CMD-$DIST_OS-universal-$DIST_BIT"
                if [ -x "$WRAPPER_TEST_CMD" ]
                then
                    WRAPPER_CMD="$WRAPPER_TEST_CMD"
                else
                    if [ ! -x "$WRAPPER_CMD" ]
                    then
                        echo "Unable to locate any of the following binaries:"
                        echo "  $WRAPPER_CMD-$DIST_OS-$DIST_ARCH-$DIST_BIT"
                        echo "  $WRAPPER_CMD-$DIST_OS-universal-$DIST_BIT"
                        echo "  $WRAPPER_CMD"
                        NO_WRAPPER="$JAVA_REAL_IMPL  -Xmx1500m -Xss512k -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0 --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED -cp bcprov-jdk15on-1.59.jar:freenet-ext.jar:freenet.jar:jna-4.5.2.jar:jna-platform-4.5.2.jar:pebble-3.1.5.jar:unbescape-1.1.6.RELEASE.jar:slf4j-api-1.7.25.jar freenet.node.NodeStarter"
                    fi
                fi
            fi
        fi
    else
        if [ ! -x "$WRAPPER_CMD" ]
        then
            echo "Unable to locate any of the following binaries:"
            echo "  $WRAPPER_CMD-$DIST_OS-$DIST_ARCH-$DIST_BIT"
            echo "  $WRAPPER_CMD"
            NO_WRAPPER="$JAVA_REAL_IMPL  -Xmx1500m -Xss512k -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0 --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED  -cp bcprov-jdk15on-1.59.jar:freenet-ext.jar:freenet.jar:jna-4.5.2.jar:jna-platform-4.5.2.jar:pebble-3.1.5.jar:unbescape-1.1.6.RELEASE.jar:slf4j-api-1.7.25.jar freenet.node.NodeStarter"
        fi
    fi
fi

# Build the nice clause
if [ "X$PRIORITY" = "X" ]
then
    CMDNICE=""
else
    CMDNICE="nice -$PRIORITY"
fi

# Build the anchor file clause.
if [ "X$IGNORE_SIGNALS" = "X" ]
then
   ANCHORPROP=
   IGNOREPROP=
else
   ANCHORPROP=wrapper.anchorfile=\"$ANCHORFILE\"
   IGNOREPROP=wrapper.ignore_signals=TRUE
fi

# Build the lock file clause.  Only create a lock file if the lock directory exists on this platform.
if [ -d "$LOCKDIR" ]
then
    LOCKPROP=wrapper.lockfile=\"$LOCKFILE\"
else
    LOCKPROP=
fi

checkUser() {
    # Check the configured user.  If necessary rerun this script as the desired user.
    if [ "X$RUN_AS_USER" != "X" ]
    then
        # Resolve the location of the 'id' command
        IDEXE="/usr/xpg4/bin/id"
        if [ ! -x $IDEXE ]
        then
            IDEXE="/usr/bin/id"
            if [ ! -x $IDEXE ]
            then
                echo "Unable to locate 'id'."
                echo "Please report this message along with the location of the command on your system."
                exit 1
            fi
        fi

        if [ "`$IDEXE -u -n`" = "$RUN_AS_USER" ]
        then
            # Already running as the configured user.  Avoid password prompts by not calling su.
            RUN_AS_USER=""
        fi
    fi
    if [ "X$RUN_AS_USER" != "X" ]
    then
        # If LOCKPROP and $RUN_AS_USER are defined then the new user will most likely not be
        # able to create the lock file.  The Wrapper will be able to update this file once it
        # is created but will not be able to delete it on shutdown.  If $2 is defined then
        # the lock file should be created for the current command
        if [ "X$LOCKPROP" != "X" ]
        then
            if [ "X$2" != "X" ]
            then
                # Resolve the primary group
                RUN_AS_GROUP=`groups $RUN_AS_USER | awk '{print $3}' | tail -1`
                if [ "X$RUN_AS_GROUP" = "X" ]
                then
                    RUN_AS_GROUP=$RUN_AS_USER
                fi
                touch "$LOCKFILE"
                chown $RUN_AS_USER:$RUN_AS_GROUP "$LOCKFILE"
            fi
        fi

        # Still want to change users, recurse.  This means that the user will only be
        #  prompted for a password once.
        su -m $RUN_AS_USER -c "$REALPATH $1"

        # Now that we are the original user again, we may need to clean up the lock file.
        if [ "X$LOCKPROP" != "X" ]
        then
            getpid
            if [ "X$pid" = "X" ]
            then
                # Wrapper is not running so make sure the lock file is deleted.
                if [ -f "$LOCKFILE" ]
                then
                    rm "$LOCKFILE"
                fi
            fi
        fi

        exit 0
    fi
}

getpid() {
    if [ -f "$PIDFILE" ]
    then
        if [ -r "$PIDFILE" ]
        then
            pid="`cat \"$PIDFILE\"`"
            if [ "X$pid" != "X" ]
            then
                # It is possible that 'a' process with the pid exists but that it is not the
                #  correct process.  This can happen in a number of cases, but the most
                #  common is during system startup after an unclean shutdown.
                # So make sure the process is one of "ours" -- that we can send
		# a signal to it.  (We don't use ps(1) because that's neither
		# safe nor portable.
		if ! kill -0 $pid 2>/dev/null
                then
                    # This is a stale pid file.
                    rm -f "$PIDFILE"
                    echo "Removed stale pid file: $PIDFILE"
                    pid=""
                fi
		# Sometimes the pid exists and it's ours!
		if [ "$DIST_OS" = "linux" ]
		then
			if ! test -f /proc/$pid/cwd/Freenet.pid
			then
                    		# This is a stale pid file.
                    		rm -f "$PIDFILE"
                    		echo "Removed stale pid file2: $PIDFILE"
                    		pid=""

			fi
		fi
            fi
        else
            echo "Cannot read $PIDFILE."
            exit 1
        fi
    fi
}

testpid() {
    if ! kill -0 $pid 2>/dev/null
    then
        # Process is gone so remove the pid file.
        rm -f "$PIDFILE"
        pid=""
    fi
}

console() {
    echo "Running $APP_LONG_NAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        COMMAND_LINE="$CMDNICE \"$WRAPPER_CMD\" \"$WRAPPER_CONF\" wrapper.syslog.ident=\"$APP_NAME\" wrapper.pidfile=\"$PIDFILE\" $LDPROP $ANCHORPROP $LOCKPROP"
        eval $COMMAND_LINE
    else
        echo "$APP_LONG_NAME is already running."
        exit 1
    fi
}

start() {
    echo "Starting $APP_LONG_NAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        if [ "$NO_WRAPPER" ] # Check if we don't have usable wrapper, and run without it
        then
            echo ""
	    echo "Let's start the node without the wrapper, you'll have to daemonize it yourself."
            eval $NO_WRAPPER
        else                 # Otherwise use the wrapper
            COMMAND_LINE="$CMDNICE \"$WRAPPER_CMD\" \"$WRAPPER_CONF\" wrapper.syslog.ident=\"$APP_NAME\" wrapper.pidfile=\"$PIDFILE\" $LDPROP wrapper.daemonize=TRUE $ANCHORPROP $IGNOREPROP $LOCKPROP"
            eval $COMMAND_LINE
        fi
    else
        echo "$APP_LONG_NAME is already running."
        exit 1
    fi
}

stopit() {
    echo "Stopping $APP_LONG_NAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        echo "$APP_LONG_NAME was not running."
    else
        if [ "X$IGNORE_SIGNALS" = "X" ]
        then
            # Running so try to stop it.
            kill $pid
            if [ $? -ne 0 ]
            then
                # An explanation for the failure should have been given
                echo "Unable to stop $APP_LONG_NAME."
                exit 1
            fi
        else
            rm -f "$ANCHORFILE"
            if [ -f "$ANCHORFILE" ]
            then
                # An explanation for the failure should have been given
                echo "Unable to stop $APP_LONG_NAME."
                exit 1
            fi
        fi

        # We can not predict how long it will take for the wrapper to
        #  actually stop as it depends on settings in $WRAPPER_CONF
        #  Loop until it does.
        savepid=$pid
        CNT=0
        TOTCNT=0
        while [ "X$pid" != "X" ]
        do
            # Show a waiting message every 5 seconds.
            if [ "$CNT" -lt "5" ]
            then
                CNT=`expr $CNT + 1`
            else
                echo "Waiting for $APP_LONG_NAME to exit..."
                CNT=0
            fi
            TOTCNT=`expr $TOTCNT + 1`

            sleep 1

            testpid
        done

        pid=$savepid
        testpid
        if [ "X$pid" != "X" ]
        then
            echo "Failed to stop $APP_LONG_NAME."
            exit 1
        else
            echo "Stopped $APP_LONG_NAME."
        fi
    fi
}

status() {
    getpid
    if [ "X$pid" = "X" ]
    then
        echo "$APP_LONG_NAME is not running."
        exit 1
    else
        echo "$APP_LONG_NAME is running ($pid)."
        exit 0
    fi
}

dump() {
    echo "Dumping $APP_LONG_NAME..."
    getpid
    if [ "X$pid" = "X" ]
    then
        echo "$APP_LONG_NAME was not running."

    else
        kill -QUIT $pid

        if [ $? -ne 0 ]
        then
            echo "Failed to dump $APP_LONG_NAME."
            exit 1
        else
            echo "Dumped $APP_LONG_NAME."
        fi
    fi
}

getHardwareMemory() {
    detected=8192 # fallback, MiB
    if [ $DIST_OS = "macosx" ]
    then
       detected=$((`sysctl hw.memsize | sed s/"hw.memsize: "//`/1024/1024))
    elif [ $DIST_OS = "freebsd" ]
    then
       detected=$((`sysctl hw.physmem | sed s/"hw.physmem: "//`/1024/1024))
    elif [ $DIST_OS = "linux" ]
    then
       detected=$((`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`/1024))
    fi
# Exit codes only support values between 0 and 255. So use stdout.
    echo $detected
}

setMemoryLimitIfNeeded() {
   if [ -f memory.autolimit ]
   then
       return
   else
       touch memory.autolimit
       echo OS is $DIST_OS
       currentmem=`getHardwareMemory`
       echo Detected memory: $currentmem
       echo $currentmem > memory.autolimit
       if [ $currentmem -le 256 ]
       then
           echo "not enough memory to run"
	   rm memory.autolimit
           exit 1
       elif [ $currentmem -le 512 ]
       then
           echo "128" > memory.autolimit
           memorylimit=128
       elif [ $currentmem -le 1024 ]
       then
           echo "192" > memory.autolimit
           memorylimit=192
       elif [ $currentmem -le 2048 ]
       then
           echo "256" > memory.autolimit
           memorylimit=256
       elif [ $currentmem -le 4096 ]
       then
           echo "512" > memory.autolimit
           memorylimit=512
       else
           echo "1024" > memory.autolimit
           memorylimit=1024
       fi
   mv "$WRAPPER_CONF" "${WRAPPER_CONF}.old"
   sed "s/wrapper.java.maxmemory=.*/wrapper.java.maxmemory=$memorylimit/g" "${WRAPPER_CONF}.old" > "$WRAPPER_CONF"
   fi
}

case "$1" in

    'console')
        checkUser $1 touchlock
        console
        ;;

    'start')
        checkUser $1 touchlock
        setMemoryLimitIfNeeded
        start
        ;;

    'stop')
        checkUser $1
        stopit
        ;;

    'restart')
        checkUser $1 touchlock
        stopit
        start
        ;;

    'status')
        checkUser $1
        status
        ;;

    'dump')
        checkUser $1
        dump
        ;;

    *)
        echo "Usage: $0 { console | start | stop | restart | status | dump }"
        exit 1
        ;;
esac

exit 0
