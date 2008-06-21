@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@set ISO3_LANG=$ISO3_LANG
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@echo Detecting tcp port availability
:: Try to detect a free, available port for fproxy
@set FPROXY_PORT=8888
@java -jar bin\bindtest.jar %FPROXY_PORT% 
@if %ERRORLEVEL% EQU 0 goto configure_fproxy
@set FPROXY_PORT=8889

@set DONTCLOSE_FILE=dont-close-me.html
@if not exist dont-close-me.%ISO3_LANG%.html goto noDl10n
@set DONTCLOSE_FILE=dont-close-me.%ISO3_LANG%.html
:noDl10n
@bin\cat.exe %DONTCLOSE_FILE% | bin\sed.exe "s/8888/%FPROXY_PORT%/g" > _dont-close-me.html
@del /F /Q dont-close-me.*html
@move /Y _dont-close-me.html dont-close-me.html > NUL

@bin\cat.exe browse.cmd | bin\sed.exe "s/8888/%FPROXY_PORT%/g" > browse2.cmd
@move /Y browse2.cmd browse.cmd > NUL

:configure_fproxy
@echo fproxy.enable=true>>freenet.ini
@echo fproxy.port=%FPROXY_PORT%>>freenet.ini
@echo fproxy.enablePersistentConnections=true>>freenet.ini
@echo node.l10n=%ISO3_LANG%>>freenet.ini

:: Try to detect a free, available port for fcp
@set FCP_PORT=9481
@java -jar bin\bindtest.jar %FCP_PORT% 
@if %ERRORLEVEL% NEQ 0 set FCP_PORT=9482
@echo fcp.enable=true >>freenet.ini
@echo fcp.port=%FCP_PORT% >>freenet.ini

@bin\cat.exe wrapper.conf | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > wrapper2.conf 
@move /Y wrapper2.conf wrapper.conf > NUL

@bin\cat.exe bin\install_service.bat | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > install_service.bat
@move /Y install_service.bat bin\install_service.bat

@bin\cat.exe bin\remove_service.bat | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > remove_service.bat
@move /Y remove_service.bat bin\remove_service.bat

@bin\cat.exe bin\start.cmd | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > start.cmd
@move /Y start.cmd bin\start.cmd

@bin\cat.exe bin\stop.cmd | bin\sed.exe "s/darknet/darknet-%FPROXY_PORT%/g" > stop.cmd
@move /Y stop.cmd bin\stop.cmd

@echo Installing the wrapper
@if exist autostart.install goto startupPolicyChanged
@echo 	- Changing the startup policy of the freenet daemon to on-demand
@bin\cat.exe wrapper.conf | bin\sed.exe "s/wrapper.ntservice.starttype=AUTO_START/wrapper.ntservice.starttype=DEMAND_START/g" > autostart.install
@move /Y autostart.install wrapper.conf
:startupPolicyChanged
@echo 	- Creating a user for freenet
:: A ugly hack to workaround password policy enforcements
@set TMPPASSWORD=%random%%random%
:: trim to 12 chars (13 chars and above passwords aren't backcompatible; a warning might get displayed)
@set PASSWORD=%TMPPASSWORD:~0,12%
:: remove the user, just in case...
@net user freenet /delete 2> NUL > NUL
:: create the user
@net user freenet %PASSWORD% /add /comment:"this user is used by freenet: do NOT delete it!" /expires:never /passwordchg:no /fullname:"Freenet dedicated user" > NUL
@if %ERRORLEVEL% EQU 0 goto pwgen
@echo Error while creating the freenet user! let's try something else...
:: try with a stronger password
@set TMPPASSWORD=Freenet_0@%PASSWORD%-
@set PASSWORD=%TMPPASSWORD:~0,12%
@net user freenet %PASSWORD% /add /comment:"this user is used by freenet: do NOT delete it!" /expires:never /passwordchg:no /fullname:"Freenet dedicated user"
@if %ERRORLEVEL% EQU 0 goto pwgen
:: We shouldn't reach that point
@echo The workaround is still not working! will install freenet to run as SYSTEM
@goto registerS

:pwgen
:: We don't want the password to expire
:: FIXME: what about that 3rd party code I haven't audited yet ? - Consider using something else
@bin\netuser.exe freenet /pwnexp:y > NUL
@echo wrapper.ntservice.account=.\freenet >> wrapper.conf
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

@echo End >> freenet.ini
:: It's likely that a node has already been set up; handle it
@bin\wrapper-windows-x86-32.exe -r ../wrapper.conf > NUL
@bin\wrapper-windows-x86-32.exe -i ../wrapper.conf

:: Start the node up
@echo 	- Start the node up
@net start freenet-darknet-%FPROXY_PORT%

@start "" /B "browse.cmd" http://127.0.0.1:%FPROXY_PORT%/wizard/
:endl10n
:end
