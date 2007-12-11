@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

:: Keep application installers in case users want to perform updates
@cd bin
@del /F 1run.cmd setup.cmd detect_port_availability.cmd install_freenet-ext.cmd install_freenet-stable-latest.cmd install_plugins.cmd install_updater.cmd install_wrapper.cmd setup.cmd opennet.install offline 2> NUL > NUL
