@echo off
::This script is designed for the Windows command line shell, so please don't put it into anything else! :)
::If you want to debug this script by adding pauses and stuff, please do it from another batch file, because
::if you modify this script in any way it will be detected as outdated and will be overwritten on the next run.
::To force a re-download of the latest Freenet .jar, simply delete freenet-cvs-snapshot.jar.url before running this script.
echo -----
echo - Freenet Windows update script 1.6 by Zero3Cool (zero3cool@zerosplayground.dk)
echo - Thanks to search4answers, Michael Schierl and toad for help and feedback.
echo - This script will automatically update your Freenet installation.
echo - In case of an unrecoverable error, this script will pause.
echo -----

::Initialize some stuff
set MAGICSTRING=INDO
set RESTART=0
set PATH=%SYSTEMROOT%\System32\;%PATH%

::Go to our location
for %%I in (%0) do set LOCATION=%%~dpI
cd %LOCATION%

::Check if its valid, or at least looks like it
if not exist freenet.ini goto error2
if not exist bin\wget.exe goto error2
echo - Freenet installation found at %LOCATION%
echo -----

::Get the filename and skip straight to the Freenet update if this is a new updater
for %%I in (%0) do set FILENAME=%%~nxI
if %FILENAME%==update.new.cmd goto updaterok

::Download latest updater and verify it
if exist update.new.cmd del update.new.cmd
echo - Checking for updater updates...
bin\wget.exe -o NUL https://emu.freenetproject.org/svn/trunk/apps/installer/installclasspath/windows/update.cmd -O update.new.cmd
if not exist update.new.cmd goto error1
find "FREENET W%MAGICSTRING%WS UPDATE SCRIPT" update.new.cmd > NUL
if errorlevel 1 goto error1

::Check if updater has been updated
fc update.cmd update.new.cmd > nul
if not errorlevel 1 goto updaterok

::It has! Run new version and end self
echo - Updater updated, restarting update...
echo -----
start update.new.cmd
goto veryend

::Updater is up to date, check Freenet
:updaterok
echo - Updater is up to date.
echo -----
echo - Checking for Freenet updates...
if exist freenet-cvs-snapshot.jar.new.url del freenet-cvs-snapshot.jar.new.url
bin\wget.exe -o NUL http://downloads.freenetproject.org/alpha/freenet-cvs-snapshot.jar.url -O freenet-cvs-snapshot.jar.new.url
if not exist freenet-cvs-snapshot.jar.new.url goto error3
FOR %%I IN ("%LOCATION%freenet-cvs-snapshot.jar.url") DO if %%~zI==0 goto error3

::Do we have something old to compare with? If not, update right away
if not exist freenet-cvs-snapshot.jar.url goto updatefreenet

::Compare with current copy
fc freenet-cvs-snapshot.jar.url freenet-cvs-snapshot.jar.new.url > nul
if not errorlevel 1 goto noupdate

::New version found, check if the node is currently running
:updatefreenet
echo - New version found!
net start | find "Freenet" > NUL
if errorlevel 1 goto updatefreenet2 > NUL
set RESTART=1
echo - Shutting down Freenet...
call stop.cmd > NUL

:updatefreenet2
echo - Downloading new version and updating local installation...
if exist freenet-cvs-snapshot.jar ren freenet-cvs-snapshot.jar freenet-cvs-snapshot.bak.jar
bin\wget.exe -o NUL -i freenet-cvs-snapshot.jar.new.url -O freenet-cvs-snapshot.jar
if not exist freenet-cvs-snapshot.jar goto error4
FOR %%I IN ("%LOCATION%freenet-cvs-snapshot.jar") DO if %%~zI==0 goto error4
if exist freenet-cvs-snapshot.jar.url del freenet-cvs-snapshot.jar.url
ren freenet-cvs-snapshot.jar.new.url freenet-cvs-snapshot.jar.url
echo - Freenet updated.
goto end

:noupdate
echo - Freenet is up to date.
goto end

:error1
echo - Error! Downloaded update script is invalid. Try again later.
goto end

:error2
echo - Error! Please run this script from a working Freenet installation.
echo -----
pause
goto veryend

:error3
echo - Error! Could not download latest Freenet update information. Try again later.
goto end

:error4
echo - Error! Freenet update failed, trying to restore backup...
if exist freenet-cvs-snapshot.jar del freenet-cvs-snapshot.jar
if exist freenet-cvs-snapshot.bak.jar ren freenet-cvs-snapshot.bak.jar freenet-cvs-snapshot.jar
goto end

:end
echo -----
echo - Cleaning up...
if exist freenet-cvs-snapshot.jar.new.url del freenet-cvs-snapshot.jar.new.url
if exist freenet-cvs-snapshot.bak.jar del freenet-cvs-snapshot.bak.jar

if %RESTART%==0 goto cleanup2
echo - Restarting Freenet...
call start.cmd > NUL

:cleanup2
if %FILENAME%==update.new.cmd goto newend
if exist update.new.cmd del update.new.cmd
echo -----
goto veryend

::If this session was launched by an old updater, replace it now (and force exit, or we will leave a command promt open)
:newend
copy /Y update.new.cmd update.cmd > NUL
echo -----
exit

:veryend
::FREENET WINDOWS UPDATE SCRIPT
