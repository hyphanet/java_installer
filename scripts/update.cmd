@ECHO off
::This script is designed for the Windows command line shell, so please don't put it into anything else! :)
::This script may need to be run with administrator privileges.

::If you want to debug this script by adding pauses and stuff, please do it from another batch file, because
::if you modify this script in any way it will be detected as outdated and will be overwritten on the next run.
::To force a re-download of the latest Freenet.jar, simply delete freenet-%RELEASE%-latest.jar.url before running this script.

::The default behavior is to fetch the latest stable release.  Run this script with the testing parameter for the latest SVN build.
::  e.g. C:\Freenet\update.cmd testing

TITLE Freenet Update Over HTTP Script
ECHO -----
ECHO - Freenet Windows update script 1.6 by Zero3Cool (zero3cool@zerosplayground.dk)
ECHO - Further contributions by Juiceman (juiceman69@gmail.com)
ECHO - Thanks to search4answers, Michael Schierl and toad for help and feedback.
ECHO -----
ECHO - This script will automatically update your Freenet installation
ECHO - from our web server freenetproject.org and/or mirrors.
ECHO - In case of an unrecoverable error, this script will pause.
ECHO -----
ECHO -----------------------------------------------------------
ECHO - Please try to use the update over Freenet feature of your
ECHO - node to reduce traffic on our servers, thanks!!!
ECHO - FYI, updating over Freenet is easy, more secure and
ECHO - is better for your anonymity.
ECHO -----------------------------------------------------------
ECHO -----

:: TODO:
:: Fixme: what to do with changing away from custom freenet user account?

:: CHANGELOG:
:: 3.5 - Script will handle all the binaries as soon as the website is ready
:: 3.4 - Made script more failsafe.
:: 3.3 - Refactored script to be more organized and prepare for updating Windows binaries
:: 3.2 - Use the .sha1 url to check for updates to freenet-ext.jar.  Saves ~4mb per run.
:: 3.1 - Fix permissions by fixing invalid cacls arguments
:: 3.0 - Handle binary start/stop.exe exit conditions and use it to set restart flag.
:: 2.9 - Check for file permissions
:: 2.8 - Add detecting of Vista\Seven, use the appropriate version of cacls.
:: 2.7 - Better error handling
:: 2.6 - Prepare for new binary start and stop.exe's
:: ---   Many various changes
:: 2.4 - Test downloaded jar after making sure it is not empty.  Copy over freenet.jar after testing for integrity.
:: 2.3 - Reduce retries to 5.  Turn on file resuming.  Clarify text.
:: 2.2 - Reduce retry delay and time between retries.
:: 2.1 - Title, comments, hide "Please ignore, it is a side effect of a work-around" ECHO unless its needed.
:: 2.0 - Warn user not to abort script.
:: 1.9 - Cosmetic fixes (Spacing, typos)
:: 1.8 - Loop stop script until Node is stopped.
:: 1.7 - Retry downloads on timeout.

::Initialize some stuff
SET MAGICSTRING=INDO
SET CAFILE=startssl.pem
SET RESTART=0

::  For these variables 0 means nothing to do, 1 means success or yes, 2 indicates an error condition
SET MAINJARUPDATED=0
SET EXTJARUPDATED=0
SET WRAPPEREXEUPDATED=0
SET WRAPPERDLLUPDATED=0
SET STARTEXEUPDATED=0
SET STOPEXEUPDATED=0
SET TRAYUTILITYUPDATED=0
SET LAUNCHERUPDATED=0
SET LAUNCHERUPDATEDNEW=0
SET SEEDUPDATED=0

SET SKIPWARNING=no
SET COUNT=0
SET PATH=%SYSTEMROOT%\System32\;%PATH%

SET NEWINSTALL=0
:: Check for the lastest install method and adapt
IF EXIST installlayout.dat SET NEWINSTALL=1

SET WRAPPER=wrapper.conf
SET WRAPPERBAK=wrapper.conf.bak
IF %NEWINSTALL%==1 SET WRAPPER=wrapper\wrapper.conf
IF %NEWINSTALL%==1 SET WRAPPERBAK=wrapper\wrapper.conf.bak

::  Accept flags from command line
SET RELEASE=stable
::Check if we were launched by the GUI. If so there is no need to warn user about connecting to our website.
IF "%1"=="testinggui" SET RELEASE=testing
IF "%1"=="testinggui" SET SKIPWARNING=yes
IF "%1"=="stablegui" SET RELEASE=stable
IF "%1"=="stablegui" SET SKIPWARNING=yes

IF "%1"=="testing" SET RELEASE=testing
IF "%1"=="-testing" SET RELEASE=testing
IF "%1"=="/testing" SET RELEASE=testing

ECHO - Release selected is: %RELEASE%
ECHO -----

IF %SKIPWARNING%==yes GOTO promptloop1out

::Warn user this script will contact our servers over the non-anoymous internet.
ECHO *******************************************************************
ECHO * This script will connect to the Freenetproject.org servers
ECHO * and/or its mirrors over the regular internet.
ECHO * This is not anonymous!
ECHO *******************************************************************
:promptloop1
::Set ANSWER1 to a different variable so it won't bug out when we loop
SET ANSWER1==X
ECHO -
ECHO - Do you wish to continue?
SET /P ANSWER1=- Press Y to continue or N to quit.
IF /i %ANSWER1%==Y GOTO promptloop1out
IF /i %ANSWER1%==N GOTO veryend
::User hit a wrong key or <enter> without selecting, go around again.
GOTO promptloop1
:promptloop1out

::Check if we are on Vista/Seven if so we need to use icacls instead of cacls
SET VISTA=0
::Treat server 2k3/XP64 as vista as they need icacls
VER | FINDSTR /l "5.2." > NUL
IF %ERRORLEVEL% EQU 0 SET VISTA=1
::Vista?
VER | FINDSTR /l "6.0." > NUL
IF %ERRORLEVEL% EQU 0 SET VISTA=1
::Seven?
VER | FINDSTR /l "6.1." > NUL
IF %ERRORLEVEL% EQU 0 SET VISTA=1

::Go to our location
FOR %%I IN (%0) DO SET LOCATION=%%~dpI
CD /D "%LOCATION%"

::The newest installer changes directory structures, we will make ours make it match now
IF NOT EXIST updater MKDIR updater
IF EXIST bin\wget.exe MOVE /Y bin\wget.exe updater > NUL
IF EXIST lib\sha1test.jar MOVE /Y lib\sha1test.jar updater > NUL
IF EXIST startssl.pem MOVE /Y startssl.pem updater > NUL

::Check if its valid, or at least looks like it
IF NOT EXIST updater\wget.exe GOTO error2
IF EXIST freenet.ini GOTO permcheck
::User may have a corrupted install from our temp file bug.  Let's try to recover.
::If no tmp file, no use trying
IF NOT EXIST freenet.ini.tmp GOTO error2
REN freenet.ini.tmp freenet.ini

:permcheck
::Simple test to see if we have enough privileges to modify files.
ECHO - Checking file permissions
IF EXIST writetest DEL writetest > NUL
IF EXIST writetest GOTO writefail
ECHO test > writetest
IF NOT EXIST writetest GOTO writefail
DEL writetest > NUL
IF EXIST writetest GOTO writefail

::Kludge to disable setting file permissions on the the deprecated custom user "freenet"
IF EXIST bin\freenettray.exe SET VISTA=2
IF %NEWINSTALL%==1 SET VISTA=2

:: Maybe fix bug #2556
ECHO - Changing file permissions
IF %VISTA%==0 ECHO Y| CACLS . /E /T /C /G freenet:f > NUL
IF %VISTA%==1 ECHO y| ICACLS . /grant freenet:(OI)(CI)F /T /C > NUL

::Get the filename and skip straight to the Freenet update if this is a new updater
FOR %%I IN (%0) DO SET FILENAME=%%~nxI
IF %FILENAME%==update.new.cmd GOTO updaterok

::New folder for keeping our temp files for this updater.
IF NOT EXIST update_temp MKDIR update_temp

::Download latest updater and verify it
IF EXIST update_temp\update.new.cmd DEL update_temp\update.new.cmd
ECHO - Checking for newer version of this update script...
updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://downloads.freenetproject.org/alpha/update/update-new.cmd -O update_temp\update.new.cmd
TITLE Freenet Update Over HTTP Script

