param(
    [string]$TargetUrl
)

if ([string]::IsNullOrEmpty($TargetUrl)) {
    $TargetUrl = $env:ANTIGRAVITY_LOGIN_URL
}

if ([string]::IsNullOrEmpty($TargetUrl)) {
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$containers = [System.Collections.Generic.List[string]]::new()
$containers.Add("[Varsayilan Sekme]")

try {
    $profilesDir = Join-Path $env:APPDATA "Mozilla\Firefox\Profiles"
    if (Test-Path $profilesDir) {
        $jsonFiles = Get-ChildItem -Path $profilesDir -Filter "containers.json" -Recurse -ErrorAction SilentlyContinue
        if ($jsonFiles) {
            $rawJson = [System.IO.File]::ReadAllText($jsonFiles[0].FullName)
            $pattern = '\{[^{}]*?"name":"(?<name>[^"]+)"[^{}]*?"public":true[^{}]*?\}|\{[^{}]*?"public":true[^{}]*?"name":"(?<name>[^"]+)"[^{}]*?\}'
            $matches = [regex]::Matches($rawJson, $pattern)
            $found = [System.Collections.Generic.List[string]]::new()
            foreach ($m in $matches) {
                $cName = $m.Groups['name'].Value
                if (-not $found.Contains($cName)) {
                    $found.Add($cName)
                }
            }
            $sorted = $found | Sort-Object {
                if ($_ -match '(\d+)') { [int]$matches[1] } else { 999999 }
            }, { $_ }
            foreach ($item in $sorted) {
                $containers.Add($item)
            }
        }
    }
} catch {
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Antigravity - Firefox Container Secin"
$form.Width = 380
$form.Height = 480
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true

$lbl = New-Object System.Windows.Forms.Label
$lbl.Text = "Konteyner Secin (Aramak icin yazin):"
$lbl.Location = New-Object System.Drawing.Point(15, 12)
$lbl.Size = New-Object System.Drawing.Size(335, 20)
$lbl.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Location = New-Object System.Drawing.Point(15, 36)
$txtSearch.Size = New-Object System.Drawing.Size(335, 25)
$txtSearch.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$lst = New-Object System.Windows.Forms.ListBox
$lst.Location = New-Object System.Drawing.Point(15, 70)
$lst.Size = New-Object System.Drawing.Size(335, 315)
$lst.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$lst.ItemHeight = 22

$btnOpen = New-Object System.Windows.Forms.Button
$btnOpen.Text = "Ac"
$btnOpen.Location = New-Object System.Drawing.Point(175, 395)
$btnOpen.Size = New-Object System.Drawing.Size(85, 32)
$btnOpen.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = "Iptal"
$btnCancel.Location = New-Object System.Drawing.Point(265, 395)
$btnCancel.Size = New-Object System.Drawing.Size(85, 32)
$btnCancel.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
$btnCancel.Add_Click({ $form.Close() })

$filterAction = {
    $q = $txtSearch.Text.Trim()
    $lst.BeginUpdate()
    $lst.Items.Clear()
    foreach ($c in $containers) {
        if ([string]::IsNullOrEmpty($q) -or $c.IndexOf($q, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            [void]$lst.Items.Add($c)
        }
    }
    if ($lst.Items.Count -gt 0) {
        $lst.SelectedIndex = 0
    }
    $lst.EndUpdate()
}

$txtSearch.Add_TextChanged($filterAction)

$txtSearch.Add_KeyDown({
    param($s, $e)
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Down) {
        if ($lst.SelectedIndex -lt ($lst.Items.Count - 1)) {
            $lst.SelectedIndex++
        }
        $e.Handled = $true
    } elseif ($e.KeyCode -eq [System.Windows.Forms.Keys]::Up) {
        if ($lst.SelectedIndex -gt 0) {
            $lst.SelectedIndex--
        }
        $e.Handled = $true
    }
})

$openAction = {
    if ($null -eq $lst.SelectedItem) { return }
    $chosen = $lst.SelectedItem.ToString()
    $firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
    if (-not (Test-Path $firefoxPath)) {
        $firefoxPath = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
    }
    if (-not (Test-Path $firefoxPath)) {
        $firefoxPath = "firefox.exe"
    }

    if ($chosen -eq "[Varsayilan Sekme]") {
        Start-Process $firefoxPath -ArgumentList "`"$TargetUrl`""
    } else {
        $encodedUrl = [System.Uri]::EscapeDataString($TargetUrl)
        $param = "ext+container:name=$chosen&url=$encodedUrl"
        Start-Process $firefoxPath -ArgumentList "`"$param`""
    }
    $form.Close()
}

$btnOpen.Add_Click($openAction)
$lst.Add_DoubleClick($openAction)
$lst.Add_KeyDown({
    param($s, $e)
    if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        & $openAction
        $e.Handled = $true
    }
})

$form.Controls.Add($lbl)
$form.Controls.Add($txtSearch)
$form.Controls.Add($lst)
$form.Controls.Add($btnOpen)
$form.Controls.Add($btnCancel)

$form.AcceptButton = $btnOpen
$form.CancelButton = $btnCancel

& $filterAction
if ($lst.Items.Count -gt 1) {
    $lst.SelectedIndex = 1
}

$form.Add_Shown({
    $form.Activate()
    $txtSearch.Focus()
})

[void]$form.ShowDialog()
