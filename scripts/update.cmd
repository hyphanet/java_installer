@echo off
::This script is designed for the Windows command line shell, so please don't put it into anything else! :)
::If you want to debug this script by adding pauses and stuff, please do it from another batch file, because
::if you modify this script in any way it will be detected as outdated and will be overwritten on the next run.
::To force a re-download of the latest Freenet.jar, simply delete freenet-%RELEASE%-latest.jar.url before running this script.

::The default behavior is to fetch the latest stable release.  Run this script with the testing parameter for the latest SVN build.
::  e.g. C:\Freenet\update.cmd testing

Title Freenet Update Over HTTP Script
echo -----
echo - Freenet Windows update script 1.6 by Zero3Cool (zero3cool@zerosplayground.dk)
echo - Freenet Windows update script 1.7 to 2.4 by Juiceman (juiceman69@gmail.com)
echo - Thanks to search4answers, Michael Schierl and toad for help and feedback.
echo - This script will automatically update your Freenet installation.
echo - In case of an unrecoverable error, this script will pause.
echo -----
echo -----------------------------------------------------------
echo - Please try to use the update over Freenet feature of your
echo - node to reduce traffic on our servers, thanks!!!
echo - FYI, updating over Freenet is more secure and better for
echo - your anonymity.
echo -----------------------------------------------------------
echo -----


::CHANGELOG:
:: 2.4 - Test downloaded jar after making sure it is not empty.  Copy over freenet.jar after testing for integrity.
:: 2.3 - Reduce retries to 5.  Turn on file resuming.  Clarify text.
:: 2.2 - Reduce retry delay and time between retries. 
:: 2.1 - Title, comments, hide "Please ignore, it is a side effect of a work-around" echo unless its needed.
:: 2.0 - Warn user not to abort script.
:: 1.9 - Cosmetic fixes (Spacing, typos)
:: 1.8 - Loop stop script until Node is stopped.
:: 1.7 - Retry downloads on timeout.

::Initialize some stuff
set MAGICSTRING=INDO
set CAFILE=startssl.pem
set RESTART=0
set PATH=%SYSTEMROOT%\System32\;%PATH%
set RELEASE=stable
if "%1"=="testing" set RELEASE=testing

::Go to our location
for %%I in (%0) do set LOCATION=%%~dpI
cd /D %LOCATION%

::Check if its valid, or at least looks like it
if not exist freenet.ini goto error2
if not exist bin\wget.exe goto error2

if not exist wrapper.conf.bak copy wrapper.conf wrapper.conf.bak > NUL

::Get the filename and skip straight to the Freenet update if this is a new updater
for %%I in (%0) do set FILENAME=%%~nxI
if %FILENAME%==update.new.cmd goto updaterok

::Download latest updater and verify it
if exist update.new.cmd del update.new.cmd
echo - Checking for newer version of update script...
bin\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 http://downloads.freenetproject.org/alpha/update/update.cmd -O update.new.cmd
Title Freenet Update Over HTTP Script

if not exist update.new.cmd goto error1
find "FREENET W%MAGICSTRING%WS UPDATE SCRIPT" update.new.cmd > NUL
if errorlevel 1 goto error1

find "freenet.jar" wrapper.conf > NUL
if errorlevel 1 goto error5

find "freenet.jar.new" wrapper.conf > NUL
if not errorlevel 1 goto error5

:: fix #1527
find "freenet-ext.jar.new" wrapper.conf > NUL
if not errorlevel 1 goto skipit
copy freenet-ext.jar.new freenet-ext.jar > NUL
del /F freenet-ext.jar.new
:skipit

::Check if updater has been updated
fc update.cmd update.new.cmd > NUL
if not errorlevel 1 goto updaterok

::It has! Run new version and end self
echo - Update script updated, restarting update script...
echo -----
start update.new.cmd
goto veryend


::Updater is up to date, check Freenet
:updaterok
echo - Update script is current.
echo -----

::Handle older installations where start and stop are not in the bin\ directory
if not exist bin\stop.cmd copy stop.cmd bin\stop.cmd > NUL
if not exist bin\start.cmd copy start.cmd bin\start.cmd > NUL
if not exist bin\stop.cmd goto error2
if not exist bin\start.cmd goto error2

echo - Freenet installation found at %LOCATION%
echo -----
echo - Checking for Freenet JAR updates...

