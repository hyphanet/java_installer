@set PATH=%SYSTEMROOT%\System32\;%PATH%
@set INSTALL_PATH=$INSTALL_PATH
@set JAVA_HOME=$JAVA_HOME
@cd /D %INSTALL_PATH%

@if not exist frost goto nofrost 
@del /F frost > NUL
@if exist offline goto end
@echo "Downloading Frost"
@java -jar bin\sha1test.jar frost/frost.zip . > NUL
:end
@echo "Setting Frost up"
@mkdir frost
@java -jar bin\uncompress.jar frost.zip frost > NUL
:nofrost
