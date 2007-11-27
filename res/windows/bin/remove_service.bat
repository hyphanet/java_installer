@set PATH=%SYSTEMROOT%\System32\;%PATH%

if not exist wrapper-windows-x86-32.exe cd bin
@echo Cleaning up
@net stop freenet-darknet
@echo Unregistering Freenet as a system service
@wrapper-windows-x86-32.exe -r ../wrapper.conf
