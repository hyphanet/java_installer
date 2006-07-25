@echo "Downloading jSite"
@set PATH=%SYSTEMROOT%\System32\;%PATH%
@cd $INSTALL_PATH\bin
@java -jar sha1test.jar jSite/jSite.jar ../
@echo "Done"
