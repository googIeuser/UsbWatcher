; USB Watcher installer
; Built with Inno Setup. Values are supplied by scripts/build-installer.ps1.

#ifndef MyAppVersion
  #define MyAppVersion "0.1.0"
#endif
#ifndef MySourceDir
  #define MySourceDir "..\artifacts\USB-Watcher-v0.1.0-win-x64"
#endif

#define MyAppName "USB Watcher"
#define MyAppExeName "usb_watcher.exe"
#define MyAppPublisher "USB Watcher Contributors"

[Setup]
AppId={{D7DF2D4B-8C62-4B05-B8A6-EA98B676DB54}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
VersionInfoVersion={#MyAppVersion}
VersionInfoProductName={#MyAppName}
VersionInfoDescription={#MyAppName} Setup
VersionInfoCompany={#MyAppPublisher}
DefaultDirName={autopf}\USB Watcher
DefaultGroupName=USB Watcher
DisableProgramGroupPage=yes
AllowNoIcons=yes
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=assets\usb_watcher.ico
LicenseFile=..\LICENSE
OutputDir=..\artifacts
OutputBaseFilename=USB_Watcher_Setup_{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=150,150
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
CloseApplications=yes
RestartApplications=no
SetupLogging=yes
ChangesAssociations=no
DisableWelcomePage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\USB Watcher"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\Uninstall USB Watcher"; Filename: "{uninstallexe}"
Name: "{autodesktop}\USB Watcher"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch USB Watcher"; WorkingDir: "{app}"; Flags: nowait postinstall skipifsilent

[Code]
procedure InitializeWizard;
begin
  WizardForm.Caption := 'USB Watcher Setup';
  WizardForm.WelcomeLabel1.Caption := 'Welcome to USB Watcher Setup';
  WizardForm.WelcomeLabel2.Caption :=
    'This wizard will install USB Watcher on your computer.' + #13#10 + #13#10 +
    'USB Watcher inspects connected USB devices and displays the negotiated connection information reported by Windows.' + #13#10 + #13#10 +
    'Close USB Watcher before continuing.';
  WizardForm.FinishedLabel.Caption :=
    'USB Watcher has been installed successfully.' + #13#10 + #13#10 +
    'Click Finish to close Setup.';
end;
