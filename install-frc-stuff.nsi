!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "Plugins\strExplode.nsh"
!addplugindir "Plugins\"

!define MUI_ICON "Graphics\installer-icon.ico"
!define MUI_WELCOMEPAGE_TEXT "This GUI will guide you through installing all of the necessary software for FRC programming"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "Graphics\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "Graphics\wf.bmp"

Name "Install FRC Stuff"
InstallDir "$PROFILE\frc-installers"
OutFile "install-frc-stuff.exe"
RequestExecutionLevel admin

Var WPILibVersion
Var WLVersionBackup
Var WLOutFile
Var VersionSelectionBox
Var NIVersion
Var NIVersionBackup
Var NIOutFile
Var Dialog
Var Label
Var RHCVersion
Var RHCVersionBackup
Var RHCOutFile
Var ChoreoVersion
Var ChoreoVersionBackup
Var ChoreoOutFile
Var GitDownload
Var GitOutFile
Var STR_HAYSTACK
Var STR_NEEDLE
Var STR_CONTAINS_VAR_1
Var STR_CONTAINS_VAR_2
Var STR_CONTAINS_VAR_3
Var STR_CONTAINS_VAR_4
Var STR_RETURN_VAR

!insertMacro MUI_PAGE_WELCOME
Page custom nsDP nsDPLeave "- VERSION SELECTOR: WPILIB"
Page custom nsDP2 nsDPLeave2 "- VERSION SELECTOR: NI FRC GAME TOOLS"
Page custom nsDP4 nsDPLeave4 "- VERSION SELECTOR: REV HARDWARE CLIENT"
Page custom nsDP5 nsDPLeave5 "- VERSION SELECTOR: CHOREO"
!define MUI_COMPONENTSPAGE_NODESC
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION RunFinishInstallation
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Function RunFinishInstallation
    nsExec::ExecToStack 'cmd /c start "Run Installers" powershell -File "$EXEDIR\lib\runinstallers.ps1" -wpi "$WLOutFile" -rhc "$RHCOutFile" -chor "$ChoreoOutFile" -git "$GitOutFile" -ni "$NIOutFile"'
FunctionEnd

Function GetWPILibVersions
    Exch $R0
    nsExec::ExecToStack "$EXEDIR\VersionManager.exe -$R0"
    Pop $0
    Pop $0
    Push $0
FunctionEnd

Function nsDP
    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
          Abort
    ${EndIf}
    Push "w"
    Call GetWPILibVersions
    Pop $1
    ${NSD_CreateLabel} 0 0 100% 12u "Choose WPILib version (alpha/beta builds omitted)"
    Pop $Label
    ${NSD_CreateListBox} 0 50 200 100 ""
    Pop $VersionSelectionBox
    ${strExplode} $0 '|' $1
    ${do}
        Pop $1
        ${If} ${Errors}
              ClearErrors
              ${ExitDo}
        ${Else}
               Push $1
               Push "v"
               Call StrContains
               Pop $0
               StrCmp $0 "" notversion
                    ${NSD_LB_AddString} $VersionSelectionBox $1
                    StrCpy $WLVersionBackup $1
               notversion:
        ${EndIf}
    ${loop}
    !insertMacro MUI_HEADER_TEXT "Choose WPILib Version" "Press next to default to latest"
    nsDialogs::Show
FunctionEnd

Function nsDP2
    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
          Abort
    ${EndIf}
    Push "n"
    Call GetWPILibVersions
    Pop $1
    ${NSD_CreateLabel} 0 0 100% 12u "Choose NI FRC Game Tools version"
    Pop $Label
    ${NSD_CreateListBox} 0 50 200 100 ""
    Pop $VersionSelectionBox
    ${strExplode} $0 '|' $1
    ${do}
         Pop $1
         ${If} ${Errors}
               ClearErrors
               ${ExitDo}
         ${Else}
                Push $1
                Push "ni"
                Call StrContains
                Pop $0
                StrCmp $0 "" notversion
                       ${NSD_LB_AddString} $VersionSelectionBox $1
                       StrCpy $NIVersionBackup $1
                notversion:
         ${EndIf}
    ${loop}
    !insertMacro MUI_HEADER_TEXT "Choose NI FRC Game Tools Version" "Press next to default to latest"
    nsDialogs::Show
FunctionEnd