IF NOT EXIST update_temp\update.new.cmd GOTO error1
FIND "FREENET W%MAGICSTRING%WS UPDATE SCRIPT" update_temp\update.new.cmd > NUL
IF ERRORLEVEL 1 GOTO error1

::Check if updater has been updated
FC update.cmd update_temp\update.new.cmd > NUL
IF not ERRORLEVEL 1 GOTO updaterok

::It has! Run new version and end self
ECHO - New update script found, restarting update script...
ECHO -----
COPY /Y update_temp\update.new.cmd update.new.cmd > NUL
START update.new.cmd %RELEASE%
GOTO veryend

::Updater is up to date, check Freenet
:updaterok
ECHO    - Update script is current.
ECHO -----

:: Check for dependencies.
:: Check for bcprov-jdk15on-147.jar
:: Necessary to run 1422 and later.

IF NOT EXIST bcprov-jdk15on-147.jar updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 https://downloads.freenetproject.org/alpha/deps/bcprov-jdk15on-147.jar -O bcprov-jdk15on-147.jar

FIND "bcprov-jdk15on-147.jar" %WRAPPER% > NUL
IF NOT ERRORLEVEL 1 GOTO checkeddeps
:: We can simply append to wrapper.conf, no need to clobber it.
ECHO wrapper.java.classpath.3=bcprov-jdk15on-147.jar >> %WRAPPER%

:checkeddeps

FIND "freenet.jar" %WRAPPER% > NUL
IF ERRORLEVEL 1 GOTO error5

FIND "freenet.jar.new" %WRAPPER% > NUL
IF NOT ERRORLEVEL 1 GOTO error5

:: fix #1527
FIND "freenet-ext.jar.new" %WRAPPER% > NUL
IF ERRORLEVEL 1 GOTO skipit
IF NOT EXIST freenet-ext.jar.new GOTO skipit
IF EXIST freenet-ext.jar DEL /F freenet-ext.jar > NUL
COPY freenet-ext.jar.new freenet-ext.jar > NUL
:: Try to delete the file.  If the node is running, it will likely fail.
IF EXIST freenet-ext.jar.new DEL /F freenet-ext.jar.new > NUL
:: Fix the wrapper.conf
GOTO error5
:skipit

ECHO - Freenet installation found at %LOCATION%
ECHO -----
ECHO - Checking for Freenet JAR updates...
ECHO -----

::Check for sha1test and download if needed.
IF NOT EXIST updater\sha1test.jar updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10  https://checksums.freenetproject.org/latest/sha1test.jar -O updater\sha1test.jar
IF NOT ERRORLEVEL 0 GOTO error3
IF NOT EXIST updater\sha1test.jar GOTO error3

::New folder for keeping our temp files for this updater.
IF NOT EXIST update_temp MKDIR update_temp
::We will work out of the temp folder for most of the rest of this script.
CD update_temp\
::Let's clean up any files currently in the Freenet folder
IF EXIST ..\freenet-*.url MOVE /Y ..\freenet-*.url . > NUL
IF EXIST ..\freenet-*.sha1 MOVE /Y ..\freenet-*.sha1 . > NUL
IF EXIST ..\freenet-stable* DEL ..\freenet-stable*
IF EXIST ..\freenet-testing* DEL ..\freenet-testing*

::Work around corrupted ssl certificate bug
::If our startssl.pem file is larger than 100kB we can assume it is corrupt and download a new one.
FOR %%I IN (..\updater\%CAFILE%) DO IF %%~zI LEQ 100000 GOTO maincheck
::Warn the user
ECHO *******************************************************************
ECHO * It appears your installation has a corrupted security certificate.
ECHO * Unfortunately our Windows installer included this bad file during
ECHO * a period between April 27 and July 28 2010.  If you downloaded Freenet
ECHO * during this time, you can try to download an updated version of
ECHO * this file by pressing U and enter now.
ECHO *
ECHO * Warning - this file is used to make sure the files we download
ECHO * from our website have not been tampered with.  If you are not
ECHO * sure this is legit hit Q and enter to quit and ask around first.
ECHO *******************************************************************
:promptloop3
::Set ANSWER3 to a different variable so it won't bug out when we loop
SET ANSWER3==X
ECHO -
ECHO - Do you wish to (U)pdate, (C)ontinue anyway, or (Q)uit?
SET /P ANSWER3=- Press U to update, C to continue or Q to quit.
IF /i %ANSWER3%==U GOTO promptloop3out
IF /i %ANSWER3%==C GOTO maincheck
IF /i %ANSWER3%==Q GOTO veryend
::User hit a wrong key or enter without selecting, go around again.
GOTO promptloop3
:promptloop3out
::User wants to try to download a new certificate
IF EXIST startssl.pem.new DEL startssl.pem.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10  https://checksums.freenetproject.org/latest/startssl.pem -O startssl.pem.new
IF NOT ERRORLEVEL 0 GOTO error3
IF NOT EXIST startssl.pem.new GOTO error3
::File should not be smaller than 2760 bytes
FOR %%I IN ("startssl.pem.new") DO IF %%~zI LSS 2760 GOTO error3
::File seems to be ok, let's copy it over.
::Back up our file first
IF EXIST startssl.pem.bak DEL startssl.pem.bak
IF EXIST ..\updater\startssl.pem COPY ..\updater\startssl.pem startssl.pem.bak > NUL
COPY /Y startssl.pem.new ..\updater\startssl.pem > NUL

:maincheck
::Check for a new main jar
ECHO - Checking main jar
::Backup our .sha1/.url files in case we fail later
IF EXIST freenet-%RELEASE%-latest.jar.url.bak DEL freenet-%RELEASE%-latest.jar.url.bak
IF EXIST freenet-%RELEASE%-latest.jar.url COPY freenet-%RELEASE%-latest.jar.url freenet-%RELEASE%-latest.jar.url.bak > NUL
IF EXIST freenet-%RELEASE%-latest.jar.new.url DEL freenet-%RELEASE%-latest.jar.new.url
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://downloads.freenetproject.org/alpha/freenet-%RELEASE%-latest.jar.url -O freenet-%RELEASE%-latest.jar.new.url
TITLE Freenet Update Over HTTP Script

IF NOT EXIST freenet-%RELEASE%-latest.jar.new.url GOTO maincheckfail
FOR %%I IN ("freenet-%RELEASE%-latest.jar.new.url") DO IF %%~zI LSS 50 GOTO maincheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST freenet-%RELEASE%-latest.jar.url GOTO mainyes

::Compare with current copy
FC freenet-%RELEASE%-latest.jar.url freenet-%RELEASE%-latest.jar.new.url > NUL
IF ERRORLEVEL 1 GOTO mainyes
ECHO    - Main jar is current.
GOTO maincheckend
:maincheckfail
ECHO    - Main jar could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET MAINJARUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Main jar
IF EXIST freenet-%RELEASE%-latest.jar.url DEL freenet-%RELEASE%-latest.jar.url
IF EXIST freenet-%RELEASE%-latest.jar.url.bak REN freenet-%RELEASE%-latest.jar.url.bak freenet-%RELEASE%-latest.jar.url
GOTO maincheckend
:mainyes
ECHO    - New main jar found!
SET MAINJARUPDATED=1
:maincheckend

::Check for a new freenet-ext.jar.
ECHO - Checking ext jar
::Backup our .sha1/.url files in case we fail later
IF EXIST freenet-ext.jar.sha1.bak DEL freenet-ext.jar.sha1.bak
IF EXIST freenet-ext.jar.sha1 COPY freenet-ext.jar.sha1 freenet-ext.jar.sha1.bak > NUL
IF EXIST freenet-ext.jar.sha1.new DEL freenet-ext.jar.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenet-ext.jar.sha1 -O freenet-ext.jar.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST freenet-ext.jar.sha1.new GOTO extcheckfail
FOR %%I IN ("freenet-ext.jar.sha1.new") DO IF %%~zI LSS 50 GOTO extcheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST freenet-ext.jar.sha1 GOTO extyes
FC freenet-ext.jar.sha1 freenet-ext.jar.sha1.new > NUL
IF ERRORLEVEL 1 GOTO extyes
ECHO    - ext jar is current.
GOTO extcheckend
:extcheckfail
ECHO    - ext jar could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET EXTJARUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Ext jar
IF EXIST freenet-ext.jar.sha1 DEL freenet-ext.jar.sha1
IF EXIST freenet-ext.jar.sha1.bak REN freenet-ext.jar.sha1.bak freenet-ext.jar.sha1
GOTO extcheckend

