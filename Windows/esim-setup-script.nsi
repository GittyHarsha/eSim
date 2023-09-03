;NSIS Modern User Interface
;Start Menu Folder Selection Example Script
;Modified by Fahim Khan, Saurabh Bansode, Rahul Paknikar, Sumanto Kar, Partha Singha Roy - 04_09_2023
;Made by eSim Team, FOSSEE, IIT Bombay

;--------------------------------
;Include Modern UI

 !include "MUI2.nsh"
 !include "ZipDLL.nsh"
 !include "x64.nsh"
;--------------------------------

;--------------------------------
; StrContains
; This function does a case sensitive searches for an occurrence of a substring in a string. 
; It returns the substring if it is found. 
; Otherwise it returns null(""). 
; Written by kenglish_hi
; Adapted from StrReplace written by dandaman32


Var STR_HAYSTACK
Var STR_NEEDLE
Var STR_CONTAINS_VAR_1
Var STR_CONTAINS_VAR_2
Var STR_CONTAINS_VAR_3
Var STR_CONTAINS_VAR_4
Var STR_RETURN_VAR
 
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
 
!macro _StrContainsConstructor OUT NEEDLE HAYSTACK
  Push `${HAYSTACK}`
  Push `${NEEDLE}`
  Call StrContains
  Pop `${OUT}`
!macroend
 
!define StrContains '!insertmacro "_StrContainsConstructor"'

;--------------------------------


;General
	
!define PRODUCT_NAME "eSim"
!define PRODUCT_VERSION "2.4"
!define VERSION "2.4.0.0"
!define PRODUCT_PUBLISHER "FOSSEE, IIT Bombay"
!define PRODUCT_WEB_SITE "https://esim.fossee.in/"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

VIAddVersionKey  "ProductName" "eSim"
VIProductVersion "${VERSION}"
VIFileVersion "${VERSION}"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey  "CompanyName" "FOSSEE, IIT Bombay"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2007 Free Software Foundation,  Inc."
VIAddVersionKey "FileDescription" "Installer for eSim EDA Suite"
 


;Default installation folder
  InstallDir "C:\FOSSEE"

;Request application privileges for Admin Rights
  RequestExecutionLevel admin

;Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\eSim" ""

!include LogicLib.nsh

Function .onInit
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
    MessageBox mb_iconstop "Administrator rights required!"
    SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
    Quit
${EndIf}
FunctionEnd
  
;--------------------------------
;Variables
  Var StartMenuFolder
 
;--------------------------------
;Interface Settings
  !define MUI_ABORTWARNING
;--------------------------------

;Pages

  !insertmacro MUI_PAGE_LICENSE "LICENSE.rtf"
  !insertmacro MUI_PAGE_DIRECTORY
  
  ;Start Menu Folder Page Configuration

  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\eSim" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
 
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "eSim-2.4_installer.exe"


Function .onVerifyInstDir
  ${StrContains} $0 "Program Files" $INSTDIR
  StrCmp $0 "" notfound
  MessageBox MB_ICONSTOP|MB_OK \
        "Installation in 'Program Files' is not allowed, please choose another directory."
  Abort
  notfound:
    ${StrContains} $0 " " $INSTDIR
    StrCmp $0 "" PathGood
    MessageBox MB_ICONSTOP|MB_OK \
        "Installation path containing spaces is not allowed, please choose another directory."
    Abort
  PathGood:
FunctionEnd


;Installer Sections