::Check for sha1test and download if needed.
if not exist lib mkdir lib
if not exist lib\sha1test.jar bin\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10  http://downloads.freenetproject.org/alpha/installer/sha1test.jar -O lib\sha1test.jar
if not errorlevel 0 goto error3

if exist freenet-%RELEASE%-latest.jar.new.url del freenet-%RELEASE%-latest.jar.new.url
bin\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 http://downloads.freenetproject.org/alpha/freenet-%RELEASE%-latest.jar.url -O freenet-%RELEASE%-latest.jar.new.url
Title Freenet Update Over HTTP Script

echo Fetched new main jar

if not exist freenet-%RELEASE%-latest.jar.new.url goto error3
FOR %%I IN ("%LOCATION%freenet-%RELEASE%-latest.jar.url") DO if %%~zI==0 goto error3

::Do we have something old to compare with? If not, update right away
if not exist freenet-%RELEASE%-latest.jar.url goto update1

::Compare with current copy
fc freenet-%RELEASE%-latest.jar.url freenet-%RELEASE%-latest.jar.new.url > NUL
if not errorlevel 1 goto checkext
goto update0

:checkext
::Main jar not updated.
echo - Main jar not updated
echo - Checking ext jar
::Check for a new freenet-ext.jar.
::Unfortunately there is no .url file for it, so we have to download the whole thing.
if exist freenet-ext.jar.copy del freenet-ext.jar.copy
bin\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 http://downloads.freenetproject.org/alpha/freenet-ext.jar -O freenet-ext.jar.copy
if not exist freenet-ext.jar.copy goto error3
FOR %%I IN ("%LOCATION%freenet-ext.jar.copy") DO if %%~zI==0 goto error3
::Update anyway if doesn't exist...
if not exist freenet-ext.jar goto update1
fc freenet-ext.jar freenet-ext.jar.copy > NUL
if errorlevel 1 goto update1
del freenet-ext.jar.copy
goto noupdate

:update0
echo - Main jar updated
echo - Checking ext jar as well
::Check for a new freenet-ext.jar.
::Unfortunately there is no .url file for it, so we have to download the whole thing.
if exist freenet-ext.jar.copy del freenet-ext.jar.copy
bin\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 http://downloads.freenetproject.org/alpha/freenet-ext.jar -O freenet-ext.jar.copy
if not exist freenet-ext.jar.copy goto error3
FOR %%I IN ("%LOCATION%freenet-ext.jar.copy") DO if %%~zI==0 goto error3
if not exist freenet-ext.jar goto update1
fc freenet-ext.jar freenet-ext.jar.copy > NUL
if errorlevel 1 goto update1
del freenet-ext.jar.copy

::New version found, check if the node is currently running
:update1
echo - New version found!
echo -----

