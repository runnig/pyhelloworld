; NSIS script for pyhelloworld Windows installer
; Basic installer without Modern UI to avoid icon issues
; Set TEST_MODE=1 when compiling for test mode (user-level, no UAC)
; Example: makensis /DTEST_MODE=1 pyhelloworld.nsi

; Define application metadata
!define APP_NAME "HelloWorld"
!define APP_VERSION "0.1.0"
!define APP_PUBLISHER "pyhelloworld"
!define APP_URL "https://github.com/runnig/pyhelloworld"
!define APP_EXECUTABLE "pyhelloworld.exe"

; Registry hive - compile-time decision based on TEST_MODE
!ifdef TEST_MODE
    !define REGISTRY_HIVE "HKCU"
    RequestExecutionLevel user
!else
    !define REGISTRY_HIVE "HKLM"
    RequestExecutionLevel admin
!endif

; Default installation directory
InstallDir "$PROGRAMFILES\${APP_NAME}"

; Registry key to store installation directory
InstallDirRegKey ${REGISTRY_HIVE} "Software\${APP_NAME}" "InstallPath"

; Pages
Page license
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

; License file
LicenseData "..\LICENSE"

; Output file
!ifdef TEST_MODE
    OutFile "..\dist\pyhelloworld-test-installer.exe"
!else
    OutFile "..\dist\pyhelloworld-installer.exe"
!endif

; Language

; Installer Sections
Section "Main Application" SecMain
    SectionIn RO

    SetOutPath "$INSTDIR"

    ; Copy the single PyInstaller executable
    File "..\dist\pyhelloworld.exe"

    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Add installation information to registry
    WriteRegStr ${REGISTRY_HIVE} "Software\${APP_NAME}" "InstallPath" "$INSTDIR"
    WriteRegStr ${REGISTRY_HIVE} "Software\${APP_NAME}" "Version" "${APP_VERSION}"

    ; Add uninstaller to Add/Remove Programs
    WriteRegStr ${REGISTRY_HIVE} "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr ${REGISTRY_HIVE} "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr ${REGISTRY_HIVE} "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${APP_VERSION}"
    WriteRegStr ${REGISTRY_HIVE} "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${APP_PUBLISHER}"
    WriteRegStr ${REGISTRY_HIVE} "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "URLInfoAbout" "${APP_URL}"

SectionEnd

Section "Start Menu Shortcuts" SecShortcuts
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXECUTABLE}" "" "$INSTDIR\${APP_EXECUTABLE}" 0
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
SectionEnd

Section "Desktop Shortcut" SecDesktop
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXECUTABLE}" "" "$INSTDIR\${APP_EXECUTABLE}" 0
SectionEnd

; Uninstaller Section
Section "Uninstall"
    ; Remove files and directories
    RMDir /r "$INSTDIR\*.*"
    RMDir "$INSTDIR"

    ; Remove shortcuts
    Delete "$SMPROGRAMS\${APP_NAME}\*.*"
    RMDir "$SMPROGRAMS\${APP_NAME}"
    Delete "$DESKTOP\${APP_NAME}.lnk"

    ; Remove registry entries
    DeleteRegKey ${REGISTRY_HIVE} "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey ${REGISTRY_HIVE} "Software\${APP_NAME}"

SectionEnd
