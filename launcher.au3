#RequireAdmin

#include <Array.au3>
#include <Math.au3>
#include <AutoItConstants.au3>
#include <StringConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Opt("TrayIconHide", 1)
Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)


Dim $INILocation = @ScriptDir & "\launch.ini"
FileChangeDir(@ScriptDir)

; Global Settings
Dim $GUItitle = IniRead($INILocation, "General", "Title", "1337 App Installer")
Dim $GUIIcon = IniRead($INILocation, "General", "Icon", "")
Dim $GUIHandle
Dim $SoftwarePerPage = IniRead($INILocation, "General", "SoftwarePerRow", 20)
Dim $SortEntries = IniRead($INILocation, "General", "SortEntries", 1)
Dim $ExitafterInstall = IniRead($INILocation, "General", "ExitafterInstall", 0)
Dim $TimeOut = IniRead($INILocation, "General", "TimeOut", 0)
Dim $DiskLabel = StringLower(IniRead($INILocation, "General", "DiskLabel", "no label specified"))
Dim $CleanupCMD = IniRead($INILocation, "General", "CleanupCMD", "")
Dim $ColumnWidth = Int(IniRead($INILocation, "General", "ColumnWidth", "250"))
Dim $HiddenState = IniRead($INILocation, "General", "StartHidden", "0")
Dim $AlwaysOnTop = IniRead($INILocation, "General", "AlwaysOnTop", "0")

; Global runtime variables
Dim $NumberofEntries = 0
Dim $NumberofPresets = 0
Dim $PresetNames[0]
Dim $Disk = ""
Dim $MAINArray[0]
Dim $ProgressBar
Dim $OKButton

; Start running..
Main()

Func Main()
   FindSourceDrive()
   GetEntries()
   BuildGUI()

   If $TimeOut <> 0 Then
	   AdlibRegister("timeout", 1000)
	   HotKeySet("^c", "StopCountdown")
   EndIf

   While 1
	   Sleep(1000)
   WEnd
EndFunc

; ------------ FUNCTIONS------------------
Func BuildGUI()
   $GUItitle = $GUItitle & "  (USB@" & $Disk & ")"

   $NumberofEntries = UBound($MAINArray)
   Local $NumberofRows = Ceiling(($NumberofEntries) / $SoftwarePerPage)
   Local $GUIwidth = $NumberofRows * $ColumnWidth

   If $NumberofEntries <= $SoftwarePerPage Then
	   Dim $GUIheight = 20 * $NumberofEntries + 70 + 40
   Else
	   Dim $GUIheight = 20 * $SoftwarePerPage + 70 + 40
   EndIf

   Local $ExFlags = 0
   If $AlwaysOnTop = "1" Then $ExFlags = $WS_EX_TOPMOST

   $GUIHandle = GUICreate($GUItitle, $GUIwidth, $GUIheight, default, default, default, $ExFlags)
   If $GUIIcon <> "" Then
	  GUISetIcon($GUIIcon)
   EndIf

   For $row = 0 To $NumberofRows - 1
	  Local $checkboxheight = 0
	  For $i = $row * $SoftwarePerPage to (($row + 1) * $SoftwarePerPage - 1)
		 If $i >= $NumberofEntries Then ExitLoop
		 $MAINArray[$i][4] = GUICtrlCreateCheckbox($MAINArray[$i][0], 3 + $row * $ColumnWidth, ($checkboxheight * 20) + 44)
		 If $MAINArray[$i][5] <> "" Then GUICtrlSetTip(-1, $MAINArray[$i][5])
		 If $MAINArray[$i][6] = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
		 $checkboxheight = $checkboxheight + 1
	  Next
   Next

   $OKButton = GUICtrlCreateButton("INSTALL!", $GUIwidth / 2 - 75, 3, 150, 35)
   Local $TimeoutText = IniRead($INILocation, "General", "TextCancelCountdown", "Ctrl-C to stop countdown")
   If $TimeOut <> 0 Then GUICtrlCreateLabel($TimeoutText, $GUIwidth / 2 + 75 + 10, 13)
   Local $SelectMenu = GUICtrlCreateMenu("&Presets")
   Local $AboutMenu = GUICtrlCreateMenu("&About")
   Local $InfoButton = GUICtrlCreateMenuItem("About..", $AboutMenu)
   Local $SelectText = IniRead($INILocation, "General", "TextPresetNone", "&None")
   Local $SelectNone = GUICtrlCreateMenuItem($SelectText, $SelectMenu)

   $ProgressBar = GUICtrlCreateProgress(10, $GUIheight - 50, $GUIwidth - 20, 25)

   GUICtrlCreateMenuItem("", $SelectMenu)
   For $i = 0 to $NumberofPresets-1
	   Local $preset = GUICtrlCreateMenuItem($PresetNames[$i], $SelectMenu)
	   GUICtrlSetOnEvent($preset, "Preset" & $i)
   Next
   GUISetOnEvent($GUI_EVENT_CLOSE, "Close")
   GUICtrlSetOnEvent($OKButton, "InstallButton")
   GUICtrlSetOnEvent($InfoButton, "Info")
   GUICtrlSetOnEvent($SelectNone, "Clear")
   activatePreset(1)
   GUISetState(@SW_SHOW)

