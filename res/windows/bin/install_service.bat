@set PATH=%SYSTEMROOT%\System32\;%PATH%

@echo "Cleaning up"
@net stop freenet-darknet
@wrapper-windows-x86-32.exe -r ../wrapper.conf
@echo "Registering Freenet as a system service"
@wrapper-windows-x86-32.exe -i ../wrapper.conf
