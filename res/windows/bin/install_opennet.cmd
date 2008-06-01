@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if not exist opennet.install goto end
@del /F opennet.install > NUL

@if exist offline goto end
@echo Downloading the Opennet seednode file
@java -jar bin\sha1test.jar seednodes.fref . %CAFILE% > NUL
:end
