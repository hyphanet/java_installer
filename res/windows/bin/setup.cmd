@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@echo Registering .fref file extension
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

:: Are we in offline mode ?
@if exist offline echo "Offline installation mode"
:end
