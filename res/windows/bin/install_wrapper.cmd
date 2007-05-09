@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@echo "Detecting tcp port availability"
:: Try to detect a free, available port for fproxy
@set FPROXY_PORT=8888
@java -jar bin\bindtest.jar %FPROXY_PORT% 
@if errorlevel 0 goto configure_fproxy
@set FPROXY_PORT=8889
@bin\cat.exe welcome.html | bin\sed.exe "s/8888/%FPROXY_PORT%/g" > welcome2.html
@move /Y welcome2.html welcome.html > NUL
:configure_fproxy
@echo fproxy.enable=true >>freenet.ini
@echo fproxy.port=%FPROXY_PORT% >>freenet.ini

:: Create a script for the "browse shortcut"
@echo @start http://127.0.0.1:%FPROXY_PORT%/ > browse.cmd

:: Try to detect a free, available port for fcp
@set FCP_PORT=9481
@java -jar bin\bindtest.jar %FCP_PORT% 
@if not errorlevel 0 set FCP_PORT=9482
@echo fcp.enable=true >>freenet.ini
@echo fcp.port=%FCP_PORT% >>freenet.ini

:: Try to detect a free, available port for console
@set CONSOLE_PORT=2323
@java -jar bin\bindtest.jar %CONSOLE_PORT% 
@if not errorlevel 0 set CONSOLE_PORT=2324
@echo console.enable=true >>freenet.ini
@echo console.port=%CONSOLE_PORT% >>freenet.ini


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

@echo "Installing the wrapper"
@echo 	- Creating a user for freenet
:: A ugly hack to workaround password policy enforcements
@set PASSWORD=%random%%random%
:: remove the user, just in case...
@net user freenet /delete > NUL
@net user freenet %PASSWORD% /add /comment:"this user is used by freenet: do NOT delete it!" /expires:never /passwordchg:no /fullname:"Freenet dedicated user" > NUL
@if errorlevel 0 goto pwgenerated
@echo "Error while creating the freenet user! let's try something else..."
:: try with a better password
@set PASSWORD=Freenet_0@%PASSWORD%-
@net user freenet %PASSWORD% /add /comment:"this user is used by freenet: do NOT delete it!" /expires:never /passwordchg:no /fullname:"Freenet dedicated user"
@if errorlevel 0 goto pwgenerated
:: We shouldn't reach that point
@echo "The workaround is still not working! will install freenet to run as SYSTEM"
@goto registerS
:pwgenerated
@echo wrapper.ntservice.password=%PASSWORD%>> wrapper.password
@type wrapper.password >> wrapper.conf

@echo 	- Hiding the freenet user from the login screen
@echo Windows Registry Editor Version 5.00 >> hide_user.reg
@echo [HKEY_LOCAL_MACHINE\Software\Microsoft\WindowsNT\CurrentVersion\Winlogon\SpecialAccounts\UserList] >> hide_user.reg
@echo "freenet"=dword:00000000 >> hide_user.reg
@regedit /s hide_user.reg > NUL
@del /F hide_user.reg > NUL

@echo 	- Tweaking the permissions of the freenet user
:: yes it belongs to the ressource kit... But the licence specifies that it's redistribuable.
@bin\ntrights.exe -u freenet +r SeServiceLogonRight > NUL
@bin\ntrights.exe -u freenet -r SeDenyServiceLogonRight > NUL
@bin\ntrights.exe -u freenet +r SeIncreaseBasePriorityPrivilege > NUL
@bin\ntrights.exe -u freenet +r SeDenyNetworkLogonRight > NUL
@bin\ntrights.exe -u freenet +r SeDenyInteractiveLogonRight > NUL
@bin\ntrights.exe -u freenet -r SeShutdownPrivilege > NUL

@echo 	- Changing file permissions
@cacls . /E /T /C /G freenet:f 2> NUL > NUL
:registerS
@echo 	- Registering Freenet as a system service

:: It's likely that a node has already been set up; handle it
@bin\wrapper-windows-x86-32.exe -r ../wrapper.conf > NUL
@bin\wrapper-windows-x86-32.exe -i ../wrapper.conf

:: Start the node up
@echo 	- Start the node up
@net start freenet-darknet-%FPROXY_PORT%

@echo "Spawning up a browser"
@start http://127.0.0.1:%FPROXY_PORT%/
@start welcome.html