EndFunc

Func GetEntries()
   Local $INISections = IniReadSectionNames($INILocation)
   If @error Then
	   MsgBox(16, "Error", "Unable to read .ini File.")
	   Exit
   EndIf

   ReDim $PresetNames[9]
   $NumberofPresets = 0
   While 1
	   Local $val = IniRead($INILocation, "General", "Preset" & ($NumberofPresets+1), "none")
	   If $val <> "none" Then
		   $PresetNames[$NumberofPresets] = $val
		   $NumberofPresets = $NumberofPresets+1
	   Else
		   ExitLoop
	   EndIf
   WEnd

   Dim $NumberofEntries = $INISections[0] - 1

   If $NumberofEntries = 0 Then
	   MsgBox(16, "Error", "No sections found in configuration");
	   Exit(1)
	EndIf

	For $i = 1 To UBound($INISections) - 2
	   If $INISections[$i] = "General" Then _ArrayDelete($INISections, $i)
   Next

   If $SortEntries <> 0 Then _ArraySort($INISections, 0, 1)

   ReDim $MAINArray[$NumberofEntries][7]  ; 0= Name, 1= Command1, 2=Command2 3=Command3 4=ControlID 5=Tooltip 6=Presetgroups
   For $i = 0 To $NumberofEntries - 1
	  $MAINArray[$i][0] = $INISections[$i + 1]
	  $MAINArray[$i][1] = StringReplace(IniRead($INILocation, $INISections[$i + 1], "Command1", "No Command in .ini found!"), "SOURCE_DRIVE", $Disk)
	  $MAINArray[$i][2] = StringReplace(IniRead($INILocation, $INISections[$i + 1], "Command2", ""), "SOURCE_DRIVE", $Disk)
	  $MAINArray[$i][3] = StringReplace(IniRead($INILocation, $INISections[$i + 1], "Command3", ""), "SOURCE_DRIVE", $Disk)
	  $MAINArray[$i][5] = IniRead($INILocation, $INISections[$i + 1], "ToolTip", "")
	  $MAINArray[$i][6] = IniRead($INILocation, $INISections[$i + 1], "Preset", "0")
   Next

   Return $MAINArray
EndFunc

Func FindSourceDrive()
   Local $drives = DriveGetDrive($DT_ALL)

   If Not @error Then
	  For $i = 1 to $drives[0]
		  If StringInStr(DriveGetLabel($drives[$i]), $DiskLabel, $STR_NOCASESENSE) = 1 Then
			  ; wanted found at the beginning of drive label
			  $Disk = $drives[$i]
			  ExitLoop
		 EndIf
	  Next
   EndIf

   If $Disk = "" Then
	   $Disk = InputBox("Error", "Source drive could not be found. Please enter drive letter manually", "e:")
	   If $Disk = "" Then Exit(1)
   EndIf
