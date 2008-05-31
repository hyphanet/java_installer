@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if not exist frost.install goto nofrost
@del /F frost.install > NUL
@if exist offline goto end
@echo Downloading Frost
@java -jar bin\sha1test.jar frost/frost.zip . %CAFILE% > NUL
:end
@echo Setting Frost up
@mkdir frost
@java -jar bin\uncompress.jar frost.zip frost > NUL
:nofrost
:end
