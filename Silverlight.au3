#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Iconleak-Or-Light-bulb.ico
#AutoIt3Wrapper_Outfile_x64=SilverLight.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=SilverLight Updater
#AutoIt3Wrapper_Res_Fileversion=1.3.0.0
#AutoIt3Wrapper_Res_ProductVersion=1.3.0.0
#AutoIt3Wrapper_Res_LegalCopyright=carm0@sourceforge
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <InetConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include <EventLog.au3>
If UBound(ProcessList(@ScriptName)) > 2 Then Exit
Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayOnEventMode", 1) ; Enable TrayOnEventMode.
TrayCreateItem("About")
TrayItemSetOnEvent(-1, "About")
TrayCreateItem("") ; Create a separator line.
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "ExitScript")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "About") ; Display the About MsgBox when the tray icon is double clicked on with the primary mouse button.
TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.

Local $ecode, $CVersion

Func About()
	; Display a message box about the AutoIt version and installation path of the AutoIt executable.
	MsgBox(32, "Silverlight", "" & @CRLF & _
			"Silverlight installer by Carm0@sourceforge", 4) ; Find the folder of a full path.
EndFunc   ;==>About

Func ExitScript()
	Exit
EndFunc   ;==>ExitScript

Global $sBase_x32 = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
Global $sBase_x64 = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
SplashTextOn("Progress", "", 220, 60, -1, -1, 16, "Tahoma", 10)
Getversion()
Uninstall1()
Silverlight()
SplashOff()
;FileDelete("C:\windows\temp\Silverlight_x64.exe")
Exit

Func Getversion()

	$dia = 'http://go.microsoft.com/fwlink/?LinkId=229321'
	$hDownload2 = InetGet($dia, "C:\windows\temp\" & "\Silverlight_x64.exe", $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
	ControlSetText("Progress", "", "Static1", "Downloading Silverlight", 2)
	Do
		Sleep(200)
	Until InetGetInfo($hDownload2, $INET_DOWNLOADCOMPLETE)
	Sleep(500)

	$CVersion = StringStripWS(FileGetVersion("C:\windows\temp\" & "\Silverlight_x64.exe", $FV_FILEDESCRIPTION), 3)
	If $CVersion <> "Self-Extracting Cabinet" Then
		$ecode = '404'
		EventLog()
		FileDelete("C:\windows\temp\Silverlight_x64.exe")
		Exit
	EndIf

EndFunc   ;==>Getversion


Func Silverlight()
	ControlSetText("Progress", "", "Static1", "Installing Silverlight", 2)
	; Download the file in the background with the selected option of 'force a reload from the remote site.'
	;$Version = $Version5 & " - 32bit"
	;_webDownloader('http://go.microsoft.com/fwlink/?LinkId=229321', "Silverlight_x64.exe", "")
	$CMD1 = 'cd C:\Windows\Temp && ' & _
			'Silverlight_x64.exe /q /doNotRequireDRMPrompt'
	RunWait('"' & @ComSpec & '" /c ' & $CMD1, @SystemDir, @SW_HIDE)

	$CVersion = FileGetVersion("C:\Program Files\Microsoft Silverlight\sllauncher.exe", $FV_FILEVERSION)
	$name = FileGetVersion("C:\Program Files\Microsoft Silverlight\sllauncher.exe", $FV_PRODUCTNAME)
	If $name = "Microsoft® Silverlight" Then
		$ecode = '411'
		EventLog()
	ElseIf $name <> "Microsoft® Silverlight" Then
		$ecode = '667'
		EventLog()
		FileDelete("C:\windows\temp\Silverlight_x64.exe")
		Exit ('667')
	EndIf
	FileDelete("C:\windows\temp\Silverlight_x64.exe")
EndFunc   ;==>Silverlight



Func Uninstall1()
	ControlSetText("Progress", "", "Static1", "UnInstalling Silverlight", 2)
	$iEval = 1
	$sSearch = "Silverlight"
	While 1
		$sUninst = ""
		$sDisplay = ""
		$sCurrent = RegEnumKey($sBase_x32, $iEval)
		If @error Then ExitLoop
		$sKey = $sBase_x32 & $sCurrent
		$sDisplay = RegRead($sKey, "Displayname")
		If StringRegExp($sDisplay, "(?i).*" & $sSearch & ".*") Then
			$sUninst1 = StringSplit(RegRead($sKey, "UninstallString"), "/X", 1)
			$sUninst = $sUninst1[1] & ' /X' & $sUninst1[2] & ' /q'
			;MsgBox(0, "32", $sUninst)
			RunWait($sUninst)
			;Call('Uninstall1')
		EndIf
		$iEval += 1
	WEnd
EndFunc   ;==>Uninstall1


Func EventLog()

	If $ecode = '404' Then
		Local $hEventLog, $aData[4] = [0, 4, 0, 4]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 1, 0, 404, @UserName, @UserName & ' No "exe" found for SilverLIght. The webpage and/or download link might have changed. ' & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf

	If $ecode = '411' Then
		Local $hEventLog, $aData[4] = [0, 4, 1, 1]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 0, 0, 411, @UserName, @UserName & " SilverLIght " & "version " & $CVersion & " successfully installed." & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf

	If $ecode = '667' Then
		Local $hEventLog, $aData[4] = [0, 6, 6, 7]
		$hEventLog = _EventLog__Open("", "Application")
		_EventLog__Report($hEventLog, 1, 0, 667, @UserName, @UserName & " SilverLIght  install cannot be verified" & @CRLF, $aData)
		_EventLog__Close($hEventLog)
	EndIf

EndFunc   ;==>EventLog

; Silverlight download links ( direct )
; http://www.ryanvm.net/forum/viewtopic.php?t=10320&sid=4b51163a7c037f1016cb6b36a408d49b