EndFunc


Func RunWithCheck($command, $workdir, $hide = False)
   If $hide <> 0 Then
	  RunWait($command, $workdir, @SW_HIDE)
   Else
	  RunWait($command, $workdir)
   EndIf
   If @error Then MsgBox(48, "Error", "Error launching " & @CRLF & $command & @CRLF & @CRLF & "Working Directory: " & $workdir, 10)
EndFunc

Func Install()
	StopCountdown()
	WinActivate($GUIHandle)
	Local $count = 0
	For $i = 0 To $NumberofEntries - 1
		If GUICtrlRead($MAINArray[$i][4]) = $GUI_CHECKED Then
			$count = $count +1
		EndIf
	Next
	Local $progress = 0
	Local $step = 100 / $count

	GUICtrlSetState($OKButton, $GUI_DISABLE)
	For $i = 0 To $NumberofEntries - 1
		If GUICtrlRead($MAINArray[$i][4]) = $GUI_CHECKED Then
			GUICtrlSetFont($MAINArray[$i][4], default, "", 4)
			RunWithCheck($MAINArray[$i][1], @ScriptDir, $HiddenState)
			If $MAINArray[$i][2] <> "" Then RunWithCheck($MAINArray[$i][2], @ScriptDir, $HiddenState)
			If $MAINArray[$i][3] <> "" Then RunWithCheck($MAINArray[$i][3], @ScriptDir, $HiddenState)

			GUICtrlSetState($MAINArray[$i][4], $GUI_UNCHECKED)
			GUICtrlSetState($MAINArray[$i][4], $GUI_DISABLE)
			GUICtrlSetFont($MAINArray[$i][4], default, "", 8)
			$progress += $step
			GUICtrlSetData($ProgressBar, Round($progress))
		EndIf
	Next
	If $CleanupCMD <> "" Then
		RunWait(StringReplace($CleanupCMD, "SOURCE_DRIVE", $Disk))
	EndIf
	If $ExitafterInstall = 1 Then Exit
	GUICtrlSetState($OKButton, $GUI_ENABLE)
EndFunc   ;==>install

Func TimeOut()
	If $TimeOut = 0 Then
		AdlibUnRegister()
		install()
	EndIf
	GUICtrlSetData($OKButton, "INSTALL! (" & $Timeout & ")")
	$TimeOut = $TimeOut - 1
EndFunc   ;==>TimeOut

Func StopCountdown()
	AdlibUnRegister()
	HotKeySet("^c")
	GUICtrlSetData($OKButton, "INSTALL!")
EndFunc   ;==>StopCountdown

Func Close()
	Exit(0)
EndFunc

Func Info()
	MsgBox(64, "About", "Customizable Application Launcher 2020" & @CRLF & @CRLF & "Contact: github.com/ict/CustomAppLauncher")
EndFunc

Func Clear()
	activatePreset("a")
EndFunc

Func Preset0()
	activatePreset(1)
EndFunc

Func Preset1()
	activatePreset(2)
EndFunc

Func Preset2()
	activatePreset(3)
EndFunc

Func Preset3()
	activatePreset(4)
EndFunc

Func Preset4()
	activatePreset(5)
EndFunc

Func Preset5()
	activatePreset(6)
EndFunc

Func Preset6()
	activatePreset(7)
EndFunc

Func Preset7()
	activatePreset(8)
EndFunc

Func Preset8()
	activatePreset(9)
EndFunc

Func activatePreset($n)
	For $i = 0 To $NumberofEntries - 1
		If StringInStr($MAINArray[$i][6], $n) Then
			GUICtrlSetState($MAINArray[$i][4], $GUI_CHECKED)
		Else
			GUICtrlSetState($MAINArray[$i][4], $GUI_UNCHECKED)
		EndIf

	Next
EndFunc

Func InstallButton()
	install()
EndFunc
