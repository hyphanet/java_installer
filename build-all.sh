#!/bin/bash

# Dependancies:
# In bin/ : freenet.jar, freenet-ext.jar, seednodes.fref
# In ../FreenetReleased/ : JSTUN.jar, UPnP.jar, Library.jar, KeyExplorer.jar, ThawIndexBrowser.jar

JAVA_HOME=/usr/lib/jvm/java-1.5.0-sun
PATH=$JAVA_HOME/bin/:$PATH

test -e bin/freenet.jar || exit
test -e bin/freenet-ext.jar || exit
test -e bin/seednodes.fref || exit

rm -rf offline/*
rm -f *.exe *.jar *.sig
ant clean
ant win32
mv install.jar new_installer.jar
mkdir dist
cp ./res/bin/sha1test.jar dist
mv install*exe* new_installer.* dist

# update wrapper_windows.zip
rm -rf wrapper_windows
cp -a res/windows wrapper_windows
cd wrapper_windows
zip -9 -q -r wrapper_windows.zip . -i bin/*.exe -i lib/*.dll
sha1sum wrapper_windows.zip >wrapper_windows.zip.sha1
mv wrapper_windows.zip* ../dist
cd ..

# update wrapper_linux.zip
rm -rf wrapper_unix
cp -a res/unix wrapper_unix
cd wrapper_unix
zip -9 -q -r wrapper_Linux.zip . -i bin/wrapper-linux-* -i lib/libwrapper-linux-*
zip -9 -q -r wrapper_Darwin.zip . -i bin/wrapper-macosx-* -i lib/libwrapper-macosx-*
sha1sum wrapper_Linux.zip >wrapper_Linux.zip.sha1
sha1sum wrapper_Darwin.zip >wrapper_Darwin.zip.sha1
mv wrapper_*.zip* ../dist
cd ..

touch offline/offline
cp dist/wrapper_*.zip* offline/
cp bin/freenet.jar offline/freenet-stable-latest.jar
cp bin/freenet-ext.jar offline/freenet-ext.jar
cp bin/seednodes.fref offline/
cp scripts/update.sh offline/
cp res/bin/sha1test.jar offline/

mkdir offline/plugins
cp ../FreenetReleased/JSTUN.jar offline/plugins/
cp ../FreenetReleased/UPnP.jar offline/plugins/
cp ../FreenetReleased/Library.jar offline/plugins/
cp ../FreenetReleased/KeyExplorer.jar offline/plugins/
cp ../FreenetReleased/ThawIndexBrowser.jar offline/plugins/
ant win32

mv install.jar new_installer_offline.jar
mv install.exe install_offline.exe
mv -f install_offline.* new_installer_offline.* dist/

# update da-tarball
rm -rf tarball
mkdir -p tarball
cd tarball
mkdir -p freenet/bin freenet/lib
cp ../res/unix/bin/remove_cronjob.sh freenet/bin/
cp ../res/bin/*jar freenet/bin/
cp ../scripts/1run.sh freenet/bin/
cp ../res/wrapper.conf freenet/
cp ../res/unix/run.sh freenet/
rm -rf freenet/license
cp -a ../res/license freenet/license
cp ../res/startssl.pem freenet/
chmod a+rx -R freenet/bin freenet/lib
tar czf freenet07.tar.gz freenet
sha1sum freenet07.tar.gz >freenet07.tar.gz.sha1
mv freenet07.tar.gz* ../dist/
cd ..
rm -f freenet-ext.jar freenet-stable-latest.jar
chmod a+r dist/*

