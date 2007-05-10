@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@echo "Downloading update.cmd"
@if exist offline goto end
@java -jar bin\sha1test.jar update/update.cmd . > NUL
:end
@echo node.updater.enabled=true >> freenet.ini

@if not exist update goto noautoupdate
@echo node.updater.autoupdate=true >> freenet.ini
@del /F update > NUL
:noautoupdate
