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
@java -jar bin\sha1test.jar JSTUN.jar plugins %CAFILE% > NUL
:end1
@del /F stun > NUL
:nostun

@if not exist mdns goto nomdns 
@echo 	-MDNSDiscovery
@set PLUGINS=MDNSDiscovery;%PLUGINS%
@if exist offline goto end2
@java -jar bin\sha1test.jar MDNSDiscovery.jar plugins %CAFILE% > NUL
:end2
@del /F mdns > NUL
:nomdns

@if not exist upnp goto noupnp 
@echo 	-UPnP
@set PLUGINS=UPnP;%PLUGINS%
@if exist offline goto end3
@java -jar bin\sha1test.jar UPnP.jar plugins %CAFILE% > NUL
:end3
@del /F upnp > NUL
:noupnp

@if not exist xmllibrarian goto nolibrarian 
@echo 	-XMLLibrarian
@set PLUGINS=XMLLibrarian;%PLUGINS%
@if exist offline goto end4
@java -jar bin\sha1test.jar XMLLibrarian.jar plugins %CAFILE% > NUL
:end4
@del /F xmllibrarian > NUL
:nolibrarian

@if not exist keyexplorer goto nolibrarian 
@echo 	-KeyExplorer
@set PLUGINS=KeyExplorer;%PLUGINS%
@if exist offline goto end4
@java -jar bin\sha1test.jar KeyExplorer.jar plugins %CAFILE% > NUL
:end4
@del /F keyexplorer > NUL
:nokeyexplorer

@if not exist thawindexbrowser goto nolibrarian 
@echo 	-ThawIndexBrowser
@set PLUGINS=ThawIndexBrowser;%PLUGINS%
@if exist offline goto end4
@java -jar bin\sha1test.jar ThawIndexBrowser.jar plugins %CAFILE% > NUL
:end4
@del /F thawindexbrowser > NUL
:nothawindexbrowser

@echo pluginmanager.loadplugin=%PLUGINS% >> freenet.ini
:end
