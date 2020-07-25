#!/bin/bash

# Dependencies:
# izPack (version 4 or later?): standalone-compiler.jar in lib/
# ~/.freenetrc pointing to $releaseDir
# In bin/ : freenet.jar, freenet-ext.jar, seednodes.fref, bcprov-jdk15on-1.59.jar, wrapper.jar (version corresponding to the native wrapper binaries)
# In $releaseDir : JSTUN.jar, UPnP.jar, Library.jar, KeyUtils.jar, ThawIndexBrowser.jar, Sharesite.jar

mkdir -p offline

source ../scripts/freenet-scripts-common || exit 1

touch -c bin/freenet.jar || exit
touch -c bin/freenet-ext.jar || exit
touch -c bin/bcprov-jdk15on-1.59.jar || exit
touch -c bin/wrapper.jar || exit
touch -c bin/seednodes.fref || exit

mkdir -p dist

ant compile

# update wrapper_linux.zip
rm -rf wrapper_unix
cp -a res/unix wrapper_unix
cd wrapper_unix
cp ../bin/wrapper.jar . || exit 9
zip -9 -q -r wrapper_Linux.zip . -i bin/wrapper-linux-* -i lib/libwrapper-linux-* || exit 9
zip -9 -q -r wrapper_Linux.zip wrapper.jar || exit 9
zip -9 -q -r wrapper_Darwin.zip . -i bin/wrapper-macosx-* -i lib/libwrapper-macosx-* || exit 10
zip -9 -q -r wrapper_Darwin.zip wrapper.jar || exit 10
sha1sum wrapper_Linux.zip >wrapper_Linux.zip.sha1
sha1sum wrapper_Darwin.zip >wrapper_Darwin.zip.sha1
mv wrapper_*.zip* ../dist
cd ..

touch offline/offline
cp dist/wrapper_*.zip* offline/ || exit 11
cp bin/freenet.jar offline/freenet-stable-latest.jar || exit 12
cp bin/freenet-ext.jar offline/freenet-ext.jar || exit 13
cp bin/bcprov-jdk15on-1.59.jar offline/ || exit 14
cp bin/jna-4.5.2.jar offline/ || exit
cp bin/jna-platform-4.5.2.jar offline || exit
cp bin/wrapper.jar offline/wrapper.jar || exit 37
cp bin/seednodes.fref offline/ || exit 15
cp scripts/update.sh offline/ || exit 16
cp res/bin/sha1test.jar offline/ || exit 17

mkdir -p offline/plugins
cp $releaseDir/JSTUN.jar offline/plugins/ || exit 18
cp $releaseDir/UPnP.jar offline/plugins/ || exit 19
cp $releaseDir/Library.jar offline/plugins/ || exit 20
cp $releaseDir/KeyUtils.jar offline/plugins/ || exit 21
cp $releaseDir/ThawIndexBrowser.jar offline/plugins/ || exit 22
cp $releaseDir/Sharesite.jar offline/plugins/ || exit 22

ant sign || exit

mv install.jar new_installer_offline.jar || exit 23
mv -f new_installer_offline.* dist/ || exit 25

# update da-tarball
rm -rf tarball
mkdir -p tarball
cd tarball
mkdir -p freenet/bin freenet/lib
cp ../res/unix/bin/remove_cronjob.sh freenet/bin/ || exit 26
cp ../res/bin/*jar freenet/bin/ || exit 27
cp ../scripts/1run.sh freenet/bin/ || exit 28
cp ../res/wrapper.conf freenet/ || exit 29
cp ../res/unix/run.sh freenet/ || exit 30
rm -rf freenet/license
cp -a ../res/license freenet/license || exit 31
cp ../res/startssl.pem freenet/ || exit 32
chmod a+rx -R freenet/bin freenet/lib
tar czf freenet07.tar.gz freenet || exit 33
sha1sum freenet07.tar.gz >freenet07.tar.gz.sha1 || exit 34
mv freenet07.tar.gz* ../dist/ || exit 35
cd ..
rm -f freenet-ext.jar freenet-stable-latest.jar
chmod a+r dist/*

rm -Rf wrapper_unix
echo Completed UNIX installer build
