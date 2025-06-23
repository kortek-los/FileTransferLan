[Setup]
AppName=File Transfer LAN
AppVersion=1.1
DefaultDirName={pf}\FileTransferLan
DefaultGroupName=FileTransferLan
UninstallDisplayIcon={app}\icon.ico
OutputDir=.
OutputBaseFilename=FileTransferLanInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "app.py"; DestDir: "{app}"
Source: "launcher.bat"; DestDir: "{app}"
Source: "run_server.bat"; DestDir: "{app}"
Source: "runner.py"; DestDir: "{app}"
Source: "File Transfer Lan.exe"; DestDir: "{app}"
Source: "icon.ico"; DestDir: "{app}"
Source: ".env"; DestDir: "{app}"
Source: "README.md"; DestDir: "{app}"
Source: "templates\*"; DestDir: "{app}\templates"; Flags: recursesubdirs

[Icons]
Name: "{group}\File Transfer Lan"; Filename: "{app}\launcher.bat"
Name: "{group}\Uninstall File Transfer Lan"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\launcher.bat"; Description: "Jalankan File Transfer Lan"; Flags: postinstall shellexec