:extyes
ECHO    - New ext jar found!
SET EXTJARUPDATED=1
:extcheckend

::Check wrapper .exe
IF NOT EXIST ..\updater\wrapper-windows-x86-32.exe GOTO wrapperexecheckend
ECHO - Checking wrapper .exe
::Backup our .sha1/.url files in case we fail later
IF EXIST wrapper-windows-x86-32.exe.sha1.bak DEL wrapper-windows-x86-32.exe.sha1.bak
IF EXIST wrapper-windows-x86-32.exe.sha1 COPY wrapper-windows-x86-32.exe.sha1 wrapper-windows-x86-32.exe.sha1.bak > NUL
IF EXIST wrapper-windows-x86-32.exe.sha1.new DEL wrapper-windows-x86-32.exe.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/wrapper-windows-x86-32.exe.sha1 -O wrapper-windows-x86-32.exe.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST wrapper-windows-x86-32.exe.sha1.new GOTO wrapperexecheckfail
FOR %%I IN ("wrapper-windows-x86-32.exe.sha1.new") DO IF %%~zI LSS 50 GOTO wrapperexecheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST wrapper-windows-x86-32.exe.sha1 GOTO wrapperexeyes

FC wrapper-windows-x86-32.exe.sha1 wrapper-windows-x86-32.exe.sha1.new > NUL
IF ERRORLEVEL 1 GOTO wrapperexeyes
ECHO    - wrapper .exe is current.
GOTO wrapperexecheckend
:wrapperexecheckfail
ECHO    - wrapper .exe could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET WRAPPEREXEUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Wrapper .exe
IF EXIST wrapper-windows-x86-32.exe.sha1 DEL wrapper-windows-x86-32.exe.sha1
IF EXIST wrapper-windows-x86-32.exe.sha1.bak REN wrapper-windows-x86-32.exe.sha1.bak wrapper-windows-x86-32.exe.sha1
GOTO wrapperexecheckend

:wrapperexeyes
ECHO    - New wrapper .exe found!
SET WRAPPEREXEUPDATED=1
:wrapperexecheckend

::Check wrapper .dll
IF NOT EXIST ..\lib\wrapper-windows-x86-32.dll GOTO wrapperdllcheckend
ECHO - Checking wrapper .dll
::Backup our .sha1/.url files in case we fail later
IF EXIST wrapper-windows-x86-32.dll.sha1.bak DEL wrapper-windows-x86-32.dll.sha1.bak
IF EXIST wrapper-windows-x86-32.dll.sha1 COPY wrapper-windows-x86-32.dll.sha1 wrapper-windows-x86-32.dll.sha1.bak > NUL
IF EXIST wrapper-windows-x86-32.dll.sha1.new DEL wrapper-windows-x86-32.dll.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/wrapper-windows-x86-32.dll.sha1 -O wrapper-windows-x86-32.dll.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST wrapper-windows-x86-32.dll.sha1.new GOTO wrapperdllcheckfail
FOR %%I IN ("wrapper-windows-x86-32.dll.sha1.new") DO IF %%~zI LSS 50 GOTO wrapperdllcheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST wrapper-windows-x86-32.dll.sha1 GOTO wrapperdllyes

FC wrapper-windows-x86-32.dll.sha1 wrapper-windows-x86-32.dll.sha1.new > NUL
IF ERRORLEVEL 1 GOTO wrapperdllyes
ECHO    - wrapper .dll is current.
GOTO wrapperdllcheckend
:wrapperdllcheckfail
ECHO    - wrapper .dll could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET WRAPPERDLLUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Wrapper .dll
IF EXIST wrapper-windows-x86-32.dll.sha1 DEL wrapper-windows-x86-32.dll.sha1
IF EXIST wrapper-windows-x86-32.dll.sha1.bak REN wrapper-windows-x86-32.dll.sha1.bak wrapper-windows-x86-32.dll.sha1
GOTO wrapperdllcheckend

:wrapperdllyes
:: Handle loop if there is no old URL to compare to.
ECHO    - New wrapper .dll found!
SET WRAPPERDLLUPDATED=1
:wrapperdllcheckend

::Check start.exe if present
IF NOT EXIST ..\bin\start.exe GOTO startexecheckend
ECHO - Checking start.exe
::Backup our .sha1/.url files in case we fail later
IF EXIST start.exe.sha1.bak DEL start.exe.sha1.bak
IF EXIST start.exe.sha1 COPY start.exe.sha1 start.exe.sha1.bak > NUL
IF EXIST start.exe.sha1.new DEL start.exe.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/start.exe.sha1 -O start.exe.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST start.exe.sha1.new GOTO startexecheckfail
FOR %%I IN ("start.exe.sha1.new") DO IF %%~zI LSS 50 GOTO startexecheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST start.exe.sha1 GOTO startexeyes

FC start.exe.sha1 start.exe.sha1.new > NUL
IF ERRORLEVEL 1 GOTO startexeyes
ECHO    - start.exe is current.
GOTO startexecheckend
:startexecheckfail
ECHO    - start.exe could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET STARTEXEUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Start.exe
IF EXIST start.exe.sha1 DEL start.exe.sha1
IF EXIST start.exe.sha1.bak REN start.exe.sha1.bak start.exe.sha1
GOTO startexecheckend

:startexeyes
ECHO    - New start.exe found!
SET STARTEXEUPDATED=1
:startexecheckend

::Check stop.exe if present
IF NOT EXIST ..\bin\stop.exe GOTO stopexecheckend
ECHO - Checking stop.exe
::Backup our .sha1/.url files in case we fail later
IF EXIST stop.exe.sha1.bak DEL stop.exe.sha1.bak
IF EXIST stop.exe.sha1 COPY stop.exe.sha1 stop.exe.sha1.bak > NUL
IF EXIST stop.exe.sha1.new DEL stop.exe.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/stop.exe.sha1 -O stop.exe.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST stop.exe.sha1.new GOTO stopexecheckfail
FOR %%I IN ("stop.exe.sha1.new") DO IF %%~zI LSS 50 GOTO stopexecheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST stop.exe.sha1 GOTO stopexeyes

FC stop.exe.sha1 stop.exe.sha1.new > NUL
IF ERRORLEVEL 1 GOTO stopexeyes
ECHO    - stop.exe is current.
GOTO stopexecheckend
:stopexecheckfail
ECHO    - stop.exe could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET STOPEXEUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Stop.exe
IF EXIST stop.exe.sha1 DEL stop.exe.sha1
IF EXIST stop.exe.sha1.bak REN stop.exe.sha1.bak stop.exe.sha1
GOTO stopexecheckend

:stopexeyes
ECHO    - New stop.exe found!
SET STOPEXEUPDATED=1
:stopexecheckend

::Check tray utility if present
::If the tray utility already is installed, let's see if it needs upgrading.
IF EXIST ..\bin\freenettray.exe GOTO traycheck

::If the required start.exe and stop.exe and installid.dat are present we will offer to install the tray for them
IF NOT EXIST ..\bin\start.exe GOTO traycheckend
IF NOT EXIST ..\bin\stop.exe GOTO traycheckend
IF NOT EXIST ..\installid.dat GOTO traycheckend

::Get the tray utility and put it in the \bin directory
::We don't need to exit the program because it's not running since it's not even installed.
ECHO - Downloading freenettray.exe
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenettray.exe -O freenettray.exe
TITLE Freenet Update Over HTTP Script

IF NOT EXIST freenettray.exe GOTO traycheckfail
FOR %%I IN ("freenettray.exe") DO IF %%~zI LSS 50 GOTO traycheckfail

JAVA -cp ..\updater\sha1test.jar Sha1Test freenettray.exe . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO traycheckfail
TITLE Freenet Update Over HTTP Script

::Copy it to the \bin folder
COPY /Y freenettray.exe ..\bin\freenettray.exe > NUL
IF NOT EXIST ..\bin\freenettray.exe GOTO unknownerror

