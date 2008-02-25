@set PATH=%SYSTEMROOT%\System32\;%PATH%
@cd "$INSTALL_PATH\Uninstaller"

:ask
@set /P X= Do you really want to uninstall Freenet (Y/N)?
@if /I "%X%"=="Y" goto begin
@if /I "%X%"=="N" goto end
@goto ask

:begin
@echo The uninstaller has been started, please hold on
@echo Unregistering the system service
@"../bin/wrapper-windows-x86-32.exe" -r ../wrapper.conf 
@echo Deleting the freenet user
@"../bin/ntrights.exe" -u freenet -r SeServiceLogonRight > NUL
@"../bin/ntrights.exe" -u freenet -r SeIncreaseBasePriorityPrivilege > NUL
@"../bin/ntrights.exe" -u freenet -r SeDenyNetworkLogonRight > NUL
@"../bin/ntrights.exe" -u freenet -r SeDenyInteractiveLogonRight > NUL
@net user freenet /delete > NUL 2> NUL
@echo Cleaning up the registry
@echo Windows Registry Editor Version 5.00 >> fref.reg
@echo [-HKEY_CLASSES_ROOT\.fref] >> fref.reg
@echo [-HKEY_CLASSES_ROOT\fref_auto_file] >> fref.reg
@echo [-HKEY_LOCAL_MACHINE\Software\Microsoft\WindowsNT\CurrentVersion\Winlogon\SpecialAccounts\UserList\freenet] >> fref.reg
@regedit /s fref.reg > NUL
@del /F fref.reg > NUL

:: needed otherwise the directory isn't deleted
@cd c:\
@echo Actually remove the files
@javaw -jar "$INSTALL_PATH\Uninstaller\uninstaller.jar" -c -f

:end
@pause
