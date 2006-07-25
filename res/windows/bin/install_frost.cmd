@echo "Downloading Frost"
@set PATH=%SYSTEMROOT%\System32\;%PATH%
@cd $INSTALL_PATH\bin
@java -jar sha1test.jar frost/frost.zip ../
@echo "Setting Frost up"
@mkdir ../frost
@java -jar uncompress.jar ../frost.zip ../frost
@echo "Done"
