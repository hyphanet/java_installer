@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@echo Setting up plugins
@mkdir plugins 2> NUL
@set PLUGINS=

@if not exist stun goto nostun 
@echo 	-JSTUN
@set PLUGINS=JSTUN;%PLUGINS%
@if exist offline goto end1
@java -jar bin\sha1test.jar plugins/JSTUN.jar plugins > NUL
:end1
@del /F stun > NUL
:nostun

@if not exist mdns goto nomdns 
@echo 	-MDNSDiscovery
@set PLUGINS=MDNSDiscovery;%PLUGINS%
@if exist offline goto end2
@java -jar bin\sha1test.jar plugins/MDNSDiscovery.jar plugins > NUL
:end2
@del /F mdns > NUL
:nomdns

@if not exist upnp goto noupnp 
@echo 	-UPnP
@set PLUGINS=UPnP;%PLUGINS%
@if exist offline goto end3
@java -jar bin\sha1test.jar plugins/UPnP.jar plugins > NUL
:end3
@del /F upnp > NUL
:noupnp

@if not exist xmllibrarian goto nolibrarian 
@echo 	-XMLLibrarian
@set PLUGINS=XMLLibrarian;%PLUGINS%
@if exist offline goto end4
@java -jar bin\sha1test.jar plugins/XMLLibrarian.jar plugins > NUL
:end4
@del /F xmllibrarian > NUL
:nolibrarian

@echo pluginmanager.loadplugin=%PLUGINS% >> freenet.ini
