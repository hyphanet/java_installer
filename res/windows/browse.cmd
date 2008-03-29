@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

:: Get the URL from the parameters if set
@set COUNT=0
@for %%x in (%*) do @( set /A COUNT=%COUNT%+1 )
@if %COUNT% GEQ 1 goto withURL
@set URL="http://127.0.0.1:8888/"
@goto doneURL
:withURL
@set URL="%1"
:doneURL

:: Check the simple case first (FF exists and has been detected)
@if not exist firefox.location goto detectff
@set /P FIREFOX=<firefox.location
@if not defined FIREFOX goto detectff
@start "" /B %FIREFOX% "file://%INSTALL_PATH%\dont-close-me.html"
@start "" /B %FIREFOX% -no-remote -P freenet "%URL%"
@goto realEnd

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
@start "" /B %FIREFOX% "file://%INSTALL_PATH%\dont-close-me.html"
@%FIREFOX% -no-remote -CreateProfile "freenet %INSTALL_PATH%\firefox_profile" > NUL
@start "" /B %FIREFOX% -no-remote -P freenet "%URL%"
@goto end

:: Firefox hasn't been detected at all
:noff
@echo The installer was unable to locate Mozilla Firefox on your computer
@del /f firefox.location
@start "%URL%"
:end
@del /f firefox.reg
:realEnd
