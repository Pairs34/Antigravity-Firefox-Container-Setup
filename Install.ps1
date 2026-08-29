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
if (-not (Test-Path $mainJsPath)) {
    Write-Host "main.js dosyasi bulunamadi: $mainJsPath" -ForegroundColor Red
    exit 1
}

$targetDir = Join-Path $env:USERPROFILE ".antigravity-ide\scripts"
if (-not (Test-Path $targetDir)) {
    [void](New-Item -ItemType Directory -Force -Path $targetDir)
}

$destScript = Join-Path $targetDir "firefox_container.ps1"
$sourceScript = Join-Path $PSScriptRoot "firefox_container.ps1"

if (Test-Path $sourceScript) {
    Copy-Item -Path $sourceScript -Destination $destScript -Force
    Write-Host "Konteyner secici scripti kopyalandi: $destScript" -ForegroundColor Cyan
} else {
    Write-Host "Kaynak script bulunamadi: $sourceScript" -ForegroundColor Red
    exit 1
}

$backupPath = "$mainJsPath.bak"
if (-not (Test-Path $backupPath)) {
    Copy-Item -Path $mainJsPath -Destination $backupPath -Force
    Write-Host "Orijinal dosya yedeklendi: $backupPath" -ForegroundColor Cyan
}

$content = [System.IO.File]::ReadAllText($mainJsPath)
$escapedScriptPath = $destScript.Replace("\", "\\")

$replacement = "process.env.ANTIGRAVITY_LOGIN_URL=r;const cp=await import(`"child_process`");const ch=cp.spawn(`"cmd.exe`",[`"/c`",`"start`",`"`",`"powershell.exe`",`"-NoProfile`",`"-ExecutionPolicy`",`"Bypass`",`"-File`",`"$escapedScriptPath`"],{detached:true});ch.unref()"
$fullReplacement = "await (async()=>{try{$replacement}catch{await wbl.openExternal(r)}})()"

if ($content.Contains("ANTIGRAVITY_LOGIN_URL")) {
    $pattern = 'await \(async\(\)=>\{try\{process\.env\.ANTIGRAVITY_LOGIN_URL=r;.*?\}catch\{await wbl\.openExternal\(r\)\}\}\)\(\)'
    $newContent = [regex]::Replace($content, $pattern, $fullReplacement)
    [System.IO.File]::WriteAllText($mainJsPath, $newContent)
    Write-Host "Antigravity IDE zaten yamaliydi, guncellendi!" -ForegroundColor Green
} elseif ($content.Contains("await wbl.openExternal(r)")) {
    $newContent = $content.Replace("await wbl.openExternal(r)", $fullReplacement)
    [System.IO.File]::WriteAllText($mainJsPath, $newContent)
    Write-Host "Antigravity IDE basariyla yamalandi!" -ForegroundColor Green
} else {
    Write-Host "Hedef login metodu main.js icerisinde bulunamadi." -ForegroundColor Yellow
}

Write-Host "`nKurulum tamamlandi. IDE'yi baslatip 'Continue with Google' butonuna basabilirsiniz." -ForegroundColor Green
