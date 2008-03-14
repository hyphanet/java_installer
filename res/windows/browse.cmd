@set COUNT=0
@for %%x in (%*) do ( @set /A COUNT=!COUNT!+1 )
@if %COUNT% LSS 1 @set URL=http://127.0.0.1:8888/ else @set URL=%1

@set /P FIREFOX=<firefox.location
@if not defined FIREFOX goto noff
@%FIREFOX% -no-remote -p freenet "%URL%"
@exit
:noff
@start "%URL%"