net start | find "Freenet 0.7 darknet" > NUL
if errorlevel 1 goto update2 > NUL
set RESTART=1
::Tell the user not to abort script, it gets very messy.
echo - Shutting down Freenet...   (This may take a moment, please don't abort)
call bin\stop.cmd > NUL
net start | find "Freenet 0.7 darknet" > NUL
if errorlevel 1 goto update2 > NUL
:: Uh oh, this may take a few tries.  Better tell the user not to panic.
echo -
echo - If you see an error message about: 
echo - "The service could not be controlled in its present state."
echo - Please ignore, it is a side effect of a work-around 
echo - to make sure the node is stopped before we copy files.
echo -
::Keep trying until service is stopped for sure.
:safetycheck
net start | find "Freenet 0.7 darknet" > NUL
if errorlevel 1 goto update2 > NUL
call bin\stop.cmd > NUL
goto safetycheck


::Ok Freenet is stopped, it is safe to copy files.
:update2
echo -----
echo - Downloading new version and updating local installation...

::Backup last version of Freenet-%RELEASE%-latest.jar file, we will need it if update fails.
if exist freenet-%RELEASE%-latest.jar.bak del freenet-%RELEASE%-latest.jar.bak
if exist freenet-%RELEASE%-latest.jar ren freenet-%RELEASE%-latest.jar freenet-%RELEASE%-latest.jar.bak
::Download new jar file
bin\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 -i freenet-%RELEASE%-latest.jar.new.url -O freenet-%RELEASE%-latest.jar
:: Make sure it got downloaded successfully
if not exist freenet-%RELEASE%-latest.jar goto error4
FOR %%I IN ("%LOCATION%freenet-%RELEASE%-latest.jar") DO if %%~zI==0 goto error4
::Test the new jar file for integrity.
java -cp lib\sha1test.jar Sha1Test freenet-%RELEASE%-latest.jar . %CAFILE% > NUL
if not errorlevel 0 goto error4
::Everything looks good, lets install it
copy freenet-%RELEASE%-latest.jar freenet.jar > NUL
::Prepare shortcut file for next run.
if exist freenet-%RELEASE%-latest.jar.url del freenet-%RELEASE%-latest.jar.url
ren freenet-%RELEASE%-latest.jar.new.url freenet-%RELEASE%-latest.jar.url
Title Freenet Update Over HTTP Script
::Tell user the good news.
echo   - Changing file permissions
echo Y| cacls . /E /T /C /G freenet:f 2> NUL > NUL
echo -
echo - Freenet-%RELEASE%-snapshot.jar verified and copied to freenet.jar

if not exist freenet-ext.jar.copy goto end
if exist freenet-ext.jar.bak del freenet-ext.jar.bak
if exist freenet-ext.jar ren freenet-ext.jar freenet-ext.jar.bak
ren freenet-ext.jar.copy freenet-ext.jar
java -cp lib\sha1test.jar Sha1Test freenet-ext.jar . %CAFILE% > NUL
if not errorlevel 0 goto errore4
ren freenet-ext.jar.copy freenet-ext.jar
echo Copied updated freenet-ext.jar

goto end


::No update needed
:noupdate
echo - Freenet is up to date.
goto end


::Server gave us a damaged version of the update script, tell user to try again later.
:error1
echo - Error! Downloaded update script is invalid. Try again later.
goto end


::Can't find Freenet installation
:error2
echo - Error! Please run this script from a working Freenet installation.
echo -----
pause
goto veryend

::Server may be down.
:error3
@del /F bin\netuser.exe
echo - Error! Could not download latest Freenet update information. Try again later.
goto end

::Corrupt file was downloaded, restore from backup.
:error4
echo - Error! Freenet update failed, trying to restore backup...
if exist freenet-%RELEASE%-latest.jar del freenet-%RELEASE%-latest.jar
if exist freenet-%RELEASE%-latest.jar.bak ren freenet-%RELEASE%-latest.jar.bak freenet-%RELEASE%-latest.jar
if exist freenet-%RELEASE%-latest.jar.url del freenet-%RELEASE%-latest.jar.url
goto end

:Corrupt ext jar was downloaded, restore from backup
:errore4
echo Error! freenet-ext.jar update failed, trying to restore backup...
if exist freenet-ext.jar del freenet-ext.jar
if exist freenet-ext.jar.bak ren freenet-ext.jar.bak freenet-ext.jar
goto end

::Wrapper.conf is old, downloading new version and restarting update script
:error5
echo - Your wrapper.conf needs to be updated .... updating it ; please restart the script when done.
if exist wrapper.conf.bak del wrapper.conf.bak
if exist wrapper.conf ren wrapper.conf wrapper.conf.bak
bin\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 http://downloads.freenetproject.org/alpha/update/wrapper.conf -O wrapper.conf
if exist wrapper.password type wrapper.password >> wrapper.conf
start update.new.cmd
goto veryend

::Cleanup and restart if needed.
:end
echo -----
echo - Cleaning up...
if exist freenet-%RELEASE%-latest.jar.new.url del freenet-%RELEASE%-latest.jar.new.url
if exist freenet-%RELEASE%-latest.jar.bak del freenet-%RELEASE%-latest.jar.bak

:: Maybe fix bug #2556
echo   - Changing file permissions
echo Y| cacls . /E /T /C /G freenet:f 2> NUL > NUL

if %RESTART%==0 goto cleanup2
echo - Restarting Freenet...
call bin\start.cmd > NUL


:cleanup2
if %FILENAME%==update.new.cmd goto newend
if exist update.new.cmd del update.new.cmd
echo -----
goto veryend


::If this session was launched by an old updater, replace it now (and force exit, or we will leave a command prompt open)
:newend
copy /Y update.new.cmd update.cmd > NUL
echo -----
exit


:veryend
::FREENET WINDOWS UPDATE SCRIPT
