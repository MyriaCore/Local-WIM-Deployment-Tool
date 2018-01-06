
:: Copyright 2018 Jonathan Zarnstorff, Marcus
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
echo Type 'help' for help, or 'help [command]' for help with a specific command.

if not exist "Builds" (
	mkdir Builds
)
if not exist "Images" (
	mkdir Images
)
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

	:: If the user's command doesn't match up with any existing commands, throw an error.
	echo Unknown command. Type 'help' for help.
goto Main

:Capture
	if %count% geq 3 (
		if /I "%command4%"=="/fd" (
			set /p description=<%command3%
		) else (
			set description=%command3%
		)
		echo dism /Capture-Image /ImageFile:Images\%command2%.wim /CaptureDir:%command1% /Name:%command2% /Description:!description! /Compress:max /CheckIntegrity
	) else (
		echo Not enough arguments! Type 'help capture' for help.
	)
goto Main

:Build
	if %count% geq 2 (
		if "%command2%"=="" (
			for %%f in (Images\*.wim) do (
				echo dism /Export-Image /SourceImageFile:Images\%%f /SourceName:%%~nf /DestinationImageFile:Builds\%command1%.esd /Compress:recovery /CheckIntegrity
			)
		) else (
			for %%i in (%command%) do (
        		if not %%i==%command0% (
        			if not %%i==%command1% (
        				echo dism /Export-Image /SourceImageFile:Images\%%i.wim /SourceName:%%i /DestinationImageFile:Builds\%command1%.esd /Compress:recovery /CheckIntegrity
        			)
        		)
        	)
		)
	)
	)else (
		echo Not enough arguments! Type 'help capture' for help.
	)
goto Main

:: Need to test!
:Export
	echo "Beginning to export to drive: %command1%"
	copy "Builds\%command2%.esd" "%command1~0,1%\sources\install.esd" /Y /B
    echo "Export complete, install.esd was replaced!"
goto Main

::Setup Help
:Help
	echo ----------------------------------
	echo Availible Commands:
	echo capture [directory] [name] [description] /fd  ^| Creates an image.
	echo build [buildName] [images]... ^| Builds an ESD.
	echo export [volume] [buildName]  ^| Exports an ESD to bootable media.
	echo exit                           ^| Exits the Deployment Tool.
	echo help [command]               ^| Shows detailed help.
	echo ----------------------------------
goto Main

:HelpCapture
	echo ----------------------------------
	echo Command: capture [directory] [name] [description] /fd
	echo Usage: capture C:\ MyImage MyDescription
	echo Usage: capture C:\ MyImage C:\description.txt /fd
	echo directory: The directory to caputure an image of.
	echo name: The name to give the image.
	echo description: The description to give to the image.
	echo /fd: Indicates that [description] is a file path.
	echo ----------------------------------
goto Main

:HelpBuild
	echo ----------------------------------
	echo build [buildName] [images]...
	echo Usage: build MyBuild MyFirstImage MySecondImage
	echo buildName: The name of the build.
	echo images...: A list of image names to add to the build, or blank to build all.
	echo ----------------------------------
goto Main

:HelpExport
	echo ----------------------------------
	echo Command: export [volume] [buildName] /h
	echo Usage: export F: MyBuild /h
	echo volume: The volume containing bootable media to export to.
	echo buildName: The name of the build to export.
	echo ----------------------------------
goto Main
