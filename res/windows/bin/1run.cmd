@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@echo "Registering .fref file extention"
@echo Windows Registry Editor Version 5.00 >> fref.reg
@echo [HKEY_CLASSES_ROOT\.fref] >> fref.reg
@echo @="fref_auto_file" >> fref.reg
@echo [HKEY_CLASSES_ROOT\fref_auto_file] >> fref.reg
@echo @="Freenet node reference" >> fref.reg
@echo "EditFlags"=dword:00000000 >> fref.reg
@echo "BrowserFlags"=dword:00000008 >> fref.reg
@echo [HKEY_CLASSES_ROOT\fref_auto_file\DefaultIcon] >> fref.reg
@echo @="shell32.dll,56" >> fref.reg
@echo [HKEY_CLASSES_ROOT\fref_auto_file\shell] >> fref.reg
@echo @="Open" >> fref.reg
:: We need to double escape it ... it doesn't work so let's try something else :p ... FTYPE
:: @echo [HKEY_CLASSES_ROOT\fref_auto_file\shell\Connect] >> fref.reg
:: @echo [HKEY_CLASSES_ROOT\fref_auto_file\shell\Connect\command] >> fref.reg
:: @echo @="\"%JAVA%\\bin\\java.exe\"  \"-cp\"  \"%INST%\\freenet.jar\" \"freenet.support.AddRef\" \"%%1\"" >> fref.reg
@regedit /s fref.reg > NUL
@FTYPE fref_auto_file="$JAVA_HOME\bin\javaw.exe" -cp "$INSTALL_PATH\freenet.jar" freenet.tools.AddRef "%%1" > NUL
@del /F fref.reg

@echo "Setting up plugins"
:: Tweak freenet.ini
@if not exist stun goto nostun 
@set PLUGINS=plugins.JSTUN@file:///%INSTALL_PATH%\plugins\JSTUN.jar;%PLUGINS%
@mkdir plugins > NUL
@java -jar bin\sha1test.jar JSTUN.jar plugins > NUL
@del /F stun > NUL
:nostun

@if not exist librarian goto nolibrarian 
@mkdir plugins > NUL
@set PLUGINS=plugins.Librarian@file:///%INSTALL_PATH%\plugins\Librarian.jar;%PLUGINS%
@java -jar bin\sha1test.jar plugins/Librarian.jar.url plugins > NUL
@copy plugins\Librarian.jar.url plugins\Librarian.jar > NUL
@del /F librarian > NUL
:nolibrarian

@echo pluginmanager.loadplugin=%PLUGINS% >> freenet.ini

@if exist update echo node.updater.autoupdate=true >> freenet.ini
@del /F update > NUL

@echo "Detecting tcp port availability"
:: Try to detect a free, available port for fproxy
@set FPROXY_PORT=8888
@java -jar bin\bindtest.jar %FPROXY_PORT% 
@IF NOT ERRORLEVEL 1 GOTO configure_fproxy
@set FPROXY_PORT=8889
@bin\cat.exe welcome.html | bin\sed.exe "s/8888/%FPROXY_PORT%/g" > welcome2.html
@move /Y welcome2.html welcome.html > NUL
:configure_fproxy
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

@echo "Downloading update.cmd"
@java -jar bin\sha1test.jar update/update.cmd . > NUL
@echo "Downloading freenet-ext.jar"
@java -jar bin\sha1test.jar freenet-ext.jar . > NUL
@echo "Downloading freenet-stable-latest.jar"
@java -jar bin\sha1test.jar freenet-stable-latest.jar . > NUL
@copy freenet-stable-latest.jar freenet.jar > NUl
@echo "Installing the wrapper"
@echo "Registering Freenet as a system service"
::
:: It's likely that a node has already been set up; handle it
@bin\cat.exe wrapper.conf | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > wrapper2.conf 
@move /Y wrapper2.conf wrapper.conf > NUL

@bin\cat bin\install_service.bat | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > install_service.bat
@move /Y install_service.bat bin\install_service.bat

@bin\cat bin\remove_service.bat | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > remove_service.bat
@move /Y remove_service.bat bin\remove_service.bat

@bin\cat bin\start.cmd | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > start.cmd
@move /Y start.cmd bin\start.cmd

@bin\cat bin\stop.cmd | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > stop.cmd
@move /Y stop.cmd bin\stop.cmd

@bin\wrapper-windows-x86-32.exe -r ../wrapper.conf > NUL
@bin\wrapper-windows-x86-32.exe -i ../wrapper.conf

:: Start the node up
@net start freenet-darknet-%FPROXY_PORT%
@echo "Waiting for freenet to startup"
@ping -n 5 127.0.0.1 >nul

@echo "Spawing up a browser"
@start http://127.0.0.1:%FPROXY_PORT%/
@start welcome.html

:: Installing additionnal softwares
@if not exist jsite goto nojsite 
@del /F jsite > NUL
@echo "Downloading jSite"
@java -jar bin\sha1test.jar jSite/jSite.jar . > NUL
:nojsite

@if not exist thaw goto nothaw 
@del /F thaw > NUL
@echo "Downloading Thaw"
@java -jar bin\sha1test.jar Thaw/Thaw.jar . > NUL
:nothaw

@if not exist frost goto nofrost 
@del /F frost > NUL
@echo "Downloading Frost"
@java -jar bin\sha1test.jar frost/frost.zip . > NUL
@echo "Setting Frost up"
@mkdir frost
@java -jar bin\uncompress.jar frost.zip frost > NUL
:nofrost

@echo "Finished"