Function nsDP4
    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
          Abort
    ${EndIf}
    Push "r"
    Call GetWPILibVersions
    Pop $1
    ${NSD_CreateLabel} 0 0 100% 12u "Choose Rev Hardware Client version (alpha/beta builds omitted)"
    Pop $Label
    ${NSD_CreateListBox} 0 50 200 100 ""
    Pop $VersionSelectionBox
    StrCpy $RHCVersionBackup ""
    ${strExplode} $0 '|' $1
    ${do}
         Pop $1
         ${If} ${Errors}
               ClearErrors
               ${ExitDo}
         ${Else}
                Push $1
                Push "rhc"
                Call StrContains
                Pop $0
                StrCmp $0 "" notversion
                       ${NSD_LB_AddString} $VersionSelectionBox $1
                       StrCmp $RHCVersionBackup "" nobackup
                       Goto hasbackup
                       nobackup:
                       StrCpy $RHCVersionBackup $1
                       hasbackup:
                notversion:
         ${EndIf}
    ${loop}
    !insertMacro MUI_HEADER_TEXT "Choose REV Hardware Client Version" "Press next to default to latest"
    nsDialogs::Show
FunctionEnd

Function nsDP5
    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
          Abort
    ${EndIf}
    Push "c"
    Call GetWPILibVersions
    Pop $1
    ${NSD_CreateLabel} 0 0 100% 12u "Choose Choreo version (alpha/beta builds omitted)"
    Pop $Label
    ${NSD_CreateListBox} 0 50 200 100 ""
    Pop $VersionSelectionBox
    StrCpy $ChoreoVersionBackup ""
    ${strExplode} $0 '|' $1
    ${do}
         Pop $1
         ${If} ${Errors}
               ClearErrors
               ${ExitDo}
         ${Else}
                Push $1
                Push "v"
                Call StrContains
                Pop $0
                StrCmp $0 "" notversion
                       ${NSD_LB_AddString} $VersionSelectionBox $1
                       StrCmp $ChoreoVersionBackup "" nobackup
                       Goto hasbackup
                       nobackup:
                       StrCpy $ChoreoVersionBackup $1
                       hasbackup:
                notversion:
         ${EndIf}
    ${loop}
    !insertMacro MUI_HEADER_TEXT "Choose Choreo Version" "Press next to default to latest"
    nsDialogs::Show
FunctionEnd

Function StrContains
  Exch $STR_NEEDLE
  Exch 1
  Exch $STR_HAYSTACK
  ; Uncomment to debug
  ;MessageBox MB_OK 'STR_NEEDLE = $STR_NEEDLE STR_HAYSTACK = $STR_HAYSTACK '
    StrCpy $STR_RETURN_VAR ""
    StrCpy $STR_CONTAINS_VAR_1 -1
    StrLen $STR_CONTAINS_VAR_2 $STR_NEEDLE
    StrLen $STR_CONTAINS_VAR_4 $STR_HAYSTACK
    loop:
      IntOp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_1 + 1
      StrCpy $STR_CONTAINS_VAR_3 $STR_HAYSTACK $STR_CONTAINS_VAR_2 $STR_CONTAINS_VAR_1
      StrCmp $STR_CONTAINS_VAR_3 $STR_NEEDLE found
      StrCmp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_4 done
      Goto loop
    found:
      StrCpy $STR_RETURN_VAR $STR_NEEDLE
      Goto done
    done:
   Pop $STR_NEEDLE ;Prevent "invalid opcode" errors and keep the
   Exch $STR_RETURN_VAR
FunctionEnd

Section "WPILib" wpilib_id
    SetOutPath $INSTDIR
    StrCpy $0 $WPILibVersion
    ${strExplode} $2 "#" $0
    Pop $0
    StrCpy $1 $0 200 1
    inetc::get "https://packages.wpilib.workers.dev/installer/$0/Win64/WPILib_Windows-$1.iso" "$INSTDIR\WPILib_Windows-$1.iso"
    StrCpy $WLOutFile "$INSTDIR\WPILib_Windows-$1.iso"
SectionEnd

Section "NI Frc Game Tools" ni_frc_id
    SetOutPath $INSTDIR
    StrCpy $0 $NIVersion
    ${strExplode} $2 "#" $0
    Pop $0
    inetc::get "https://packages.wpilib.workers.dev/game-tools/$0" "$INSTDIR\$0"
    StrCpy $NIOutFile "$INSTDIR\$0"
