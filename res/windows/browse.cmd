@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

:: Get the URL from the parameters if set
@set COUNT=0
@for %%x in (%*) do @( set /A COUNT=%COUNT%+1 )
@if %COUNT% GEQ 1 goto withURL
@set /P URL=<freenet.url.dat
@goto doneURL
:withURL
@set URL="%1"
:doneURL

:: Loop until the install process is over
:beforeLoop
@if exist Uninstaller/install.log goto begin
@ping -n 1 127.0.0.1>NUL
@goto beforeLoop
:begin

:: Use firefox if available, since on Windows the most likely alternative is IE, and that definitely has problems with Freenet

:: Check the simple case first (FF exists and has been detected)
@if not exist firefox.location goto detectff
@set /P FIREFOX=<firefox.location
@if not defined FIREFOX goto detectff
@start "" /B %FIREFOX% "%URL%"
@goto realEnd

:detectff
@echo Detecting the location of Firefox
@regedit /E firefox.reg "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe"
:: No I didn't find any better regexp I could do without cote-escaping.
:: bin\cat.exe firefox.reg | find "@=" | bin\sed.exe "s/""/|/g" | bin\sed.exe "s/.*|\(.*\)|/\1/" | bin\sed.exe "s/\\\\/\\/g" > firefox.location
@if not exist firefox.reg goto maybeff
@bin\cat.exe firefox.reg | find "@=" | bin\sed.exe s/@="\(.*\)"/\1/ | bin\sed.exe "s/\\\\/\\/g" > firefox.location
@set /P FIREFOX=<firefox.location
@if not defined FIREFOX goto maybeff
@if exist %FIREFOX% goto foundff
@echo Found Firefox in the registry at "%FIREFOX%" but the file does not exist

:maybeff
:: Try to detect firefox by checking standard locations.
@if not exist "%ProgramFiles%\Mozilla Firefox\firefox.exe" goto maybe1
@set FIREFOX="%ProgramFiles%\Mozilla Firefox\firefox.exe"
@echo "%ProgramFiles%\Mozilla Firefox\firefox.exe" > firefox.location
@goto foundff
:maybe1
@if not exist "c:\Program Files\Mozilla Firefox\firefox.exe" goto noff
@set FIREFOX="c:\Program Files\Mozilla Firefox\firefox.exe"
@echo "c:\Program Files\Mozilla Firefox\firefox.exe" > firefox.location

:foundff
@start "" /B %FIREFOX% "%URL%"
@goto end

:: Firefox hasn't been detected at all
:noff
@del /f firefox.location
@echo Trying to open "%URL%"
@start "" "%URL%"
@if errorlevel 1 goto argh
@goto end
:argh
@echo Starting the page failed, attempting to load directly in IE
@echo Do not use Internet Explorer to browse Freenet, it has serious security problems
@echo Please install an alternative browser ASAP
@start "" /B "%ProgramFiles%\Internet Explorer\iexplore.exe" "%URL%"
:end
@del /f firefox.reg
:realEnd