::Offer to install freenettray.exe in the all users>start folder
ECHO *******************************************************************
ECHO * It appears you are not using the Freenet tray utility.
ECHO * This is likely because you have an older installation that
ECHO * was before the tray program was created.
ECHO * We have downloaded the tray utility to your \bin directory.
ECHO *******************************************************************
ECHO -
ECHO - We can also install it in your startup folder so it launches when you login.
:promptloop2
::Set ANSWER2 to a different variable so it won't bug out when we loop
SET ANSWER2==X
ECHO -
SET /P ANSWER2=- Would you like to install it for "A"ll users, just "Y"ou or "N"one?
IF /i %ANSWER2%==A GOTO allusers
IF /i %ANSWER2%==Y GOTO justyou
IF /i %ANSWER2%==N GOTO traycheckend
::User hit a wrong key or <enter> without selecting, go around again.
GOTO promptloop2
:allusers
COPY /Y freenettray.exe "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\" > NUL
IF NOT ERRORLEVEL 0 GOTO writefail
ECHO freenettray.exe copied to %ALLUSERSPROFILE%\Start Menu\Programs\Startup\
GOTO traycheck
:justyou
COPY /Y freenettray.exe "%USERPROFILE%\Start Menu\Programs\Startup\" > NUL
IF NOT ERRORLEVEL 0 GOTO writefail
ECHO freenettray.exe copied to %USERPROFILE%\Start Menu\Programs\Startup\

:traycheck
ECHO - Checking freenettray.exe
::Backup our .sha1/.url files in case we fail later
IF EXIST freenettray.exe.sha1.bak DEL freenettray.exe.sha1.bak
IF EXIST freenettray.exe.sha1 COPY freenettray.exe.sha1 freenettray.exe.sha1.bak > NUL
IF EXIST freenettray.exe.sha1.new DEL freenettray.exe.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenettray.exe.sha1 -O freenettray.exe.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST freenettray.exe.sha1.new GOTO traycheckfail
FOR %%I IN ("freenettray.exe.sha1.new") DO IF %%~zI LSS 50 GOTO traycheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST freenettray.exe.sha1 GOTO trayyes

FC freenettray.exe.sha1 freenettray.exe.sha1.new > NUL
IF ERRORLEVEL 1 GOTO trayyes
ECHO    - freenettray.exe is current.
GOTO traycheckend

:traycheckfail
ECHO    - freenettray.exe could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET TRAYUTILITYUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::freenettray.exe
IF EXIST freenettray.exe.sha1 DEL freenettray.exe.sha1
IF EXIST freenettray.exe.sha1.new REN freenettray.exe.sha1.new freenettray.exe.sha1
GOTO traycheckend

:trayyes
ECHO    - New freenettray.exe found!
SET TRAYUTILITYUPDATED=1
:traycheckend

::Separate URL for new version

IF %NEWINSTALL%==1 GOTO newlauncher

::Check launcher utility if present
IF NOT EXIST ..\freenetlauncher.exe GOTO launchercheckend
ECHO - Checking freenetlauncher.exe
::Backup our .sha1/.url files in case we fail later
IF EXIST freenetlauncher.exe.sha1.bak DEL freenetlauncher.exe.sha1.bak
IF EXIST freenetlauncher.exe.sha1 COPY freenetlauncher.exe.sha1 freenetlauncher.exe.sha1.bak > NUL
IF EXIST freenetlauncher.exe.sha1.new DEL freenetlauncher.exe.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenetlauncher.exe.sha1 -O freenetlauncher.exe.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST freenetlauncher.exe.sha1.new GOTO launchercheckfail
FOR %%I IN ("freenetlauncher.exe.sha1.new") DO IF %%~zI LSS 50 GOTO launchercheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST freenetlauncher.exe.sha1 GOTO launcheryes

FC freenetlauncher.exe.sha1 freenetlauncher.exe.sha1.new > NUL
IF ERRORLEVEL 1 GOTO launcheryes
ECHO    - freenetlauncher.exe is current.
GOTO launchercheckend

:launchercheckfail
ECHO    - freenetlauncher.exe could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET LAUNCHERUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::freenetlauncher.exe
IF EXIST freenetlauncher.exe.sha1 DEL freenetlauncher.exe.sha1
IF EXIST freenetlauncher.exe.sha1.new REN freenetlauncher.exe.sha1.new freenetlauncher.exe.sha1
GOTO launchercheckend

:launcheryes
ECHO    - New freenetlauncher.exe found!
SET LAUNCHERUPDATED=1
:launchercheckend

GOTO finallaunchercheckend

:newlauncher
::Check launcher utility if present
IF NOT EXIST ..\freenetlauncher.exe GOTO newlaunchercheckend
ECHO - Checking freenetlauncher.exe new version
::Backup our .sha1/.url files in case we fail later
IF EXIST freenetlauncher.exe.sha1.bak DEL freenetlauncher.exe.sha1.bak
IF EXIST freenetlauncher.exe.sha1 COPY freenetlauncher.exe.sha1 freenetlauncher.exe.sha1.bak > NUL
IF EXIST freenetlauncher.exe.sha1.new DEL freenetlauncher.exe.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenetlauncher-new.exe.sha1 -O freenetlauncher-new.exe.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST freenetlauncher-new.exe.sha1.new GOTO newlaunchercheckfail
FOR %%I IN ("freenetlauncher-new.exe.sha1.new") DO IF %%~zI LSS 50 GOTO newlaunchercheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST freenetlauncher-new.exe.sha1 GOTO newlauncheryes

FC freenetlauncher-new.exe.sha1 freenetlauncher-new.exe.sha1.new > NUL
IF ERRORLEVEL 1 GOTO newlauncheryes
ECHO    - freenetlauncher.exe is current.
GOTO newlaunchercheckend

:newlaunchercheckfail
ECHO    - freenetlauncher.exe could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET LAUNCHERUPDATEDNEW=2
::Restore the old .sha1 files so we can check them again next run.
::freenetlauncher.exe
IF EXIST freenetlauncher-new.exe.sha1 DEL freenetlauncher-new.exe.sha1
IF EXIST freenetlauncher-new.exe.sha1.new REN freenetlauncher-new.exe.sha1.new freenetlauncher-new.exe.sha1
GOTO newlaunchercheckend

:newlauncheryes
ECHO    - New freenetlauncher.exe found!
SET LAUNCHERUPDATEDNEW=1
:newlaunchercheckend


:finallaunchercheckend

::Check for an updated seednodes.fref
::Backup our .sha1/.url files in case we fail later
IF EXIST seednodes.fref.sha1.bak DEL seednodes.fref.sha1.bak
IF EXIST seednodes.fref.sha1 COPY seednodes.fref.sha1 seednodes.fref.sha1.bak > NUL
IF EXIST seednodes.fref.sha1.new DEL seednodes.fref.sha1.new
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/seednodes.fref.sha1 -O seednodes.fref.sha1.new
TITLE Freenet Update Over HTTP Script

IF NOT EXIST seednodes.fref.sha1.new GOTO seedcheckfail
FOR %%I IN ("seednodes.fref.sha1.new") DO IF %%~zI LSS 50 GOTO seedcheckfail

::Do we have something old to compare with? If not, update right away
IF NOT EXIST seednodes.fref.sha1 GOTO seedyes

FC seednodes.fref.sha1 seednodes.fref.sha1.new > NUL
IF ERRORLEVEL 1 GOTO seedyes
GOTO seedcheckend

:seedcheckfail
ECHO    - seednodes.fref could not be checked, perhaps a server issue or broken link?
::Set to 2 to indicate error
SET SEEDUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::seednodes.fref
IF EXIST seednodes.fref.sha1 DEL seednodes.fref.sha1
IF EXIST seednodes.fref.sha1.bak REN seednodes.fref.sha1.bak seednodes.fref.sha1
GOTO seedcheckend

:seedyes
SET SEEDUPDATED=1
:seedcheckend

::Check if we have flagged any of the files as updated
IF %MAINJARUPDATED%==1 GOTO downloadbegin
IF %EXTJARUPDATED%==1 GOTO downloadbegin
IF %WRAPPEREXEUPDATED%==1 GOTO downloadbegin
IF %WRAPPERDLLUPDATED%==1 GOTO downloadbegin
IF %STARTEXEUPDATED%==1 GOTO downloadbegin
IF %STOPEXEUPDATED%==1 GOTO downloadbegin
IF %TRAYUTILITYUPDATED%==1 GOTO downloadbegin
IF %LAUNCHERUPDATED%==1 GOTO downloadbegin
IF %LAUNCHERUPDATEDNEW%==1 GOTO downloadbegin
::Purposely not considering whether seednode is updated
GOTO noupdate

