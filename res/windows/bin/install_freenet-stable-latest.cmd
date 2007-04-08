@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@echo "Downloading freenet-stable-latest.jar"
@java -jar bin\sha1test.jar freenet-stable-latest.jar . > NUL
@copy freenet-stable-latest.jar freenet.jar > NUl
