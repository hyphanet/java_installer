@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%
@if exist .isInstalled goto end

@if not exist jsite.install goto nojsite
@del /F jsite.install > NUL
@if exist offline goto end
@echo Downloading jSite
@mkdir jSite
@java -jar bin\sha1test.jar jSite/jSite.jar > NUL
@move jSite.jar jSite > NUL
:end
@echo @cd jSite > jsite.cmd
@echo @start javaw -jar jSite.jar >> jsite.cmd
:nojsite
:end
