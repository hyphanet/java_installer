@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@if exist offline goto end
@echo "Downloading freenet-ext.jar"
@java -jar bin\sha1test.jar freenet-ext.jar . > NUL
:end
