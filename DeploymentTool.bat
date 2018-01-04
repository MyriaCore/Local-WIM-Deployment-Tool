@echo off
setlocal enabledelayedexpansion

::Print Welcome Instructions
echo Welcome to the WespenJagerWindows Deployment Tool.

:: setup workspace
echo Enter the workspace directory. Usage: C:\MyWorkspaceDirectory
set /p workspaceroot="Workspace Directory: "
goto Index 

goto Main


::Setup Main Loop
:Main
	set /p command="Deployment Tool: "
	cls
	set /a count=0
	for %%i in (%command%) do (
		set "command!count!=%%i"
		set /a count+=1
	)

	::Handle commands
	if %command0%==help (
		if not defined command1 (
			goto Help
		)
		goto Help%command1%
	) 
	if /I not "%command0%"=="Capture" if /I not "%command0%"=="Build" if /I not "%command0%"=="Export" if /I not "%command0%"=="Exit" (
		echo Unknown command. Type help for help.
		pause
		goto Main
	)

:Capture
	::Set high-performance power scheme to speed deployment
	if /I "%command3%"=="/h" (call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
	
	dism /Capture-Image /ImageFile:%workspaceroot%\%command2%.wim /CaptureDir:%command1%\ /Name:%command2% /Compress:max /CheckIntegrity /Verify
	
	goto Main


:Build
	
	for %%i in (%command%) do (
		if /I not "%%i"=="%command0%" if /I not "%%i"=="%command1%" (
			for %%j in imagenamearray[] do (
				set name = %%j
				:: Source: https://stackoverflow.com/questions/7005951/batch-file-find-if-substring-is-in-string-not-in-a-file
				if not x%name:bcd=%==x%name% echo It contains bcd
			)
		)
	)
	
	if "%command !count!"
	
	
	if %count%+1 equ 1 (
		
		dism /Export-Image /SourceImageFile:                /DestinationImageFile:             /Compress:recovery
		
		
	)
	
goto :Main


:Export
	echo export
goto :Main

:Index
	set imagecount=0
	set buildcount=0
	if exist %workspaceroot% (
	
		for /R "%workspaceroot%\" %%g in (*.wim) do (
			set imagenamearray[%imagecount%]=%%g
			set imagecount+=1
		)
	
		for /R "%workspaceroot%\" %%g in (*.esd) do (
			set buildnamearray[%buildcount%]=%%g
			set buildcount+=1
		)
	) 
	else (mkdir %workspaceroot%)
goto :eof
::goto :eof should end up *hopefully 

::Setup Help
:Help
	echo ----------------------------------
	echo Availible Commands:
	echo capture [volume] [name] /h      ^| Creates an image.
	echo build [buildName] [names]...    ^| Builds an ESD.
	echo export [volume] [buildName]     ^| Exports an ESD to bootable media.
	echo index                           ^| Re-Indexes the workspace
	echo exit                            ^| Exits the Deployment Tool.
	echo help [command]                  ^| Shows detailed help.
	echo ----------------------------------
goto :Main

:HelpCapture
	echo ----------------------------------
	echo Command: capture [volume] [name] /h
	echo Usage: capture C: MyImage /h
	echo volume: The volume letter to caputure an image of.
	echo name: The name to give the captured image.
	echo /h: Use high performance mode to create the image faster.
	echo ----------------------------------
goto :Main

:HelpBuild
	echo ----------------------------------
	echo build [buildName] [names]... /h
	echo Usage: build MyBuild MyFirstImage MySecondImage
	echo buildName: The name of the build.
	echo names...: A list of image names to add to the build, or blank to build all.
	echo /h: Use high performance mode to create the image faster.
	echo ----------------------------------
goto :Main

:HelpExport
	echo ----------------------------------
	echo Command: export [volume] [buildName]
	echo Usage: export F: MyBuild
	echo volume: The volume containing bootable media to export to.
	echo buildName: The name of the build to export.
	echo ----------------------------------
goto Main

:Exit
	exit /b