#.\rebuild.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "                REBUILD APK "             -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Cleaning build cache..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter clean failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Done!" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter pub get failed!" -ForegroundColor Red
    exit 1
}
Write-Host "Done!" -ForegroundColor Green
Write-Host ""

Write-Host "[3/3] Building release APK..." -ForegroundColor Yellow
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter build failed!" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  BUILD THANH CONG!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "APK location:" -ForegroundColor Cyan
Write-Host "build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
Write-Host ""

Write-Host "Current BASE_URL in .env:" -ForegroundColor Cyan
Get-Content .env | Where-Object { $_ -match "^BASE_URL=" }
Write-Host ""

