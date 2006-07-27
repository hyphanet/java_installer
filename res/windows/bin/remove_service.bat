@set PATH=%SYSTEMROOT%\System32\;%PATH%

@echo "Cleaning up"
@net stop freenet-darknet
@echo "Unregistering Freenet as a system service"
@wrapper-windows-x86-32.exe -r ../wrapper.conf
@pause
