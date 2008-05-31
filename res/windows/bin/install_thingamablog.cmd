@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@set CAFILE=startssl.pem
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if not exist thingamablog.install goto nothingamablog
@del /F thingamablog.install > NUL
@if exist offline goto end
@echo Downloading Thingamablog
@java -jar bin\sha1test.jar thingamablog/thingamablog.zip . %CAFILE% > NUL
:end
@echo Setting Thingamablog up
@java -jar bin\uncompress.jar thingamablog.zip . > NUL
@echo @cd thingamablog-testing > thingamablog.cmd
@echo @start javaw -jar thingamablog.jar >> thingamablog.cmd
:nothingamablog
:end
