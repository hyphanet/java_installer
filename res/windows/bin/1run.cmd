@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@cd %INSTALL_PATH%

:: Tweak freenet.ini
@if not exist stun goto nostun 
@echo pluginmanager.loadplugin=plugins.JSTUN@file:///$INSTALL_PATH\plugins\JSTUN.jar >> freenet.ini
@mkdir plugins
@java -jar bin\sha1test.jar JSTUN.jar plugins > NUL
@del /F stun > NUL
:nostun
@if exist update echo node.updater.autoupdate=true >> freenet.ini
@del /F update > NUL

:: Try to detect a free, aviable port for fproxy
@set FPROXY_PORT=8888
@java -jar bin\bindtest.jar %FPROXY_PORT% 
@if not errorlevel 0 set FPROXY_PORT=8889
@echo fproxy.enable=true >>freenet.ini
@echo fproxy.port=%FPROXY_PORT% >>freenet.ini

:: Try to detect a free, aviable port for fcp
@set FCP_PORT=9481
@java -jar bin\bindtest.jar %FCP_PORT% 
@if not errorlevel 0 set FCP_PORT=9482
@echo fcp.enable=true >>freenet.ini
@echo fcp.port=%FCP_PORT% >>freenet.ini

:: Try to detect a free, aviable port for console
@set CONSOLE_PORT=2323
@java -jar bin\bindtest.jar %CONSOLE_PORT% 
@if not errorlevel 0 set CONSOLE_PORT=2324
@echo console.enable=true >>freenet.ini
@echo console.port=%CONSOLE_PORT% >>freenet.ini

@echo "Downloading freenet-stable-latest.jar"
@java -jar bin\sha1test.jar freenet-stable-latest.jar "$INSTALL_PATH" > NUL
@copy freenet-stable-latest.jar freenet.jar > NUl
@echo "Downloading freenet-ext.jar"
@java -jar bin\sha1test.jar freenet-ext.jar "$INSTALL_PATH" > NUL
@echo "Downloading update.cmd"
@java -jar bin\sha1test.jar update/update.cmd "$INSTALL_PATH" > NUL
@echo "Installing the wrapper"
@echo "Registering Freenet as a system service"
@bin\wrapper-windows-x86-32.exe -i ../wrapper.conf

:: Start the node up
@net start freenet-darknet
@echo "Waiting for freenet to startup"
@ping -n 5 127.0.0.1 >nul

@echo "Spawing up a browser"
@start http://127.0.0.1:%FPROXY_PORT%/
@start welcome.html
@echo "Finished"
