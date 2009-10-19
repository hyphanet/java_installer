@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@echo Setting up plugins
@mkdir plugins 2> NUL
@set PLUGINS=

@echo 	-JSTUN
@if exist offline goto end1
@java -jar bin\sha1test.jar JSTUN.jar plugins %CAFILE% > NUL
:end1
:nostun

@echo 	-UPnP
@if exist offline goto end3
@java -jar bin\sha1test.jar UPnP.jar plugins %CAFILE% > NUL
:end3
:noupnp

@echo 	-Library
@if exist offline goto end4
@java -jar bin\sha1test.jar Library.jar plugins %CAFILE% > NUL
:end4
:nolibrarian

@echo 	-KeyExplorer
@if exist offline goto end4
@java -jar bin\sha1test.jar KeyExplorer.jar plugins %CAFILE% > NUL
:end4
:nokeyexplorer

@echo 	-ThawIndexBrowser
@if exist offline goto end4
@java -jar bin\sha1test.jar ThawIndexBrowser.jar plugins %CAFILE% > NUL
:end4
:nothawindexbrowser

@echo pluginmanager.loadplugin=Library;KeyExplorer;ThawIndexBrowser >> freenet.ini
:end
