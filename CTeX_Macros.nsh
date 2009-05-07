!include "WordFunc.nsh"
!include "EnvVarUpdate.nsh"
!include "FileAssoc.nsh"
!include "UninstByLog.nsh"

!macro _CreateURLShortCut URLFile URLSite
	WriteINIStr "${URLFile}.URL" "InternetShortcut" "URL" "${URLSite}"
!macroend
!define CreateURLShortCut "!insertmacro _CreateURLShortCut"

!macro _AddPath DIR
	StrCpy $R0 0
	ClearErrors
	${EnvVarUpdate} $R1 "PATH" "P" "HKLM" "${DIR}"
	IfErrors 0 +2
		StrCpy $R0 1
	${If} $R0 == 1
		${EnvVarUpdate} $R1 "PATH" "P" "HKCU" "${DIR}"
	${EndIf}
!macroend
!define AddPath "!insertmacro _AddPath"

!macro _AddEnvVar NAME VALUE
	StrCpy $R0 0
	ClearErrors
	WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "${NAME}" "${VALUE}"
	IfErrors 0 +2
		StrCpy $R0 1
	${If} $R0 == 1
		WriteRegExpandStr HKCU "Environment" "${NAME}" "${VALUE}"
	${EndIf}
!macroend
!define AddEnvVar "!insertmacro _AddEnvVar"

!macro _RemovePath DIR
	${EnvVarUpdate} $R1 "PATH" "R" "HKLM" "${DIR}"
	${EnvVarUpdate} $R1 "PATH" "R" "HKCU" "${DIR}"
!macroend
!define RemovePath "!insertmacro _RemovePath"

!macro _unRemovePath DIR
	${un.EnvVarUpdate} $R1 "PATH" "R" "HKLM" "${DIR}"
	${un.EnvVarUpdate} $R1 "PATH" "R" "HKCU" "${DIR}"
!macroend
!define un.RemovePath "!insertmacro _unRemovePath"

!macro _RemoveEnvVar NAME
	DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "${NAME}"
	DeleteRegValue HKCU "Environment" "${NAME}"
!macroend
!define RemoveEnvVar "!insertmacro _RemoveEnvVar"

!macro _unRemoveEnvVar NAME
	DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "${NAME}"
	DeleteRegValue HKCU "Environment" "${NAME}"
!macroend
!define un.RemoveEnvVar "!insertmacro _unRemoveEnvVar"

Function RemoveToken
	StrCpy $R9 ""
	StrCpy $R8 0
	${Do}
		${StrTok} $R7 $R0 $R2 $R8 "1"
		${If} $R7 == ""
			${ExitDo}
		${EndIf}
		${Do}
			StrCpy $R6 $R7 1
			${If} $R6 != " "
				${ExitDo}
			${EndIf}
			StrCpy $R7 $R7 "" 1                ;  Remove leading space
		${Loop}
		${Do}
			StrCpy $R6 $R7 1 -1
			${If} $R6 != " "
				${ExitDo}
			${EndIf}
			StrCpy $R7 $R7 -1                  ;  Remove trailing space
     ${Loop}
		${If} $R7 != $R1                     ;  Remove existing target
		${AndIf} $R7 != ""
			${If} $R9 != ""
				StrCpy $R9 "$R9;$R7"
			${Else}
				StrCpy $R9 "$R7"
			${EndIf}
		${EndIf}
		IntOp $R8 $R8 + 1
	${Loop}
FunctionEnd

