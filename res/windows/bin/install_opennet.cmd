@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@if not exist opennet goto noopennet
@echo Enabling Opennet
@echo node.opennet.enabled=true >> freenet.ini
@del /F opennet > NUL
:noopennet