Section -NgspiceSim

  ;Current section needs an additional "size_kb" kilobytes of disk space
  ;AddSize 2726298
  AddSize 1593968

  SetOutPath "$EXEDIR"

  File "eSim.7z"
  File "logo.ico"
  File "sky130_fd_pr.7z"

  SetOutPath "$INSTDIR"

  ;ADD YOUR OWN FILES HERE...
  Nsis7z::ExtractWithDetails "$EXEDIR\eSim.7z" "Extracting eSim %s..."


  ;Copying Folder to install directory
  SetOutPath "$INSTDIR\eSim"
  ;File /nonfatal /a /r "eSim\"

  ;Store installation folder
  WriteRegStr HKLM "Software\eSim" "" $INSTDIR

  ;Create eSim config directory
  CreateDirectory $INSTDIR\eSim\library\config\.esim
  CopyFiles "$EXEDIR\logo.ico" "$INSTDIR\eSim\library\config\.esim"
  FileOpen $0  "$INSTDIR\eSim\library\config\.esim\config.ini" w
  FileWrite $0 `[eSim]$\n`
  FileWrite $0 `eSim_HOME = $INSTDIR\eSim$\n`
  FileWrite $0 `LICENSE = %(eSim_HOME)s\LICENSE.rtf$\n`
  FileWrite $0 `KicadLib = %(eSim_HOME)s\library\kicadLibrary.zip$\n`
  FileWrite $0 `IMAGES = %(eSim_HOME)s\images$\n`
  FileWrite $0 `VERSION = %(eSim_HOME)s\VERSION$\n`
  FileWrite $0 `MODELICA_MAP_JSON = %(eSim_HOME)s\library\ngspicetoModelica\Mapping.json$\n`
  FileClose $0

  ;Create eSim startup batch file
  ;FileOpen $0  "$INSTDIR\eSim\eSim.bat" w
  ;FileWrite $0 `@echo off$\n`
  ;FileWrite $0 `set HOME=$PROFILE$\n`
  ;FileWrite $0 `start eSim.exe$\n`
  ;FileWrite $0 `cd /d %HOME%$\n`
  ;FileClose $0

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application

  ;Create shortcuts
  ;create desktop shortcut
  CreateShortCut "$PROFILE\..\Public\Desktop\eSim.lnk" "$INSTDIR\eSim\eSim.exe" "" "$INSTDIR\eSim\library\config\.esim\logo.ico" "" SW_SHOWMINIMIZED

  SetOutPath "$INSTDIR\eSim\library"

  Nsis7z::ExtractWithDetails "$EXEDIR\sky130_fd_pr.7z" "Extracting SkyWater SKY130 PDK %s..."

  SetOutPath "$INSTDIR"

  !insertmacro MUI_STARTMENU_WRITE_END
  
  ;Remove not required files
  Delete "$EXEDIR\eSim.7z"
  Delete "$EXEDIR\logo.ico"
  Delete "$EXEDIR\sky130_fd_pr.7z"
SectionEnd


Section -InstallKiCad

  SetOutPath "$EXEDIR"
  File "kicad-6.0.11-i686.exe"

  SetOutPath "$INSTDIR"
  SetDetailsPrint both
  DetailPrint "Installing: KiCad......"
  SetDetailsPrint listonly
  ExecWait '"$EXEDIR\kicad-6.0.11-i686.exe" /S /D=$INSTDIR\KiCad'
  SetDetailsPrint both
  
  Goto endActiveSync
  endActiveSync:
 
    ;Remove not required files
    Delete "$EXEDIR\kicad-6.0.11-i686.exe"
    Delete "$PROFILE\..\Public\Desktop\KiCad.lnk"

    EnVar::SetHKLM
    EnVar::AddValue "Path" "$INSTDIR\KiCad\bin"
    Pop $0
    DetailPrint "EnVar::AddValue returned=|$0|"

    ZipDLL::extractall "$INSTDIR\eSim\library\kicadLibrary.zip" "$INSTDIR\eSim\library\"

    ;Copy KiCad library made for eSim
    CopyFiles "$INSTDIR\eSim\library\kicadLibrary\eSim-symbols\*" "$INSTDIR\KiCad\share\kicad\symbols\"
 
    ;Remove older KiCad config files (if any).
    RMDir /r "$PROFILE\AppData\Roaming\kicad\6.0\"

    ;Set  settings
    CreateDirectory "$PROFILE\AppData\Roaming\\6.0\"
    CopyFiles "$INSTDIR\eSim\library\kicadLibrary\template\sym-lib-table" "$PROFILE\AppData\Roaming\kicad\6.0\"

    ;Remove extracted KiCad Library - not needed anymore
    RMDir /r "$INSTDIR\eSim\library\kicadLibrary" 

SectionEnd


Section -AdditionalIcons
 
  SetOutPath "$INSTDIR"
  CreateDirectory "$SMPROGRAMS\eSim"
  CreateShortCut "$SMPROGRAMS\eSim\Uninstall.lnk" "$INSTDIR\eSim\uninst-eSim.exe"