!macro Install_Config_MiKTeX
	StrCpy $0 "$INSTDIR\${MiKTeX_Dir}"

	WriteRegStr HKLM "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\Core" "Install" "$0"
	WriteRegStr HKLM "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\Core" "SharedSetup" "1"
	WriteRegStr HKCU "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\MPM" "AutoInstall" "2"
	WriteRegStr HKCU "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\MPM" "RemoteRepository" "ftp://ftp.ctex.org/CTAN/systems/win32/miktex/tm/packages/"
	WriteRegStr HKCU "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\MPM" "RepositoryType" "remote"

	${AddPath} "$0\miktex\bin"

	StrCpy $1 "$0\miktex\bin\yap.exe"
	!insertmacro APP_ASSOCIATE "dvi" "MiKTeX.Yap.dvi.${MiKTeX_Version}" "DVI $(Desc_File)" "$1,1" "Open with Yap" '$1 "%1"'

	CreateDirectory "$SMPROGRAMS\CTeX\MiKTeX"
	CreateShortCut "$SMPROGRAMS\CTeX\MiKTeX\Browse Packages.lnk" "$0\miktex\bin\mpm_mfc.exe"
	CreateShortCut "$SMPROGRAMS\CTeX\MiKTeX\Previewer.lnk" "$0\miktex\bin\yap.exe"
	CreateShortCut "$SMPROGRAMS\CTeX\MiKTeX\Settings.lnk" "$0\miktex\bin\mo.exe"
	CreateShortCut "$SMPROGRAMS\CTeX\MiKTeX\Update.lnk" "$0\miktex\bin\copystart_admin.exe" '"$0\miktex\config\update.dat"'
	CreateDirectory "$SMPROGRAMS\CTeX\MiKTeX\Help"
	CreateShortCut "$SMPROGRAMS\CTeX\MiKTeX\Help\FAQ.lnk" "$0\doc\miktex\faq.chm"
	CreateShortCut "$SMPROGRAMS\CTeX\MiKTeX\Help\Manual.lnk" "$0\doc\miktex\miktex.chm"
	CreateDirectory "$SMPROGRAMS\CTeX\MiKTeX\MiKTeX on the Web"

	${CreateURLShortCut} "$SMPROGRAMS\CTeX\MiKTeX\MiKTeX on the Web\Give back" "http://miktex.org/giveback"
	${CreateURLShortCut} "$SMPROGRAMS\CTeX\MiKTeX\MiKTeX on the Web\Known Issues" "http://miktex.org/2.7/issues"
	${CreateURLShortCut} "$SMPROGRAMS\CTeX\MiKTeX\MiKTeX on the Web\MiKTeX Project Page" "http://miktex.org/"
	${CreateURLShortCut} "$SMPROGRAMS\CTeX\MiKTeX\MiKTeX on the Web\Support" "http://miktex.org/support"
!macroend

!macro Reset_Config_MiKTeX
	${If} $OLD_INSTDIR != ""
		${RemovePath} "$OLD_INSTDIR\${MiKTeX_Dir}\miktex\bin"
	${EndIf}
!macroend

!macro Uninstall_Config_MiKTeX
	DeleteRegKey HKLM "Software\MiKTeX.org"
	DeleteRegKey HKCU "Software\MiKTeX.org"

	${un.RemovePath} "$INSTDIR\${MiKTeX_Dir}\miktex\bin"

	!insertmacro APP_UNASSOCIATE "dvi" "MiKTeX.Yap.dvi.${MiKTeX_Version}"
!macroend

!macro Install_Config_Addons
	StrCpy $0 "$INSTDIR\${Addons_Dir}"

	ReadRegStr $R0 HKLM "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\Core" "Roots"
	${If} $R0 == ""
		ReadRegStr $R1 HKLM "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\Core" "Install"
		WriteRegStr HKLM "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\Core" "Roots" "$0;$R1"
	${Else}
		StrCpy $R1 "$0"
		StrCpy $R2 ";"
		Call RemoveToken
		WriteRegStr HKLM "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\Core" "Roots" "$0;$R9"
	${EndIf}

; Install CCT
	${AddPath} "$0\cct\bin"
	${AddEnvVar} "CCHZPATH" "$0\cct\fonts"
	${AddEnvVar} "CCPKPATH" "$0\fonts\pk\modeless\cct\dpi$$d"
	
	FileOpen $R0 "$0\cct\bin\cctinit.ini" "w"
	FileWrite $R0 "-T$0\fonts\tfm\cct$\n"
	FileWrite $R0 "-H$0\tex\latex\cct$\n"
	FileClose $R0
	
	ExecWait "$0\cct\bin\cctinit.exe"

; Install TY
	${AddPath} "$0\ty\bin"

	FileOpen $R0 "$0\ty\bin\ty.cfg" "w"
	FileWrite $R0 "$0\fonts\tfm\ty\$\r$\n"
	FileWrite $R0 "$0\fonts\pk\modeless\ty\DPI@Rr\$\r$\n"
	FileWrite $R0 ".\$\r$\n"
	FileWrite $R0 "$0\ty\bin\$\r$\n"
	FileWrite $R0 "$FONTS\$\r$\n"
	FileWrite $R0 "600$\r$\n1095$\r$\n"
	FileWrite $R0 "simsun.ttc$\r$\nsimkai.ttf$\r$\nsimfang.ttf$\r$\nsimhei.ttf$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\n"
	FileWrite $R0 "simsun.ttc$\r$\nsimyou.ttf$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimli.ttf$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\n"
	FileWrite $R0 "0$\r$\n0$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n0$\r$\n0$\r$\n0$\r$\n0$\r$\n0$\r$\n"
	FileClose $R0

