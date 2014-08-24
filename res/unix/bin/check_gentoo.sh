#!/bin/sh

. "$HOME/_install_toSource.sh" || exit 0
cd "$INSTALL_PATH"

# The wrapper needs an ELF binary... some distros are using a shell wrapper
# see bug #6217
CANDIDATES="$JAVA_HOME/bin/java `which java` /etc/java-config-2/current-system-vm/bin/java /usr/lib/jvm/java-default-runtime/bin/java /usr/lib/jvm/java-7-openjdk/jre/bin/java"
for candidate in $CANDIDATES
do
	if test -s "$candidate"
	then
		if head -1 "$candidate"|grep '^#' >/dev/null 2>&1
		then
			echo "Your java executable at $candidate is a script... looking for alternatives..."
		else
			echo "Your java executable at $candidate seems suitable"
			ESCAPED_CANDIDATE=`echo "$candidate"|sed 's/\(\/\)/\\\\\1/g'`
			sed -i "s/^wrapper.java.command=.*$/wrapper.java.command=$ESCAPED_CANDIDATE/" wrapper.conf
			break
		fi
	fi
done