SectionEnd


!include "nghdl-setup-script.nsi" 


Section -InstallMakerchip

  SetOutPath "$EXEDIR"
  File "makerchip.7z"
  
  SetOutPath $INSTDIR
  Nsis7z::ExtractWithDetails "$EXEDIR\makerchip.7z" "Extracting Makerchip %s..."
  CopyFiles "$INSTDIR\makerchip\*" "$INSTDIR\MSYS\mingw64\bin"

  RMDir /r "$INSTDIR\makerchip"
  Delete "$EXEDIR\makerchip.7z"

SectionEnd


Section -Post

  WriteUninstaller "$INSTDIR\eSim\uninst-eSim.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\eSim\uninst-eSim.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"

SectionEnd


;Function un.onUninstSuccess
;  HideWindow
;  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
;FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd


Section Uninstall

    ; Set to HKLM
	EnVar::SetHKLM
	
	GetFullPathName $1 $INSTDIR\..\eSim\nghdl\src
	EnVar::DeleteValue "Path" $1
    Pop $0
    DetailPrint "EnVar::AddValue returned=|$0|"
	
    GetFullPathName $1 $INSTDIR\..\MSYS\mingw64\bin
    EnVar::DeleteValue "Path" $1
    Pop $0
    DetailPrint "EnVar::AddValue returned=|$0|"

	GetFullPathName $1 $INSTDIR\..\MSYS\usr\bin
	EnVar::DeleteValue "Path" $1
    Pop $0
    DetailPrint "EnVar::AddValue returned=|$0|"
	
	;GetFullPathName $1 $INSTDIR\..\mingw64\GHDL\bin
	;EnVar::DeleteValue "Path" $1
    ;Pop $0
    ;DetailPrint "EnVar::AddValue returned=|$0|"
	
	GetFullPathName $1 $INSTDIR\..\nghdl-simulator\bin
	EnVar::DeleteValue "Path" $1
    Pop $0
    DetailPrint "EnVar::AddValue returned=|$0|"
	
	RMDir /r "$INSTDIR\..\MSYS"
	RMDir /r "$INSTDIR\..\nghdl-simulator"
	RMDir /r "$INSTDIR\..\eSim\nghdl"

  ;Note that in uninstaller code, $INSTDIR contains the directory where the uninstaller lies

    Delete "$INSTDIR\uninst-eSim.exe"
    Delete "$SMPROGRAMS\eSim\Uninstall.lnk"
 
    ;Removing Env Variable for KiCad
    GetFullPathName $1 $INSTDIR\..\KiCad\bin
    EnVar::DeleteValue "Path" $1
    Pop $0
    DetailPrint "EnVar::AddValue returned=|$0|"

    ;Remove KiCad config
    RMDir /r "$PROFILE\AppData\Roaming\kicad\6.0"

    ;Removing KiCad
    ExecWait '"$INSTDIR\..\KiCad\uninstaller.exe" /S'

    Goto endActiveSync
  
  endActiveSync:

    ;Removing eSim
    RMDir /r "$INSTDIR\eSim\library\config\.esim"
    RMDir /r "$INSTDIR\eSim\library\config\.nghdl"
    RMDir /r "$INSTDIR\eSim\library\config"
    RMDir "$SMPROGRAMS\eSim"
    RMDir /r "$INSTDIR\..\eSim"
	  RMDir /r "$INSTDIR\..\KiCad"
    Delete "$PROFILE\..\Public\Desktop\eSim.lnk"

    DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
    ;SetAutoClose true

SectionEnd


;Descriptions--------------------

  ;Language strings
  ;LangString DESC_NgspiceSim ${LANG_ENGLISH} "Ngspice is a mixed-level/mixed-signal circuit simulator. Its code is based on three open source software packages: Spice3f5, Cider1b1 and XSPICE. Ngspice is part of gEDA project, a full GPL'd suite of Electronic Design Automation tools."

  ;Assign language strings to sections
  ;!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  ;!insertmacro MUI_DESCRIPTION_TEXT ${NgspiceSim} $(DESC_NgspiceSim)
  ;!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
