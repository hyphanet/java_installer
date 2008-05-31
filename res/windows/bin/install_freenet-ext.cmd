@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if exist offline goto end
@echo Downloading freenet-ext.jar
@java -jar bin\sha1test.jar freenet-ext.jar . %CAFILE% > NUL
:end