; Install Fonts
	StrCpy $1 "$0\fonts\truetype\chinese\simsun.ttf"
	IfFileExists $1 0 +2
		StrCpy $1 ""
	${If} $1 != ""
		ExecWait '$0\ctex\bin\BREAKTTC.exe "$FONTS\simsun.ttc"'
		CreateDirectory "$0\fonts\truetype\chinese"
		Rename "FONT00.TTF" "$0\fonts\truetype\chinese\simsun.ttf"
		Delete "*.TTF"
	${EndIf}
!macroend

!macro Reset_Config_Addons
	${If} $OLD_INSTDIR != ""
		StrCpy $0 "$OLD_INSTDIR\${Addons_Dir}"
		
		ReadRegStr $R0 HKLM "Software\MiKTeX.org\MiKTeX\$OLD_MiKTeX_Version\Core" "Roots"
		${If} $R0 != ""
			StrCpy $R1 "$0"
			StrCpy $R2 ";"
			Call RemoveToken
			WriteRegStr HKLM "Software\MiKTeX.org\MiKTeX\$OLD_MiKTeX_Version\Core" "Roots" "$R9"
		${EndIf}
	
; Uninstall CCT
		${RemovePath} "$0\cct\bin"
		${RemoveEnvVar} "CCHZPATH"
		${RemoveEnvVar} "CCPKPATH"

; Uninstall TY
		${RemovePath} "$0\ty\bin"
	${EndIf}
!macroend

!macro Uninstall_Config_Addons
	StrCpy $0 "$INSTDIR\${Addons_Dir}"

; Uninstall CCT
	${un.RemovePath} "$0\cct\bin"
	${un.RemoveEnvVar} "CCHZPATH"
	${un.RemoveEnvVar} "CCPKPATH"

; Uninstall TY
	${un.RemovePath} "$0\ty\bin"
!macroend

!macro Install_Config_Ghostscript
	StrCpy $0 "$INSTDIR\${Ghostscript_Dir}"
	StrCpy $1 "$0\gs${Ghostscript_Version}"
	WriteRegStr HKLM "Software\GPL Ghostscript\${Ghostscript_Version}" "GS_DLL" "$1\bin\gsdll32.dll"
	WriteRegStr HKLM "Software\GPL Ghostscript\${Ghostscript_Version}" "GS_LIB" "$1\lib;$0\fonts;$FONTS"

	${AddPath} "$1\bin"

	CreateDirectory "$SMPROGRAMS\CTeX\Ghostcript"
	CreateShortCut "$SMPROGRAMS\CTeX\Ghostcript\Ghostscript.lnk" "$1\bin\gswin32.exe" '"-I$1\lib;$0\fonts;$FONTS"'
	CreateShortCut "$SMPROGRAMS\CTeX\Ghostcript\Ghostscript Readme.lnk" "$1\doc\Readme.htm"
!macroend

!macro Reset_Config_Ghostscript
	${If} $OLD_INSTDIR != ""
		${RemovePath} "$OLD_INSTDIR\${Ghostscript_Dir}\gs$OLD_Ghostscript_Version\bin"
	${EndIf}
!macroend

!macro Uninstall_Config_Ghostscript
	DeleteRegKey HKLM "Software\GPL Ghostscript"

	${un.RemovePath} "$INSTDIR\${Ghostscript_Dir}\gs${Ghostscript_Version}\bin"
!macroend

!macro Install_Config_GSview
	StrCpy $0 "$INSTDIR\${GSview_Dir}"
	WriteRegStr HKLM "Software\Ghostgum\GSview" "${GSview_Version}" "$0"

	StrCpy $R0 "$0\gsview\gsview32.ini"
	WriteINIStr $R0 "GSview-${GSview_Version}"	"Version" "${GSview_Version}"
	WriteINIStr $R0 "GSview-${GSview_Version}"	"GSversion" "864"
	ReadRegStr $R1 HKLM "Software\GPL Ghostscript\${Ghostscript_Version}" "GS_DLL"
	WriteINIStr $R0 "GSview-${GSview_Version}"	"GhostscriptDLL" "$R1"
	ReadRegStr $R1 HKLM "Software\GPL Ghostscript\${Ghostscript_Version}" "GS_LIB"
	WriteINIStr $R0 "GSview-${GSview_Version}"	"GhostscriptInclude" "$R1"
	WriteINIStr $R0 "GSview-${GSview_Version}"	"GhostscriptOther" '-dNOPLATFONTS -sFONTPATH="c:\psfonts"'
	WriteINIStr $R0 "GSview-${GSview_Version}"	"Configured" "1"
	Delete "$PROFILE\gsview32.ini"

	${AddPath} "$0\gsview"

	StrCpy $1 "$0\gsview\gsview32.exe"
	!insertmacro APP_ASSOCIATE "ps" "CTeX.PS" "PS $(Desc_File)" "$1,3" "Open with GSview" '$1 "%1"'
	!insertmacro APP_ASSOCIATE "eps" "CTeX.EPS" "EPS $(Desc_File)" "$1,3" "Open with GSview" '$1 "%1"'

	CreateDirectory "$SMPROGRAMS\CTeX\Ghostgum"
	CreateShortCut "$SMPROGRAMS\CTeX\Ghostgum\GSview.lnk" "$0\gsview\gsview32.exe"
	CreateShortCut "$SMPROGRAMS\CTeX\Ghostgum\GSview Readme.lnk" "$0\gsview\Readme.htm"
