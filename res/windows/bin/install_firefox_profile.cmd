@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if not exist firefox_profile.install goto end
@echo Downloading the firefox profile
@if exist offline goto end1
@java -jar bin\sha1test.jar firefox_profile.zip . %CAFILE% > NUL
:end1
@mkdir firefox_profile 2> NUL
@java -jar bin\uncompress.jar firefox_profile.zip firefox_profile > NUL
@del /F firefox_profile.install > NUL

:end
