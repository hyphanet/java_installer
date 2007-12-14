@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@if not exist opennet.install goto end
@del /F opennet.install > NUL

@if exist offline goto end
@echo Downloading the Opennet seednode file
@java -jar bin\sha1test.jar opennet/seednodes.fref . > NUL
:end
