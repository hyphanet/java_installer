@set PATH=%SYSTEMROOT%\System32\;%PATH%
@cd "$INSTALL_PATH"
@echo "Downloading freenet-cvs-snapshot.jar"
@java -jar bin\sha1test.jar freenet-cvs-snapshot.jar "$INSTALL_PATH"
@echo "Downloading freenet-ext.jar"
@java -jar bin\sha1test.jar freenet-ext.jar "$INSTALL_PATH"
@echo "Installing the wrapper"
@echo "Registering Freenet as a system service"
@bin\wrapper-windows-x86-32.exe -i ../wrapper.conf
@net start freenet-darknet
@echo "Waiting for freenet to startup"
@ping -n 10 127.0.0.1 >nul
@echo "Spawing up a browser"
@start http://127.0.0.1:8888
@echo "Finished"
