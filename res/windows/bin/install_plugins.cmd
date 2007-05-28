@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@echo "Setting up plugins"
@mkdir plugins 2> NUL
@set PLUGINS=

@if not exist stun goto nostun 
@echo 	-JSTUN
@set PLUGINS=plugins.JSTUN.JSTUN@file:///%INSTALL_PATH%\plugins\JSTUN.jar;%PLUGINS%
@if exist offline goto end1
@java -jar bin\sha1test.jar plugins/JSTUN.jar.url plugins > NUL
:end1
@copy plugins\JSTUN.jar.url plugins\JSTUN.jar > NUL
@del /F stun > NUL
:nostun

@if not exist mdns goto nomdns 
@echo 	-MDNSDiscovery
@set PLUGINS=plugins.MDNSDiscovery.MDNSDiscovery@file:///%INSTALL_PATH%\plugins\MDNSDiscovery.jar;%PLUGINS%
@if exist offline goto end2
@java -jar bin\sha1test.jar plugins/MDNSDiscovery.jar.url plugins > NUL
:end2
@copy plugins\MDNSDiscovery.jar.url plugins\MDNSDiscovery.jar > NUL
@del /F mdns > NUL
:nomdns

@if not exist upnp goto noupnp 
@echo 	-UPnP
@set PLUGINS=plugins.UPnP.UPnP@file:///%INSTALL_PATH%\plugins\UPnP.jar;%PLUGINS%
@if exist offline goto end3
@java -jar bin\sha1test.jar plugins/UPnP.jar.url plugins > NUL
:end3
@copy plugins\UPnP.jar.url plugins\UPnP.jar > NUL
@del /F upnp > NUL
:noupnp

@if not exist librarian goto nolibrarian 
@echo 	-Librarian
@set PLUGINS=plugins.Librarian.Librarian@file:///%INSTALL_PATH%\plugins\Librarian.jar;%PLUGINS%
@if exist offline goto end4
@java -jar bin\sha1test.jar plugins/Librarian.jar.url plugins > NUL
:end4
@copy plugins\Librarian.jar.url plugins\Librarian.jar > NUL
@del /F librarian > NUL
:nolibrarian

@echo pluginmanager.loadplugin=%PLUGINS% >> freenet.ini
