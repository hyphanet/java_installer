@set PATH=%SYSTEMROOT%\System32\;%PATH%

@echo Cleaning up
@bin\wrapper-windows-x86-32.exe -r ../wrapper.conf
@echo Registering Freenet as a system service
@bin\wrapper-windows-x86-32.exe -i ../wrapper.conf
