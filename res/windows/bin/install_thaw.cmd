@echo "Downloading Thaw"
@set PATH=%SYSTEMROOT%\System32\;%PATH%
@cd $INSTALL_PATH\bin
@java -jar sha1test Thaw/Thaw.jar ../
@echo "Done"
