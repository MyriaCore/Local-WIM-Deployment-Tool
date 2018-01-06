
:: Copyright 2018 Jonathan Zarnstorff
:: <p>
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
:: <p>
:: http://www.apache.org/licenses/LICENSE-2.0
:: <p>
:: Unless required by applicable law or agreed to in writing, software

@echo off
setlocal enabledelayedexpansion

:: DISM DOCS ===
:: DISM Main - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14
:: DISM /Capture-Image - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14#capture-image
:: DISM /Export-Image - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14#export-image
:: DISM /Apply-Image - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14#apply-image
:: DISM /Append-Image - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14#append-image
:: DISM /Mount-Image - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14#mount-image
:: DISM /Commit-Image - https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14#commit-image


::TODO =============
::Info:
::Figure out how to make a wim into esd(need export?)
::Figure out how multiple images work in regard to the windows installer.

::Implementation:
::Figure out how to split a string by space, but respect quotes.
::(maybe split my quotes then split every other one by spaces?)
:: All functionality Finished! Need to test: Capture, Build, Export
::Make Help Commands more clear:
::	User may not necessarily know that "Build" == *.esd, and "Image" == *.wim, and that "Volume" == A specific volume pertaining to the Capture Dir, Install Disk Dir, etc.
::Rethink Index Label (You seem to have just used the weird dp0 thingy, so I'm just gonna comment out Index and go w/ that)
::Cry because we're using batch
::Write some nice things in the README.md file :D



::Print Welcome Instructions
echo Welcome to the WespenJagerWindows Deployment Tool.
echo "Type 'help' for help, or 'help [command]' for help with a specific command."
goto Main

:: setup workspace
REM echo Enter the workspace directory. Usage: C:\MyWorkspaceDirectory
REM set /p workspaceroot="Workspace Directory: "
REM goto Index



::Setup Main Loop
:Main
	set /p command="Deployment Tool> "
	cls
	set /a count=0
	for %%i in (%command%) do (
		set "command!count!=%%i"
		set /a count+=1
	)

	::Handle commands
	if /I "%command0%"=="Help" (
		if not defined command1 (
			goto Help
		)
		goto Help%command1%
	)
	:: If the user's command doesn't match up with any existing commands, throw an error.
	if /I "%command0%"=="Capture" (
	    goto Capture
    )
    if /I "%command0%"=="Build" (
        goto Build
    )
    if /I "%command0%"=="Export" (
        goto Export
    )
    if /I "%command0%"=="Exit" (
        exit /b
    )
    echo Unknown command. Type 'help' for help.
    goto Main

:: Tested! It Works!
:Capture
	::Set high-performance power scheme to speed deployment
	if /I "%command3%"=="/h" (call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
	:: If Images Folder doesn't exist, create it and continue.
	mkdir "%~dp0Images"
	dism /Capture-Image /ImageFile:"%~dp0Images\%command2%.wim" /CaptureDir:%command1%\ /Name:"%command2%" /Compress:max /CheckIntegrity

goto Main

:: Need to test!
:Build
	:: Debugging Notes =======
	:: Batch file Can't excecute the final for loop.
	:: When I isolate the dism command and run that by itself, it throws DISM Error 87.
	:: This error seems to be for if you make a syntax error in the dism command
	:: I've searched far and wide, but I cannot find where I have it wrong.
	:: To test, I've found the dism logs and pulled out what it ended up writing as a dism command.
	:: Here is what it excecuted as:
	:: dism  /Export-Image /SourceImageFile:H:\Images\testimage.wim /DestinationImageFile:H:\Builds\testbuild.esd /Compress:recovery /CheckIntegrity
	:: H: is the drive I have the DeploymentTool.bat on. an Images and Builds foler exists at its root.
	:: I've fiddled with this specific command in isolation, but it seems that we simply are getting the /Export-Image command wrong somehow.
	:: I'm leaving a link to my DISM logs if you want to look through them.
	:: DISM Log: https://goo.gl/xU2dHc (It's a gist)

	:: Looks for /h as last command
	for %%i in (%command%) do (
		if /I "%%i"=="/h" (call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
	)

	:: If Images Folder doesnt exist, throw an error
	:: If Builds Folder doesn't exist, create it and continue
	if not exist %~dp0Images (
		echo "Imgaes folder does not exist!"
		goto Main
	)
	if not exist %~dp0Builds (
		mkdir %~dp0Builds
	)

	:: Loops through ImageNames and exports them into a Build with filename BuildName
	:: Can't get here and instead exits with the message "Syntax is incorrect" or something like that
	for %%i in (%command%) do (
		if /I not %%i==%command0% (if /I not %%i==%command1% (
			dism /Export-Image /SourceImageFile:"%~dp0Images\%%i.wim" /DestinationImageFile:"%~dp0Builds\%command1%.esd" /Compress:recovery /CheckIntegrity
		) )
	)
goto Main

:: Need to test!
:Export
	::Set high-performance power scheme to speed deployment
	if /I "%command3%"=="/h" (call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)

	echo "Beginning to export to drive: %command1%"
	copy "%~dp0Builds\%command2%.esd" "%command1%\sources\install.esd" /Y /B
    echo "Export complete, install.esd was replaced!"
goto Main

:: Commented out Index Label
REM :Index
REM 	set imagecount=0
REM 	set buildcount=0
REM 	mkdir %workspaceroot%
REM
REM 	for /R "%workspaceroot%\" %%g in (*.wim) do (
REM         set imagenamearray[%imagecount%]=%%g
REM         set imagecount+=1
REM 	)
REM
REM     for /R "%workspaceroot%\" %%g in (*.esd) do (
REM         set buildnamearray[%buildcount%]=%%g
REM         set buildcount+=1
REM     )
REM goto Main

::Setup Help
:Help
	echo ----------------------------------
	echo Availible Commands:
	echo capture [volume] [name] /h      ^| Creates an image.
	echo build [buildName] [names]... /h ^| Builds an ESD.
	echo export [volume] [buildName] /h  ^| Exports an ESD to bootable media.
	REM echo index                           ^| Re-Indexes the workspace
	echo exit                            ^| Exits the Deployment Tool.
	echo help [command]                  ^| Shows detailed help.
	echo ----------------------------------
goto Main

:HelpCapture
	echo ----------------------------------
	echo Command: capture [volume] [name] /h
	echo Usage: capture C: MyImage /h
	echo volume: The volume letter to caputure an image of.
	echo name: The name to give the captured image.
	echo /h: Use high performance mode to create the image faster.
	echo ----------------------------------
goto Main

:HelpBuild
	echo ----------------------------------
	echo build [buildName] [names]... /h
	echo Usage: build MyBuild MyFirstImage MySecondImage
	echo buildName: The name of the build.
	echo names...: A list of image names to add to the build, or blank to build all.
	echo /h: Use high performance mode to build the ESD faster.
	echo ----------------------------------
goto Main

:HelpExport
	echo ----------------------------------
	echo Command: export [volume] [buildName] /h
	echo Usage: export F: MyBuild /h
	echo volume: The volume containing bootable media to export to.
	echo buildName: The name of the build to export.
	echo /h: Use high performance mode to export the build faster
	echo ----------------------------------
goto Main
