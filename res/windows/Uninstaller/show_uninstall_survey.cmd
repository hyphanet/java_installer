@set URL=http://spreadsheets.google.com/viewform?key=pARgKQ0i0ggo42b-G3If4Iw

@echo Trying to open "%URL%"
@start "" "%URL%"
@if errorlevel 1 goto argh
@goto end
:argh
@echo Starting the page failed, attempting to load directly in IE
@start "" /B "%ProgramFiles%\Internet Explorer\iexplore.exe" "%URL%"
:end
