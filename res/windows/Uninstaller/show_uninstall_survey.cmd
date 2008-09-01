@set URL=http://freenetproject.org/uninstall.html

@echo Trying to open "%URL%"
@start "" "%URL%"
@if errorlevel 1 goto argh
@goto end
:argh
@echo Starting the page failed, attempting to load directly in IE
@start "" /B "%ProgramFiles%\Internet Explorer\iexplore.exe" "%URL%"
:end
