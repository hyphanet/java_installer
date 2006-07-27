@echo "Downloading JSTUN"
@set PATH=%SYSTEMROOT%\System32\;%PATH%
@cd $INSTALL_PATH\bin
@mkdir ..\plugins
@java -jar sha1test.jar JSTUN.jar ../plugins
@echo "Done"
