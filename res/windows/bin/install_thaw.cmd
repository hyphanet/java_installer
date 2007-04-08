@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@if not exist thaw goto nothaw 
@del /F thaw > NUL
@echo "Downloading Thaw"
@echo @start javaw -jar Thaw.jar > thaw.cmd
@java -jar bin\sha1test.jar Thaw/Thaw.jar . > NUL
:nothaw