::New version found, check if the node is currently running
:downloadbegin
ECHO -----
ECHO - New Freenet version found!  Installing now...
ECHO -----

ECHO - Downloading new files...

::Download new main jar file
IF NOT %MAINJARUPDATED%==1 GOTO mainjardownloadend
IF EXIST freenet-%RELEASE%-latest.jar DEL freenet-%RELEASE%-latest.jar
..\updater\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 -i freenet-%RELEASE%-latest.jar.new.url -O freenet-%RELEASE%-latest.jar
TITLE Freenet Update Over HTTP Script
:: Make sure it got downloaded successfully
IF NOT EXIST freenet-%RELEASE%-latest.jar GOTO mainjardownloadfailed
FOR %%I IN ("freenet-%RELEASE%-latest.jar") DO IF %%~zI LSS 50 GOTO mainjardownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test freenet-%RELEASE%-latest.jar . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO mainjardownloadfailed
ECHO    - Freenet-%RELEASE%-snapshot.jar downloaded and verified
GOTO mainjardownloadend
:mainjardownloadfailed
ECHO    - Freenet-%RELEASE%-snapshot.jar failed to download
::Set MAINJARUPDATED to 2 so it won't copy in next stage.
SET MAINJARUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Main jar
IF EXIST freenet-%RELEASE%-latest.jar.url DEL freenet-%RELEASE%-latest.jar.url
IF EXIST freenet-%RELEASE%-latest.jar.url.bak REN freenet-%RELEASE%-latest.jar.url.bak freenet-%RELEASE%-latest.jar.url
:mainjardownloadend

::Download new ext jar file
IF NOT %EXTJARUPDATED%==1 GOTO extjardownloadend
IF EXIST freenet-ext.jar.sha1 DEL freenet-ext.jar.sha1
IF EXIST freenet-ext.jar DEL freenet-ext.jar
..\updater\wget.exe -o NUL -c --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenet-ext.jar -O freenet-ext.jar
TITLE Freenet Update Over HTTP Script
IF NOT EXIST freenet-ext.jar GOTO extjardownloadfailed
FOR %%I IN ("freenet-ext.jar") DO IF %%~zI LSS 50 GOTO extjardownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test freenet-ext.jar . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO extjardownloadfailed
ECHO    - Freenet-ext.jar downloaded and verified
GOTO extjardownloadend
:extjardownloadfailed
ECHO    - Freenet-ext.jar failed to download
::Set EXTJARUPDATED to 2 so it won't copy in next stage.
SET EXTJARUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Ext jar
IF EXIST freenet-ext.jar.sha1 DEL freenet-ext.jar.sha1
IF EXIST freenet-ext.jar.sha1.bak REN freenet-ext.jar.sha1.bak freenet-ext.jar.sha1
:extjardownloadend

::Download new wrapper.exe file
IF NOT %WRAPPEREXEUPDATED%==1 GOTO wrapperexedownloadend
IF EXIST wrapper-windows-x86-32.exe.sha1 DEL wrapper-windows-x86-32.exe.sha1
IF EXIST wrapper-windows-x86-32.exe DEL wrapper-windows-x86-32.exe
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/wrapper-windows-x86-32.exe -O wrapper-windows-x86-32.exe
TITLE Freenet Update Over HTTP Script
IF NOT EXIST wrapper-windows-x86-32.exe GOTO wrapperexedownloadfailed
FOR %%I IN ("wrapper-windows-x86-32.exe") DO IF %%~zI LSS 50 GOTO wrapperexedownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test wrapper-windows-x86-32.exe . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO wrapperexedownloadfailed
ECHO    - wrapper .exe downloaded and verified
GOTO wrapperexedownloadend
:wrapperexedownloadfailed
ECHO    - wrapper .exe failed to download
::Set WRAPPEREXEUPDATED to 2 so it won't copy in next stage.
SET WRAPPEREXEUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Wrapper .exe
IF EXIST wrapper-windows-x86-32.exe.sha1 DEL wrapper-windows-x86-32.exe.sha1
IF EXIST wrapper-windows-x86-32.exe.sha1.bak REN wrapper-windows-x86-32.exe.sha1.bak wrapper-windows-x86-32.exe.sha1
:wrapperexedownloadend

::Download new wrapper.dll file
IF NOT %WRAPPERDLLUPDATED%==1 GOTO wrapperdlldownloadend
IF EXIST wrapper-windows-x86-32.dll.sha1 DEL wrapper-windows-x86-32.dll.sha1
IF EXIST wrapper-windows-x86-32.dll DEL wrapper-windows-x86-32.dll
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/wrapper-windows-x86-32.dll -O wrapper-windows-x86-32.dll
TITLE Freenet Update Over HTTP Script
IF NOT EXIST wrapper-windows-x86-32.dll GOTO wrapperdlldownloadfailed
FOR %%I IN ("wrapper-windows-x86-32.dll") DO IF %%~zI LSS 50 GOTO wrapperdlldownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test wrapper-windows-x86-32.dll . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO wrapperdlldownloadfailed
ECHO    - wrapper .dll downloaded and verified
GOTO wrapperdlldownloadend
:wrapperdlldownloadfailed
ECHO    - wrapper .dll failed to download
::Set WRAPPERDLLUPDATED to 2 so it won't copy in next stage.
SET WRAPPERDLLUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Wrapper .dll
IF EXIST wrapper-windows-x86-32.dll.sha1 DEL wrapper-windows-x86-32.dll.sha1
IF EXIST wrapper-windows-x86-32.dll.sha1.bak REN wrapper-windows-x86-32.dll.sha1.bak wrapper-windows-x86-32.dll.sha1
:wrapperdlldownloadend

::Download new start.exe file
IF NOT %STARTEXEUPDATED%==1 GOTO startexedownloadend
IF EXIST start.exe.sha1 DEL start.exe.sha1
IF EXIST start.exe DEL start.exe
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/start.exe -O start.exe
TITLE Freenet Update Over HTTP Script
IF NOT EXIST start.exe GOTO startexedownloadfailed
FOR %%I IN ("start.exe") DO IF %%~zI LSS 50 GOTO startexedownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test start.exe . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO startexedownloadfailed
ECHO    - start.exe downloaded and verified
GOTO startexedownloadend
:startexedownloadfailed
ECHO    - start.exe failed to download
::Set STARTEXEUPDATED to 2 so it won't copy in next stage.
SET STARTEXEUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Start.exe
IF EXIST start.exe.sha1 DEL start.exe.sha1
IF EXIST start.exe.sha1.bak REN start.exe.sha1.bak start.exe.sha1
:startexedownloadend

::Download new stop.exe file
IF NOT %STOPEXEUPDATED%==1 GOTO stopexedownloadend
IF EXIST stop.exe.sha1 DEL stop.exe.sha1
IF EXIST stop.exe DEL stop.exe
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/stop.exe -O stop.exe
TITLE Freenet Update Over HTTP Script
IF NOT EXIST stop.exe GOTO stopexedownloadfailed
FOR %%I IN ("stop.exe") DO IF %%~zI LSS 50 GOTO stopexedownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test stop.exe . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO stopexedownloadfailed
ECHO    - stop.exe downloaded and verified
GOTO stopexedownloadend
:stopexedownloadfailed
ECHO    - stop.exe failed to download
::Set STOPEXEUPDATED to 2 so it won't copy in next stage.
SET STOPEXEUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Stop.exe
IF EXIST stop.exe.sha1 DEL stop.exe.sha1
IF EXIST stop.exe.sha1.bak REN stop.exe.sha1.bak stop.exe.sha1
:stopexedownloadend

::Download new freenettray.exe file
IF NOT %TRAYUTILITYUPDATED%==1 GOTO traydownloadend
IF EXIST freenettray.exe.sha1 DEL freenettray.exe.sha1
IF EXIST freenettray.exe DEL freenettray.exe
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenettray.exe -O freenettray.exe
TITLE Freenet Update Over HTTP Script
IF NOT EXIST freenettray.exe GOTO traydownloadfailed
FOR %%I IN ("freenettray.exe") DO IF %%~zI LSS 50 GOTO traydownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test freenettray.exe . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO traydownloadfailed
ECHO    - freenettray.exe downloaded and verified
GOTO traydownloadend
:traydownloadfailed
ECHO    - freenettray.exe failed to download
::Set TRAYUTILITYUPDATED to 2 so it won't copy in next stage.
SET TRAYUTILITYUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Tray utility
IF EXIST freenettray.exe.sha1 DEL freenettray.exe.sha1
IF EXIST freenettray.exe.sha1.bak REN freenettray.exe.sha1.bak freenettray.exe.jar.sha1
:traydownloadend

