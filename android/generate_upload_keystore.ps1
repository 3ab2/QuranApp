# Generates upload-keystore.jks in the android/ folder for Play App Signing upload key.
# Usage (PowerShell, from repo root):
#   .\android\generate_upload_keystore.ps1
# Then copy android\key.properties.template to android\key.properties and fill passwords to match.

$ErrorActionPreference = "Stop"
$androidDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $androidDir

$keystore = Join-Path $androidDir "upload-keystore.jks"
if (Test-Path $keystore) {
    Write-Host "Refusing to overwrite existing: $keystore" -ForegroundColor Yellow
    exit 1
}

$storePass = Read-Host "Keystore password (storePassword)"
$keyPass = Read-Host "Key password (keyPassword, often same as store)"
$dname = Read-Host "Distinguished name (optional, press Enter for default)"
if ([string]::IsNullOrWhiteSpace($dname)) {
    $dname = "CN=Quran Noor, OU=Mobile, O=Quran Noor, L=Unknown, ST=Unknown, C=XX"
}

& keytool -genkeypair -v `
    -keystore $keystore `
    -storetype PKCS12 `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias upload `
    -storepass $storePass `
    -keypass $keyPass `
    -dname $dname

Write-Host ""
Write-Host "Next: copy key.properties.template -> key.properties and set storeFile=upload-keystore.jks" -ForegroundColor Green
Write-Host "Backup this .jks file and passwords OFFLINE (password manager + encrypted backup)." -ForegroundColor Cyan
