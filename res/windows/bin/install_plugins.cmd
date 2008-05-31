@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@echo Setting up plugins
@mkdir plugins 2> NUL
@set PLUGINS=

@if not exist stun goto nostun 
@echo 	-JSTUN
@set PLUGINS=JSTUN;%PLUGINS%
@if exist offline goto end1
@java -jar bin\sha1test.jar plugins/JSTUN.jar.url plugins %CAFILE% > NUL
@if exist plugins\JSTUN.jar del /F plugins\JSTUN.jar > NUL
@move plugins\JSTUN.jar.url plugins\JSTUN.jar > NUL
:end1
@del /F stun > NUL
:nostun

@if not exist mdns goto nomdns 
@echo 	-MDNSDiscovery
@set PLUGINS=MDNSDiscovery;%PLUGINS%
@if exist offline goto end2
@java -jar bin\sha1test.jar plugins/MDNSDiscovery.jar.url plugins %CAFILE% > NUL
@if exist plugins\MDNSDiscovery.jar del /F plugins\MDNSDiscovery.jar > NUL
@move plugins\MDNSDiscovery.jar.url plugins\MDNSDiscovery.jar > NUL
:end2
@del /F mdns > NUL
:nomdns

@if not exist upnp goto noupnp 
@echo 	-UPnP
@set PLUGINS=UPnP;%PLUGINS%
@if exist offline goto end3
@java -jar bin\sha1test.jar plugins/UPnP.jar.url plugins %CAFILE% > NUL
@if exist plugins\UPnP.jar del /F plugins\UPnP.jar > NUL
@move plugins\UPnP.jar.url plugins\UPnP.jar
:end3
@del /F upnp > NUL
:noupnp

@if not exist xmllibrarian goto nolibrarian 
@echo 	-XMLLibrarian
@set PLUGINS=XMLLibrarian;%PLUGINS%
@if exist offline goto end4
@java -jar bin\sha1test.jar plugins/XMLLibrarian.jar.url plugins %CAFILE% > NUL
@if exist plugins\XMLLibrarian.jar del /F plugins\XMLLibrarian.jar > NUL
@move plugins\XMLLibrarian.jar.url plugins\XMLLibrarian.jar
:end4
@del /F xmllibrarian > NUL
:nolibrarian

@echo pluginmanager.loadplugin=%PLUGINS% >> freenet.ini
:end