::Download new freenetlauncher.exe file
IF NOT %LAUNCHERUPDATED%==1 GOTO launcherdownloadend
IF EXIST freenetlauncher.exe.sha1 DEL freenetlauncher.exe.sha1
IF EXIST freenetlauncher.exe DEL freenetlauncher.exe
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenetlauncher.exe -O freenetlauncher.exe
TITLE Freenet Update Over HTTP Script
IF NOT EXIST freenetlauncher.exe GOTO launcherdownloadfailed
FOR %%I IN ("freenetlauncher.exe") DO IF %%~zI LSS 50 GOTO launcherdownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test freenetlauncher.exe . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO launcherdownloadfailed
ECHO    - freenetlauncher.exe downloaded and verified
GOTO launcherdownloadend
:launcherdownloadfailed
ECHO    - freenetlauncher.exe failed to download
::Set LAUNCHERUPDATED to 2 so it won't copy in next stage.
SET LAUNCHERUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::Launcher.exe
IF EXIST freenetlauncher.exe.sha1 DEL freenetlauncher.exe.sha1
IF EXIST freenetlauncher.exe.sha1.bak REN freenetlauncher.exe.sha1.bak freenetlauncher.exe.sha1
:launcherdownloadend

::Download new freenetlauncher.exe file for non service installs
IF NOT %LAUNCHERUPDATEDNEW%==1 GOTO newlauncherdownloadend
IF EXIST freenetlauncher-new.exe.sha1 DEL freenetlauncher-new.exe.sha1
IF EXIST freenetlauncher-new.exe DEL freenetlauncher-new.exe
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/freenetlauncher-new.exe -O freenetlauncher-new.exe
TITLE Freenet Update Over HTTP Script
IF NOT EXIST freenetlauncher-new.exe GOTO newlauncherdownloadfailed
FOR %%I IN ("freenetlauncher-new.exe") DO IF %%~zI LSS 50 GOTO newlauncherdownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test freenetlauncher-new.exe . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO newlauncherdownloadfailed
ECHO    - freenetlauncher.exe downloaded and verified
::Arrange for the next stage to use the exe
DEL freenetlauncher.exe
REN freenetlauncher-new.exe freenetlauncher.exe
SET LAUNCHERUPDATEDNEW=2
SET LAUNCHERUPDATED=1
GOTO newlauncherdownloadend
:newlauncherdownloadfailed
ECHO    - freenetlauncher.exe failed to download
::Set LAUNCHERUPDATED to 2 so it won't copy in next stage.
SET LAUNCHERUPDATEDNEW=2
::Restore the old .sha1 files so we can check them again next run.
::Launcher.exe
IF EXIST freenetlauncher-new.exe.sha1 DEL freenetlauncher-new.exe.sha1
IF EXIST freenetlauncher-new.exe.sha1.bak REN freenetlauncher-new.exe.sha1.bak freenetlauncher.exe.sha1
:newlauncherdownloadend

::Download an updated seednodes.fref.  We will only do this if at least one of the main files above were updated and the .sha1 of the file has changed.
::We are stingy because we don't want people to run this script *just* to get the latest seednodes file.
IF NOT %SEEDUPDATED%==1 GOTO seeddownloadend
IF EXIST seednodes.fref.sha1 DEL seednodes.fref.sha1
IF EXIST seednodes.fref DEL seednodes.fref
..\updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 http://checksums.freenetproject.org/latest/seednodes.fref -O seednodes.fref
TITLE Freenet Update Over HTTP Script
IF NOT EXIST seednodes.fref GOTO seeddownloadfailed
FOR %%I IN ("seednodes.fref") DO IF %%~zI LSS 50 GOTO seeddownloadfailed
::Test the new file for integrity.
JAVA -cp ..\updater\sha1test.jar Sha1Test seednodes.fref . ..\updater\%CAFILE% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO seeddownloadfailed
ECHO    - seednodes.fref downloaded and verified
GOTO seeddownloadend
:seeddownloadfailed
ECHO    - seednodes.fref failed to download
::Set SEEDUPDATED to 2 so it won't copy in next stage.
SET SEEDUPDATED=2
::Restore the old .sha1 files so we can check them again next run.
::seednodes.fref
IF EXIST seednodes.fref.sha1 DEL seednodes.fref.sha1
IF EXIST seednodes.fref.sha1.bak REN seednodes.fref.sha1.bak seednodes.fref.sha1
:seeddownloadend

TITLE Freenet Update Over HTTP Script

::Check if we have any successful downloads
IF %MAINJARUPDATED%==1 GOTO installbegin
IF %EXTJARUPDATED%==1 GOTO installbegin
IF %WRAPPEREXEUPDATED%==1 GOTO installbegin
IF %WRAPPERDLLUPDATED%==1 GOTO installbegin
IF %STARTEXEUPDATED%==1 GOTO installbegin
IF %STOPEXEUPDATED%==1 GOTO installbegin
IF %TRAYUTILITYUPDATED%==1 GOTO installbegin
IF %LAUNCHERUPDATED%==1 GOTO installbegin
::Purposely not considering whether seednode is updated
GOTO error4

:installbegin
::At least one of our files are ok, let's move forward.

