@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@if exist offline goto end
@echo Downloading freenet-stable-latest.jar
@java -jar bin\sha1test.jar freenet-stable-latest.jar . > NUL
:end
@copy freenet-stable-latest.jar freenet.jar > NUl
