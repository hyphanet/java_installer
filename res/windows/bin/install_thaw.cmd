@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if not exist thaw.install goto nothaw 
@del /F thaw.install > NUL
@echo Downloading Thaw
@if exist offline goto end
@mkdir Thaw
@java -jar bin\sha1test.jar Thaw/Thaw.jar > NUL
@move Thaw.jar Thaw > NUL
:end
@echo Setting Thaw up
@echo @cd Thaw >thaw.cmd
@echo @start javaw -jar Thaw.jar >> thaw.cmd
:nothaw
:end