::Time to stop the node
::Tell the user not to abort script, it gets very messy.
ECHO -----
ECHO - Shutting down Freenet if it is running...   (This may take a moment, please don't abort)
ECHO -----
::If we are using the newest install method, for now we need the user to manually shutdown the node.
IF %NEWINSTALL%==1 GOTO manualshutdownprompt

::See if we are using the new binary stop.exe
IF NOT EXIST ..\bin\stop.exe GOTO oldstopper
:newstoppper
CALL ..\bin\stop.exe /silent
IF ERRORLEVEL 0 SET RESTART=1
IF ERRORLEVEL 1 GOTO unknownerror
GOTO beginfilecopy

:oldstopper
NET START | FIND "Freenet 0.7 darknet" > NUL
IF ERRORLEVEL 1 GOTO beginfilecopy
SET RESTART=1
CALL ..\bin\stop.cmd > NUL
NET START | FIND "Freenet 0.7 darknet" > NUL
IF ERRORLEVEL 1 GOTO beginfilecopy
:: Uh oh, this may take a few tries.  Better tell the user not to panic.
ECHO -
ECHO - If you see an error message about:
ECHO - "The service could not be controlled in its present state."
ECHO - Please ignore, it is a side effect of a work-around
ECHO - to make sure the node is stopped before we copy files.
ECHO -
::Keep trying until service is stopped for sure.
:safetycheck
NET START | FIND "Freenet 0.7 darknet" > NUL
IF ERRORLEVEL 1 GOTO beginfilecopy
::Much cleaner way of giving us a 5 second pause to make sure the node is shut down.
::Found at http://www.allenware.com/icsw/icswref.htm#WaitsFixedPing
::Insert delay of 5 =6-1 seconds
PING -n 6 127.0.0.1 > NUL
CALL ..\bin\stop.cmd > NUL
GOTO safetycheck

::We are using the newest install method, for now we need the user to manually shutdown the node.
:manualshutdownprompt
ECHO -
ECHO - We are currently not able to automatically shutdown Freenet with this script.
ECHO - You need to manually stop Freenet using the tray icon then press any key to continue.
ECHO -
PAUSE
::Let's give the node a few seconds to shutdown cleanly
ECHO - Continuing in 15 seconds...
::Insert delay of 15 =16-1 seconds
PING -n 16 127.0.0.1 > NUL

::Ok Freenet is stopped, it is safe to copy files.
:beginfilecopy
::Everything looks good, lets install it
ECHO - Backing up files...
ECHO -----
ECHO - Installing new files...
::Main jar
IF NOT %MAINJARUPDATED%==1 GOTO maincopyend
::Backup last version of Freenet.jar file, user may want to go back if something is broken in new build
IF EXIST freenet.jar.bak DEL freenet.jar.bak
IF EXIST ..\freenet.jar COPY ..\freenet.jar freenet.jar.bak > NUL
COPY /Y freenet-%RELEASE%-latest.jar ..\freenet.jar > NUL
::Prepare shortcut file for next run.
IF EXIST freenet-%RELEASE%-latest.jar.url DEL freenet-%RELEASE%-latest.jar.url
REN freenet-%RELEASE%-latest.jar.new.url freenet-%RELEASE%-latest.jar.url
ECHO    - Freenet-%RELEASE%-snapshot.jar copied to freenet.jar
:maincopyend

::Ext jar
IF NOT %EXTJARUPDATED%==1 GOTO extcopyend
::Backup last version of Freenet-ext.jar file, user may want to go back if something is broken in new build
IF EXIST freenet-ext.jar.bak DEL freenet-ext.jar.bak
IF EXIST ..\freenet-ext.jar COPY ..\freenet-ext.jar freenet-ext.jar.bak > NUL
COPY /Y freenet-ext.jar ..\freenet-ext.jar > NUL
::Prepare .sha1 file for next run.
IF EXIST freenet-ext.jar.sha1 DEL freenet-ext.jar.sha1
IF EXIST freenet-ext.jar.sha1.new REN freenet-ext.jar.sha1.new freenet-ext.jar.sha1
ECHO    - Copied updated freenet-ext.jar
:extcopyend

::wrapper .exe
IF NOT %WRAPPEREXEUPDATED%==1 GOTO wrapperexecopyend
::Backup last version of wrapper.exe file, user may want to go back if something is broken in new build
IF EXIST wrapper-windows-x86-32.exe.bak DEL wrapper-windows-x86-32.exe.bak
IF EXIST ..\bin\wrapper-windows-x86-32.exe COPY ..\bin\wrapper-windows-x86-32.exe wrapper-windows-x86-32.exe.bak > NUL
COPY /Y wrapper-windows-x86-32.exe ..\bin\wrapper-windows-x86-32.exe > NUL
::Prepare .sha1 file for next run.
IF EXIST wrapper-windows-x86-32.exe.sha1 DEL wrapper-windows-x86-32.exe.sha1
IF EXIST wrapper-windows-x86-32.exe.sha1.new REN wrapper-windows-x86-32.exe.sha1.new wrapper-windows-x86-32.exe.sha1
ECHO    - Copied updated wrapper .exe
:wrapperexecopyend

::Wrapper .dll
IF NOT %WRAPPERDLLUPDATED%==1 GOTO wrapperdllcopyend
::Backup last version of wrapper.dll file, user may want to go back if something is broken in new build
IF EXIST wrapper-windows-x86-32.dll.bak DEL wrapper-windows-x86-32.dll.bak
IF EXIST ..\lib\wrapper-windows-x86-32.dll COPY ..\lib\wrapper-windows-x86-32.dll wrapper-windows-x86-32.dll.bak > NUL
COPY /Y wrapper-windows-x86-32.dll ..\lib\wrapper-windows-x86-32.dll > NUL
::Prepare .sha1 file for next run.
IF EXIST wrapper-windows-x86-32.dll.sha1 DEL wrapper-windows-x86-32.dll.sha1
IF EXIST wrapper-windows-x86-32.dll.sha1.new REN wrapper-windows-x86-32.dll.sha1.new wrapper-windows-x86-32.dll.sha1
ECHO    - Copied updated wrapper .dll
:wrapperdllcopyend

::Start.exe
IF NOT %STARTEXEUPDATED%==1 GOTO startexecopyend
::Backup last version of start.exe file, user may want to go back if something is broken in new build
IF EXIST start.exe.bak DEL start.exe.bak
IF EXIST ..\bin\start.exe COPY ..\bin\start.exe start.exe.bak > NUL
COPY /Y start.exe ..\bin\start.exe > NUL
::Prepare .sha1 file for next run.
IF EXIST start.exe.sha1 DEL start.exe.sha1
IF EXIST start.exe.sha1.new REN start.exe.sha1.new start.exe.sha1
ECHO    - Copied updated start.exe
:startexecopyend

::Stop.exe
IF NOT %STOPEXEUPDATED%==1 GOTO stopexecopyend
::Backup last version of stop.exe file, user may want to go back if something is broken in new build
IF EXIST stop.exe.bak DEL stop.exe.bak
IF EXIST ..\bin\stop.exe COPY ..\bin\stop.exe stop.exe.bak > NUL
COPY /Y stop.exe ..\bin\stop.exe > NUL
::Prepare .sha1 file for next run.
IF EXIST stop.exe.sha1 DEL stop.exe.sha1
IF EXIST stop.exe.sha1.new REN stop.exe.sha1.new stop.exe.sha1
ECHO    - Copied updated stop.exe
:stopexecopyend

::freenetlauncher.exe
IF NOT %LAUNCHERUPDATED%==1 GOTO launchercopyend
::Backup last version of freenetlauncher.exe file, user may want to go back if something is broken in new build
IF EXIST freenetlauncher.exe.bak DEL freenetlauncher.exe.bak
IF EXIST ..\freenetlauncher.exe COPY ..\freenetlauncher.exe freenetlauncher.exe.bak > NUL
COPY /Y freenetlauncher.exe ..\freenetlauncher.exe > NUL
::Prepare .sha1 file for next run.
IF EXIST freenetlauncher.exe.sha1 DEL freenetlauncher.exe.sha1
IF EXIST freenetlauncher.exe.sha1.new REN freenetlauncher.exe.sha1.new freenetlauncher.exe.sha1
ECHO    - Copied updated freenetlauncher.exe
:launchercopyend

::seednodes.fref
IF NOT %SEEDUPDATED%==1 GOTO seedcopyend
::Backup last version of seednodes.fref file, user may want to go back if something is broken in new build
IF EXIST seednodes.fref.bak DEL seednodes.fref.bak
IF EXIST ..\seednodes.fref COPY ..\seednodes.fref seednodes.fref.bak > NUL
COPY /Y seednodes.fref ..\seednodes.fref > NUL
::Prepare .sha1 file for next run.
IF EXIST seednodes.fref.sha1 DEL seednodes.fref.sha1
IF EXIST seednodes.fref.sha1.new REN seednodes.fref.sha1.new seednodes.fref.sha1
ECHO    - Copied updated seednodes.fref
:seedcopyend

::freenettray.exe
IF NOT %TRAYUTILITYUPDATED%==1 GOTO traycopyend
::Backup last version of freenettray.exe file, user may want to go back if something is broken in new build
IF EXIST freenettray.exe.bak DEL freenettray.exe.bak
IF EXIST ..\bin\freenettray.exe COPY ..\bin\freenettray.exe freenettray.exe.bak > NUL
::Shut down the tray utility
ECHO    - Pausing 15 seconds to allow Freenet tray utility to close...
IF NOT EXIST ..\tray_die.dat ECHO "" >> ..\tray_die.dat
::Much cleaner way of giving us a 15 second pause to make sure the tray is shut down.
::Found at http://www.allenware.com/icsw/icswref.htm#WaitsFixedPing
::Insert delay of 15 =16-1 seconds
PING -n 16 127.0.0.1 > NUL
IF EXIST ..\bin\freenettray.exe DEL ..\bin\freenettray.exe
COPY freenettray.exe ..\bin\freenettray.exe > NUL
::Update the startup folder also
IF EXIST "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\freenettray.exe" COPY /y freenettray.exe "%ALLUSERSPROFILE%\Start Menu\Programs\Startup\" > NUL
IF EXIST "%USERPROFILE%\Start Menu\Programs\Startup\freenettray.exe" COPY /y freenettray.exe "%USERPROFILE%\Start Menu\Programs\Startup\" > NUL
::Prepare .sha1 file for next run.
IF EXIST freenettray.exe.sha1 DEL freenettray.exe.sha1
IF EXIST freenettray.exe.sha1.new REN freenettray.exe.sha1.new freenettray.exe.sha1
ECHO    - Copied updated freenettray.exe
:traycopyend

::Check if we have any failed downloads to report
IF %MAINJARUPDATED%==2 GOTO error4
IF %EXTJARUPDATED%==2 GOTO error4
IF %WRAPPEREXEUPDATED%==2 GOTO error4
IF %WRAPPERDLLUPDATED%==2 GOTO error4
IF %STARTEXEUPDATED%==2 GOTO error4
IF %STOPEXEUPDATED%==2 GOTO error4
IF %TRAYUTILITYUPDATED%==2 GOTO error4
IF %LAUNCHERUPDATED%==2 GOTO error4
IF %SEEDUPDATED%==2 GOTO error4
GOTO end

::No update needed
:noupdate
ECHO -----
ECHO - Freenet is already up to date.
GOTO end

::Server gave us a damaged version of the update script, tell user to try again later.
:error1
ECHO - Error! Downloaded update script is invalid. Try again later.
GOTO end

::Can't find Freenet installation
:error2
ECHO - Error! Please run this script from a working Freenet installation.
ECHO -----
PAUSE
GOTO veryend

::Server may be down.
:error3
ECHO - Error! Could not download latest Freenet update information. Try again later.
GOTO end

:error4
ECHO - Error! Freenet update failed, one or more files didn't download correctly...
ECHO -
ECHO - The following files have succeeded:
IF %MAINJARUPDATED%==1 ECHO -     freenet-%RELEASE%-latest.jar
IF %EXTJARUPDATED%==1 ECHO -     freenet-ext.jar
IF %WRAPPEREXEUPDATED%==1 ECHO -     wrapper-windows-x86-32.exe
IF %WRAPPERDLLUPDATED%==1 ECHO -     wrapper-windows-x86-32.dll
IF %STARTEXEUPDATED%==1 ECHO -     start.exe
IF %STOPEXEUPDATED%==1 ECHO -     stop.exe
IF %TRAYUTILITYUPDATED%==1 ECHO -     freenettray.exe
IF %LAUNCHERUPDATED%==1 ECHO -     freenetlauncher.exe
IF %SEEDUPDATED%==1 ECHO -     seednodes.fref
ECHO -
ECHO - The following files have failed:
IF %MAINJARUPDATED%==2 ECHO -     freenet-%RELEASE%-latest.jar
IF %EXTJARUPDATED%==2 ECHO -     freenet-ext.jar
IF %WRAPPEREXEUPDATED%==2 ECHO -     wrapper-windows-x86-32.exe
IF %WRAPPERDLLUPDATED%==2 ECHO -     wrapper-windows-x86-32.dll
IF %STARTEXEUPDATED%==2 ECHO -     start.exe
IF %STOPEXEUPDATED%==2 ECHO -     stop.exe
IF %TRAYUTILITYUPDATED%==2 ECHO -     freenettray.exe
IF %LAUNCHERUPDATED%==2 ECHO -     freenetlauncher.exe
IF %SEEDUPDATED%==2 ECHO -     seednodes.fref
ECHO -
ECHO - Try again later.
GOTO end

::Wrapper.conf is old, downloading new version and restarting update script
:error5
ECHO - Your wrapper.conf needs to be updated .... updating it; please restart the script when done.
:: Let's try falling back to the old version of the wrapper so we can keep our memory settings.  If it doesn't work we'll get a new one next time around.
IF NOT EXIST %WRAPPERBAK% GOTO newwrapper
IF EXIST %WRAPPER% DEL %WRAPPER%
MOVE %WRAPPERBAK% %WRAPPER%
START update.cmd
GOTO veryend

:newwrapper
IF EXIST %WRAPPER% MOVE %WRAPPER% %WRAPPERBAK%
:: This will set the memory settings back to default, but it can't be helped.
SET WRAPPERURL=http://downloads.freenetproject.org/alpha/update/wrapper.conf
IF %NEWINSTALL%==1 SET WRAPPERURL=http://downloads.freenetproject.org/alpha/update/wrapper.conf.no-service
updater\wget.exe -o NUL --timeout=5 --tries=5 --waitretry=10 %WRAPPERURL% -O %WRAPPER%
IF NOT EXIST %WRAPPER% GOTO wrappererror
IF EXIST wrapper.password type wrapper.password >> %WRAPPER%
START update.cmd
GOTO veryend

:wrappererror
IF EXIST %WRAPPERBAK% MOVE %WRAPPERBAK% %WRAPPER%
GOTO error3

::Cleanup and restart if needed.
:end
ECHO -----
ECHO - Cleaning up...

:: Maybe fix bug #2556
CD ..
ECHO - Changing file permissions
IF %VISTA%==0 ECHO Y| CACLS . /E /T /C /G freenet:F > NUL
IF %VISTA%==1 ECHO y| ICACLS . /grant freenet:(OI)(CI)F /T /C > NUL

::If we are using the newest install method, for now we need the user to manually start the node.
IF %NEWINSTALL%==1 GOTO manualstartprompt

::Try to restart the tray if it was flagged as updated
IF %TRAYUTILITYUPDATED%==0 GOTO restart
IF EXIST tray_die.dat DEL tray_die.dat
START bin\freenettray.exe
:restart
IF %RESTART%==0 GOTO cleanup2
ECHO - Restarting Freenet...
::See if we are using the new binary start.exe
IF NOT EXIST bin\start.exe GOTO oldstarter
CALL bin\start.exe /silent
IF ERRORLEVEL 0 GOTO cleanup2
CD update_temp
GOTO unknownerror

:oldstarter
CALL bin\start.cmd > NUL
goto cleanup2

:manualstartprompt
ECHO -
ECHO - We are currently not able to automatically start Freenet with this script.
ECHO - You need to manually start Freenet using the tray icon then press any key to continue.
ECHO - You can also leave Freenet shutdown and press any key to continue.
ECHO -
PAUSE

:cleanup2
IF %FILENAME%==update.new.cmd GOTO newend
IF EXIST update_temp\update.new.cmd DEL update_temp\update.new.cmd
ECHO -----
GOTO veryend

::If this session was launched by an old updater, replace it now (and force exit, or we will leave a command prompt open)
:newend
COPY /Y update.new.cmd update.cmd > NUL
ECHO -----
exit

 ::We don't have enough privileges!
:writefail
ECHO - File permissions error!  Please launch this script with administrator privileges.
PAUSE
GOTO veryend

:unknownerror
ECHO - An unknown error has occurred.
ECHO - Please scroll up and look for clues and contact support@freenetproject.org
::Restore the old .sha1 files so we can check them again next run.
::Main jar
IF EXIST freenet-%RELEASE%-latest.jar.url DEL freenet-%RELEASE%-latest.jar.url
IF EXIST freenet-%RELEASE%-latest.jar.url.bak REN freenet-%RELEASE%-latest.jar.url.bak freenet-%RELEASE%-latest.jar.url
::Ext jar
IF EXIST freenet-ext.jar.sha1 DEL freenet-ext.jar.sha1
IF EXIST freenet-ext.jar.sha1.bak REN freenet-ext.jar.sha1.bak freenet-ext.jar.sha1
::Wrapper .exe
IF EXIST wrapper-windows-x86-32.exe.sha1 DEL wrapper-windows-x86-32.exe.sha1
IF EXIST wrapper-windows-x86-32.exe.sha1.bak REN wrapper-windows-x86-32.exe.sha1.bak wrapper-windows-x86-32.exe.sha1
::Wrapper .dll
IF EXIST wrapper-windows-x86-32.dll.sha1 DEL wrapper-windows-x86-32.dll.sha1
IF EXIST wrapper-windows-x86-32.dll.sha1.bak REN wrapper-windows-x86-32.dll.sha1.bak wrapper-windows-x86-32.dll.sha1
::Start.exe
IF EXIST start.exe.sha1 DEL start.exe.sha1
IF EXIST start.exe.sha1.bak REN start.exe.sha1.bak start.exe.sha1
::Stop.exe
IF EXIST stop.exe.sha1 DEL stop.exe.sha1
IF EXIST stop.exe.sha1.bak REN stop.exe.sha1.bak stop.exe.sha1
::Tray utility
IF EXIST freenettray.exe.sha1 DEL freenettray.exe.sha1
IF EXIST freenettray.exe.sha1.bak REN freenettray.exe.sha1.bak freenettray.exe.jar.sha1
::Launcher.exe
IF EXIST freenetlauncher.exe.sha1 DEL freenetlauncher.exe.sha1
IF EXIST freenetlauncher.exe.sha1.bak REN freenetlauncher.exe.sha1.bak freenetlauncher.exe.sha1
::seednodes.fref
IF EXIST seednodes.fref.sha1 DEL seednodes.fref.sha1
IF EXIST seednodes.fref.sha1.bak REN seednodes.fref.sha1.bak seednodes.fref.sha1

PAUSE

:veryend
::FREENET WINDOWS UPDATE SCRIPT