SectionEnd
Section "Rev Hardware Client" rhc_id
    SetOutPath $INSTDIR
    StrCpy $0 $RHCVersion
    ${strExplode} $2 "#" $0
    Pop $0
    StrCpy $1 $0 200 4
    inetc::get "https://github.com/REVrobotics/REV-Software-Binaries/releases/download/$0/REV-Hardware-Client-Setup-$1.exe" "$INSTDIR\REV-Hardware-Client-Setup-$1.exe"
    StrCpy $RHCOutFile "$INSTDIR\REV-Hardware-Client-Setup-$1.exe"
SectionEnd
Section "Choreo" chor_id
    SetOutPath $INSTDIR
    StrCpy $0 $ChoreoVersion
    ${strExplode} $2 "#" $0
    Pop $0
    inetc::get "https://github.com/SleipnirGroup/Choreo/releases/download/$0/Choreo-$0-Windows-x86_64.exe" "$INSTDIR\Choreo-$0-Windows-x86_64.exe"
    StrCpy $ChoreoOutFile "$INSTDIR\Choreo-$0-Windows-x86_64.exe"
SectionEnd
Section "Git For Windows" git_id
    SetOutPath $INSTDIR
    inetc::get $GitDownload "$INSTDIR\Git-Installer.exe"
    StrCpy $GitOutFile "$INSTDIR\Git-Installer.exe"
SectionEnd
Section "FRC PathPlanner (winget)"
    nsExec::ExecToStack 'cmd /c start "Install FRC PathPlanner" winget install "PathPlanner"'
SectionEnd
Section "Phoenix Tuner X (winget)"
    nsExec::ExecToStack 'cmd /c start "Install Phoenix Tuner X" winget install "Phoenix Tuner X"'
SectionEnd
Function nsDPLeave
    ${NSD_LB_GetSelection} $VersionSelectionBox $WPILibVersion
    StrCmp $WPILibVersion "" Bad
    Goto Good
    Bad:
        MessageBox MB_OK "No version selected, using $WLVersionBackup"
        StrCpy $WPILibVersion $WLVersionBackup
        Goto Good
    Good:
         ${strExplode} $0 "#" $WPILibVersion
         Pop $1
         Pop $1
         SectionSetSize ${wpilib_id} $1
FunctionEnd

Function nsDPLeave2
    ${NSD_LB_GetSelection} $VersionSelectionBox $NIVersion
    StrCmp $NIVersion "" Bad
    Goto Good
    Bad:
        MessageBox MB_OK "No version selected, using $NIVersionBackup"
        StrCpy $NIVersion $NIVersionBackup
        Goto Good
    Good:
        ${strExplode} $0 "#" $NIVersion
        Pop $1
        Pop $1
        SectionSetSize ${ni_frc_id} $1
FunctionEnd

Function nsDPLeave4
    ${NSD_LB_GetSelection} $VersionSelectionBox $RHCVersion
    StrCmp $RHCVersion "" Bad
    Goto Good
    Bad:
        MessageBox MB_OK "No version selected, using $RHCVersionBackup"
        StrCpy $RHCVersion $RHCVersionBackup
        Goto Good
    Good:
         ${strExplode} $0 "#" $RHCVersion
         Pop $1
         Pop $1
         SectionSetSize ${rhc_id} $1
FunctionEnd

Function nsDPLeave5
    ${NSD_LB_GetSelection} $VersionSelectionBox $ChoreoVersion
    StrCmp $ChoreoVersion "" Bad
    Goto Good
    Bad:
        MessageBox MB_OK "No version selected, using $ChoreoVersionBackup"
        StrCpy $ChoreoVersion $ChoreoVersionBackup
        Goto Good
    Good:
         ${strExplode} $0 "#" $ChoreoVersion
         Pop $1
         Pop $1
         SectionSetSize ${chor_id} $1
FunctionEnd

Function .onInit
    StrCpy $WLOutFile "none"
    StrCpy $RHCOutFile "none"
    StrCpy $ChoreoOutFile "none"
    StrCpy $GitOutFile "none"
    StrCpy $NIOutFile "none"
    Push "g"
    Call GetWPILibVersions
    Pop $0
    ${strExplode} $1 "#" $0
    Pop $0
    Pop $1
    StrCpy $GitDownload $0
    SectionSetSize ${git_id} $1
FunctionEnd