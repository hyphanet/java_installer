@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if exist offline goto end1
@echo Downloading freenet-stable-latest.jar
@java -jar bin\sha1test.jar freenet-stable-latest.jar . %CAFILE% > NUL
:end1
@copy freenet-stable-latest.jar freenet.jar > NUl
:end
