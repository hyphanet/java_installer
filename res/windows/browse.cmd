@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@set COUNT=0
@for %%x in (%*) do ( @set /A COUNT=!COUNT!+1 )
@if %COUNT% LSS 1 @set URL=http://127.0.0.1:8888/ else @set URL=%1

:: Check the simple case first (FF exists and has been detected)
@set /P FIREFOX=<firefox.location
@if not defined FIREFOX goto detectff
@%FIREFOX% -no-remote -p freenet "%URL%"
@exit

:detectff
@echo Detecting the location of Firefox
@regedit /E firefox.reg "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe"
:: No I didn't find any better regexp I could do without cote-escaping.
:: bin\cat.exe firefox.reg | find "@=" | bin\sed.exe "s/""/|/g" | bin\sed.exe "s/.*|\(.*\)|/\1/" | bin\sed.exe "s/\\\\/\\/g" > firefox.location
@bin\cat.exe firefox.reg | find "@=" | bin\sed.exe s/@="\(.*\)"/\1/ | bin\sed.exe "s/\\\\/\\/g" > firefox.location
@set /P FIREFOX=<firefox.location
@if not defined FIREFOX goto noff

:: creation of the profile
@echo Creating a Firefox profile for freenet
@%FIREFOX% -no-remote -CreateProfile "freenet %INSTALL_PATH%\firefox_profile" > NUL
@%FIREFOX% -no-remote -p freenet "%URL%"
@goto end

:: Firefox hasn't been detected at all
:noff
@echo The installer was unable to locate Mozilla Firefox on your computer
@del /f firefox.location
@start "%URL%"
:end
@del /f firefox.reg
