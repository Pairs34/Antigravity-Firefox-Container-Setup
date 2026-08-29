$candidates = @(
    "$env:LOCALAPPDATA\Programs\Antigravity IDE",
    "$env:ProgramFiles\Antigravity IDE",
    "C:\Users\Pairs\AppData\Local\Programs\Antigravity IDE"
)

$ideDir = $null
foreach ($c in $candidates) {
    if (Test-Path $c) {
        $ideDir = $c
        break
    }
}

if (-not $ideDir) {
    Write-Host "Antigravity IDE kurulum dizini bulunamadi!" -ForegroundColor Red
    exit 1
}

$mainJsPath = Join-Path $ideDir "resources\app\out\main.js"
$backupPath = "$mainJsPath.bak"

if (Test-Path $backupPath) {
    Copy-Item -Path $backupPath -Destination $mainJsPath -Force
    Write-Host "Orijinal main.js basariyla geri yuklendi." -ForegroundColor Green
} else {
    Write-Host "Yedek dosya bulunamadi: $backupPath" -ForegroundColor Red
    exit 1
}

Write-Host "Kaldirma islemi tamamlandi. IDE artik varsayilan tarayiciyi acacaktir." -ForegroundColor Green