!macroend

!macro Reset_Config_GSview
	${If} $OLD_INSTDIR != ""
		${RemovePath} "$OLD_INSTDIR\${GSview_Dir}\gsview"
	${EndIf}
!macroend

!macro Uninstall_Config_GSview
	DeleteRegKey HKLM "Software\Ghostgum"

	${un.RemovePath} "$INSTDIR\${GSview_Dir}\gsview"

	!insertmacro APP_UNASSOCIATE "ps" "CTeX.PS"
	!insertmacro APP_UNASSOCIATE "eps" "CTeX.EPS"
!macroend

!macro Install_Config_WinEdt
	StrCpy $0 "$INSTDIR\${WinEdt_Dir}"
	WriteRegStr HKLM "Software\WinEdt" "Install Root" "$0"

	${AddPath} "$0"

	StrCpy $1 "$0\WinEdt.exe"
	!insertmacro APP_ASSOCIATE "tex" "CTeX.TeX" "TeX $(Desc_File)" "$1,0" "Open with WinEdt" '$1 "%1"'

	CreateDirectory "$SMPROGRAMS\CTeX"
	CreateShortCut "$SMPROGRAMS\CTeX\WinEdt.lnk" "$INSTDIR\${WinEdt_Dir}\WinEdt.exe"
!macroend

!macro Reset_Config_WinEdt
	${If} $OLD_INSTDIR != ""
		${RemovePath} "$OLD_INSTDIR\${WinEdt_Dir}"
	${EndIf}
!macroend

!macro Uninstall_Config_WinEdt
	DeleteRegKey HKLM "Software\WinEdt"

	${un.RemovePath} "$INSTDIR\${WinEdt_Dir}"

	!insertmacro APP_UNASSOCIATE "tex" "CTeX.TeX"
!macroend

!macro Associate_WinEdt_MiKTeX
	WriteRegStr HKCU "Software\MiKTeX.org\MiKTeX\${MiKTeX_Version}\Yap\Settings" "Editor" '$INSTDIR\${WinEdt_Dir}\winedt.exe "[Open(|%f|);SelPar(%l,8)]"'
!macroend

!macro Install_Config_CTeX
	WriteRegStr HKLM "Software\${APP_NAME}" "" "${APP_NAME} ${APP_VERSION}"
	WriteRegStr HKLM "Software\${APP_NAME}" "Install" "$INSTDIR"
	WriteRegStr HKLM "Software\${APP_NAME}" "Version" "${APP_BUILD}"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_BUILD}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${APP_COMPANY}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Readme" "$INSTDIR\Readme.txt"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "HelpLink" "http://bbs.ctex.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "URLInfoAbout" "http://www.ctex.org"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
!macroend

!macro Reset_Config_CTeX
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
	DeleteRegKey HKLM "Software\${APP_NAME}"
!macroend

!macro Uninstall_Config_CTeX
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
	DeleteRegKey HKLM "Software\${APP_NAME}"
!macroend

!macro _Install_Files Files Log_File
	CreateDirectory "$INSTDIR\${Logs_Dir}"
	LogSet on
	File /r "${Files}"
	LogSet off
	CopyFiles "$INSTDIR\install.log" "$INSTDIR\${Logs_Dir}\${Log_File}"
	Delete "$INSTDIR\install.log"
!macroend
!define Install_Files "!insertmacro _Install_Files"

!macro _Begin_Install_Files
	CreateDirectory "$INSTDIR\${Logs_Dir}"
	LogSet on
!macroend
!define Begin_Install_Files "!insertmacro _Begin_Install_Files"

!macro _End_Install_Files Log_File
	LogSet off
	CopyFiles "$INSTDIR\install.log" "$INSTDIR\${Logs_Dir}\${Log_File}"
	Delete "$INSTDIR\install.log"
!macroend
!define End_Install_Files "!insertmacro _End_Install_Files"

!macro UninstallAllFiles UN
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_miktex.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_ctex.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_cjk.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_cct.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_ty.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_ghostscript.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_gsview.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_winedt.log"
	${${UN}Uninstall_Files} "$INSTDIR\${Logs_Dir}\install.log"
!macroend