@echo off
setlocal enabledelayedexpansion
title Mobile Link - Dashboard Pro

:: Set Absolute Base Directory to prevent path mapping errors
set "BASE_DIR=%~dp0"
if "!BASE_DIR:~-1!"=="\" set "BASE_DIR=!BASE_DIR:~0,-1!"
cd /d "!BASE_DIR!"

:: =========================================
:: 0. INSTANT ANIMATED SPLASH SCREEN (NO WHITE BORDER)
:: =========================================
if "%~1"=="-hidden" goto :RunMain

:: Detect System Theme for Splash Screen
set "SYS_THEME=Dark"
for /f "tokens=3" %%i in ('reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme 2^>nul') do (
    if "%%i"=="0x1" set "SYS_THEME=Light"
)

if "!SYS_THEME!"=="Light" (
    set "SPLASH_BG=#F3F3F3"
    set "SPLASH_FG=#000000"
    set "SPINNER_BG=#DDDDDD"
) else (
    set "SPLASH_BG=#202020"
    set "SPLASH_FG=#FFFFFF"
    set "SPINNER_BG=#333333"
)

set "SPLASH_HTA=%temp%\nazat_splash.hta"
echo ^<html^>^<head^>^<title^>Loading^</title^> > "%SPLASH_HTA%"
:: NO WHITE TITLE BAR GUARANTEED
echo ^<HTA:APPLICATION ID="Splash" CAPTION="no" BORDER="none" INNERBORDER="no" SHOWINTASKBAR="no" SCROLL="no" SYSMENU="no" MINIMIZEBUTTON="no" MAXIMIZEBUTTON="no" /^> >> "%SPLASH_HTA%"
echo ^<script^>window.resizeTo(320, 110); window.moveTo((screen.width-320)/2, (screen.height-110)/2);^</script^> >> "%SPLASH_HTA%"
echo ^<style^> >> "%SPLASH_HTA%"
echo body { background-color: !SPLASH_BG!; color: !SPLASH_FG!; font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; padding: 0; border: 2px solid #10893E; overflow: hidden; } >> "%SPLASH_HTA%"
echo .container { padding: 30px 20px; text-align: center; } >> "%SPLASH_HTA%"
echo .loading-text { font-size: 16px; font-weight: bold; margin-bottom: 12px; } >> "%SPLASH_HTA%"
echo .track { width: 80%%; height: 5px; background: !SPINNER_BG!; margin: 0 auto; position: relative; overflow: hidden; border-radius: 3px; } >> "%SPLASH_HTA%"
echo #thumb { height: 100%%; width: 40%%; background: #10893E; position: absolute; left: 0; } >> "%SPLASH_HTA%"
echo ^</style^>^</head^> >> "%SPLASH_HTA%"
echo ^<body^> >> "%SPLASH_HTA%"
echo     ^<div class="container"^> >> "%SPLASH_HTA%"
echo         ^<div class="loading-text"^>Starting Dashboard...^</div^> >> "%SPLASH_HTA%"
echo         ^<div class="track"^>^<div id="thumb"^>^</div^>^</div^> >> "%SPLASH_HTA%"
echo     ^</div^> >> "%SPLASH_HTA%"
echo     ^<script^> >> "%SPLASH_HTA%"
echo         var pos = 0; var dir = 1; >> "%SPLASH_HTA%"
echo         setInterval(function(){ >> "%SPLASH_HTA%"
echo             pos += 4 * dir; >> "%SPLASH_HTA%"
echo             if(pos ^> 60) dir = -1; >> "%SPLASH_HTA%"
echo             if(pos ^< 0) dir = 1; >> "%SPLASH_HTA%"
echo             document.getElementById('thumb').style.left = pos + '%%'; >> "%SPLASH_HTA%"
echo         }, 20); >> "%SPLASH_HTA%"
echo     ^</script^> >> "%SPLASH_HTA%"
echo ^</body^>^</html^> >> "%SPLASH_HTA%"

start "" mshta "%SPLASH_HTA%"

set "VBS_HIDE=%temp%\nazat_hide.vbs"
echo CreateObject("Wscript.Shell").Run """" ^& WScript.Arguments(0) ^& """ -hidden", 0, False > "%VBS_HIDE%"
wscript "%VBS_HIDE%" "%~f0"
exit

:RunMain
:: =========================================
:: 1. Environment & Fast Init Engine
:: =========================================
set "APP_DATA_DIR=%APPDATA%\MobileLink"
if not exist "%APP_DATA_DIR%" mkdir "%APP_DATA_DIR%"
set "SAVE_FILE=%APP_DATA_DIR%\nazat_save_v53.txt"
set "DEVICES_FILE=%APP_DATA_DIR%\nazat_devices.txt"

:: Default Variables
set "SAVED_IP=" & set "LAST_Q=0" & set "LAST_A=True" & set "SAVED_THEME=Dark" & set "LAST_SRC=0"
set "LAST_OTGK=False" & set "LAST_OTGM=False" & set "LAST_FPS=60" & set "LAST_ROT=0" & set "LAST_FACE=1"
set "LAST_TOP=False" & set "LAST_SCROFF=True" & set "LAST_REC=False" & set "LAST_RECPATH=" & set "LAST_AUDIO=True" & set "LAST_MIC=0" & set "LAST_DESKTOP=False" & set "LAST_BITRATE=0"

if exist "%SAVE_FILE%" (
    for /f "usebackq tokens=1-18 delims=;" %%a in ("%SAVE_FILE%") do (
        if not "%%a"=="" set "SAVED_IP=%%a"
        if not "%%b"=="" set "LAST_Q=%%b"
        if not "%%c"=="" set "LAST_A=%%c"
        if not "%%d"=="" set "SAVED_THEME=%%d"
        if not "%%e"=="" set "LAST_SRC=%%e"
        if not "%%f"=="" set "LAST_OTGK=%%f"
        if not "%%g"=="" set "LAST_OTGM=%%g"
        if not "%%h"=="" set "LAST_FPS=%%h"
        if not "%%i"=="" set "LAST_ROT=%%i"
        if not "%%j"=="" set "LAST_FACE=%%j"
        if not "%%k"=="" set "LAST_TOP=%%k"
        if not "%%l"=="" set "LAST_SCROFF=%%l"
        if not "%%m"=="" set "LAST_REC=%%m"
        if not "%%n"=="" set "LAST_RECPATH=%%n"
        if not "%%o"=="" set "LAST_AUDIO=%%o"
        if not "%%p"=="" set "LAST_MIC=%%p"
        if not "%%q"=="" set "LAST_DESKTOP=%%q"
        if not "%%r"=="" set "LAST_BITRATE=%%r"
    )
)

set "JUST_IP=192.168.1.106" & set "JUST_PORT=5555"
if not "!SAVED_IP!"=="" (
    for /f "tokens=1,2 delims=:" %%i in ("!SAVED_IP!") do ( set "JUST_IP=%%i" & if not "%%j"=="" set "JUST_PORT=%%j" )
)
set "o1=192" & set "o2=168" & set "o3=1" & set "o4=106"
for /f "tokens=1,2,3,4 delims=." %%a in ("!JUST_IP!") do (
    if not "%%a"=="" set "o1=%%a" & if not "%%b"=="" set "o2=%%b" & if not "%%c"=="" set "o3=%%c" & if not "%%d"=="" set "o4=%%d"
)

:: Re-detect System Theme for Main Application
set "SYS_THEME=Dark"
for /f "tokens=3" %%i in ('reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme 2^>nul') do (
    if "%%i"=="0x1" set "SYS_THEME=Light"
)

:: =========================================
:: 2. Pro Dashboard GUI Construction
:: =========================================
cls
set "PS_SCRIPT=%temp%\nazat_gui_v53.ps1"
echo Add-Type -AssemblyName System.Windows.Forms > "%PS_SCRIPT%"
echo Add-Type -AssemblyName System.Drawing >> "%PS_SCRIPT%"

:: Windows API for Native Dark Title Bar
echo try { >> "%PS_SCRIPT%"
echo     $csharp = 'using System; using System.Runtime.InteropServices; public class WinAPI { [DllImport("dwmapi.dll")] public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize); [DllImport("shell32.dll")] public static extern void SetCurrentProcessExplicitAppUserModelID(string AppID); }' >> "%PS_SCRIPT%"
echo     Add-Type -TypeDefinition $csharp -ErrorAction SilentlyContinue >> "%PS_SCRIPT%"
echo     [WinAPI]::SetCurrentProcessExplicitAppUserModelID("MobileLink.Dashboard.Pro") >> "%PS_SCRIPT%"
echo } catch {} >> "%PS_SCRIPT%"

echo $global:baseDir = '!BASE_DIR!' >> "%PS_SCRIPT%"
echo $global:devFile = '!DEVICES_FILE!' >> "%PS_SCRIPT%"
echo $global:savePath = '!SAVE_FILE!' >> "%PS_SCRIPT%"
echo $global:isDark = ('!SYS_THEME!' -eq 'Dark') >> "%PS_SCRIPT%"

:: START ADB SILENTLY IN BACKGROUND
echo $adbPath = Join-Path $global:baseDir 'adb.exe' >> "%PS_SCRIPT%"
echo Start-Process -FilePath $adbPath -ArgumentList 'start-server' -WindowStyle Hidden >> "%PS_SCRIPT%"

:: =========================================
:: SMOOTH CORNER & SPLIT BUTTON FUNCTIONS
:: =========================================
echo function Make-Rounded($btn, $w, $h, $rad, $isCard) { >> "%PS_SCRIPT%"
echo     $btn.FlatStyle = 'Flat'; $btn.FlatAppearance.BorderSize = 0; $p = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p.AddArc(0, 0, $rad, $rad, 180, 90); $p.AddArc(($w - $rad), 0, $rad, $rad, 270, 90); $p.AddArc(($w - $rad), ($h - $rad), $rad, $rad, 0, 90); $p.AddArc(0, ($h - $rad), $rad, $rad, 90, 90); $p.CloseFigure() >> "%PS_SCRIPT%"
echo     $btn.Region = New-Object System.Drawing.Region($p) >> "%PS_SCRIPT%"
echo     $btn.Add_Paint({ >> "%PS_SCRIPT%"
echo         param($s, $e); $g = $e.Graphics; $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias >> "%PS_SCRIPT%"
echo         $bgC = if ($isCard) { $global:cardBg } else { $s.Parent.BackColor } >> "%PS_SCRIPT%"
echo         if ($bgC -ne $null) { $pen = New-Object System.Drawing.Pen($bgC, 2.5); $g.DrawPath($pen, $p); $pen.Dispose() } >> "%PS_SCRIPT%"
echo     }) >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo function Make-LeftRounded($btn, $w, $h, $rad, $isCard) { >> "%PS_SCRIPT%"
echo     $btn.FlatStyle = 'Flat'; $btn.FlatAppearance.BorderSize = 0; $p = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p.AddArc(0, 0, $rad, $rad, 180, 90); $p.AddLine($w, 0, $w, $h); $p.AddArc(0, ($h - $rad), $rad, $rad, 90, 90); $p.CloseFigure() >> "%PS_SCRIPT%"
echo     $btn.Region = New-Object System.Drawing.Region($p) >> "%PS_SCRIPT%"
echo     $btn.Add_Paint({ >> "%PS_SCRIPT%"
echo         param($s, $e); $g = $e.Graphics; $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias >> "%PS_SCRIPT%"
echo         $bgC = if ($isCard) { $global:cardBg } else { $s.Parent.BackColor } >> "%PS_SCRIPT%"
echo         if ($bgC -ne $null) { $pen = New-Object System.Drawing.Pen($bgC, 2.5); $g.DrawPath($pen, $p); $pen.Dispose() } >> "%PS_SCRIPT%"
echo     }) >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo function Make-RightRounded($btn, $w, $h, $rad, $isCard) { >> "%PS_SCRIPT%"
echo     $btn.FlatStyle = 'Flat'; $btn.FlatAppearance.BorderSize = 0; $p = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p.AddLine(0, $h, 0, 0); $p.AddArc(($w - $rad), 0, $rad, $rad, 270, 90); $p.AddArc(($w - $rad), ($h - $rad), $rad, $rad, 0, 90); $p.CloseFigure() >> "%PS_SCRIPT%"
echo     $btn.Region = New-Object System.Drawing.Region($p) >> "%PS_SCRIPT%"
echo     $btn.Add_Paint({ >> "%PS_SCRIPT%"
echo         param($s, $e); $g = $e.Graphics; $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias >> "%PS_SCRIPT%"
echo         $bgC = if ($isCard) { $global:cardBg } else { $s.Parent.BackColor } >> "%PS_SCRIPT%"
echo         if ($bgC -ne $null) { $pen = New-Object System.Drawing.Pen($bgC, 2.5); $g.DrawPath($pen, $p); $pen.Dispose() } >> "%PS_SCRIPT%"
echo     }) >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

:: ClientSize increased perfectly so shortcuts are NEVER cut off
echo $f = New-Object System.Windows.Forms.Form; $f.Text = 'Mobile Link - Dashboard Pro'; $f.ClientSize = New-Object System.Drawing.Size(905, 600); $f.StartPosition = 'CenterScreen'; $f.FormBorderStyle = 'FixedDialog'; $f.MaximizeBox = $false >> "%PS_SCRIPT%"

echo $icoPath = Join-Path $global:baseDir 'NZT.ico' >> "%PS_SCRIPT%"
echo if (Test-Path $icoPath) { try { $f.Icon = New-Object System.Drawing.Icon($icoPath) } catch { try { $bmp = New-Object System.Drawing.Bitmap($icoPath); $Hicon = $bmp.GetHicon(); $f.Icon = [System.Drawing.Icon]::FromHandle($Hicon) } catch {} } } >> "%PS_SCRIPT%"

:: Top Buttons
echo $btnReset = New-Object System.Windows.Forms.Button; $btnReset.Text = 'Reset Settings'; $btnReset.Location = New-Object System.Drawing.Point(660,40); $btnReset.Size = New-Object System.Drawing.Size(105, 30); $btnReset.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold); $btnReset.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnReset 105 30 10 $false; $f.Controls.Add($btnReset) >> "%PS_SCRIPT%"

echo $btnTheme = New-Object System.Windows.Forms.Button; $btnTheme.Location = New-Object System.Drawing.Point(780,40); $btnTheme.Size = New-Object System.Drawing.Size(90, 30); $btnTheme.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold); $btnTheme.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnTheme 90 30 10 $false; $f.Controls.Add($btnTheme) >> "%PS_SCRIPT%"

:: Left Side Elements
echo $lblUsbSec = New-Object System.Windows.Forms.Label; $lblUsbSec.Text = 'USB Connection'; $lblUsbSec.Location = New-Object System.Drawing.Point(30,40); $lblUsbSec.AutoSize = $true; $lblUsbSec.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $lblStatus1 = New-Object System.Windows.Forms.Label; $lblStatus1.Text = 'USB Not Detected'; $lblStatus1.Location = New-Object System.Drawing.Point(30,80); $lblStatus1.AutoSize = $true; $lblStatus1.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $lblStatus2 = New-Object System.Windows.Forms.Label; $lblStatus2.Text = ''; $lblStatus2.Location = New-Object System.Drawing.Point(30,105); $lblStatus2.AutoSize = $true; $lblStatus2.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"

echo $bUsb = New-Object System.Windows.Forms.Button; $bUsb.Text = 'Connect via USB'; $bUsb.Location = New-Object System.Drawing.Point(30,135); $bUsb.Width = 315; $bUsb.Height = 45; $bUsb.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $bUsb.Enabled = $false; $bUsb.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $bUsb 315 45 10 $true >> "%PS_SCRIPT%"

echo $lblWifiSec = New-Object System.Windows.Forms.Label; $lblWifiSec.Text = 'Wireless Connection'; $lblWifiSec.Location = New-Object System.Drawing.Point(30,225); $lblWifiSec.AutoSize = $true; $lblWifiSec.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $l1 = New-Object System.Windows.Forms.Label; $l1.Text = 'Device IP Address and Port:'; $l1.Location = New-Object System.Drawing.Point(30,265); $l1.AutoSize = $true; $l1.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $l1_sub = New-Object System.Windows.Forms.Label; $l1_sub.Text = 'Wi-Fi only IP or wireless debug IP Port'; $l1_sub.Location = New-Object System.Drawing.Point(30,285); $l1_sub.AutoSize = $true; $l1_sub.Font = New-Object System.Drawing.Font('Segoe UI', 9) >> "%PS_SCRIPT%"

echo $f_font = New-Object System.Drawing.Font('Segoe UI', 12); $t_o1 = New-Object System.Windows.Forms.TextBox; $t_o1.Text = '!o1!'; $t_o1.Location = New-Object System.Drawing.Point(30,310); $t_o1.Width = 45; $t_o1.Font = $f_font; $t_o1.TextAlign = 'Center'; $t_o1.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $d1 = New-Object System.Windows.Forms.Label; $d1.Text = '.'; $d1.Location = New-Object System.Drawing.Point(76,312); $d1.AutoSize = $true; $d1.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $t_o2 = New-Object System.Windows.Forms.TextBox; $t_o2.Text = '!o2!'; $t_o2.Location = New-Object System.Drawing.Point(92,310); $t_o2.Width = 45; $t_o2.Font = $f_font; $t_o2.TextAlign = 'Center'; $t_o2.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $d2 = New-Object System.Windows.Forms.Label; $d2.Text = '.'; $d2.Location = New-Object System.Drawing.Point(138,312); $d2.AutoSize = $true; $d2.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $t_o3 = New-Object System.Windows.Forms.TextBox; $t_o3.Text = '!o3!'; $t_o3.Location = New-Object System.Drawing.Point(154,310); $t_o3.Width = 45; $t_o3.Font = $f_font; $t_o3.TextAlign = 'Center'; $t_o3.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $d3 = New-Object System.Windows.Forms.Label; $d3.Text = '.'; $d3.Location = New-Object System.Drawing.Point(200,312); $d3.AutoSize = $true; $d3.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $t_o4 = New-Object System.Windows.Forms.TextBox; $t_o4.Text = '!o4!'; $t_o4.Location = New-Object System.Drawing.Point(216,310); $t_o4.Width = 45; $t_o4.Font = $f_font; $t_o4.TextAlign = 'Center'; $t_o4.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $colon = New-Object System.Windows.Forms.Label; $colon.Text = ':'; $colon.Location = New-Object System.Drawing.Point(262,310); $colon.AutoSize = $true; $colon.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $t_p = New-Object System.Windows.Forms.TextBox; $t_p.Text = '!JUST_PORT!'; $t_p.Location = New-Object System.Drawing.Point(276,310); $t_p.Width = 69; $t_p.Font = $f_font; $t_p.TextAlign = 'Center'; $t_p.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"

echo $cbSaved = New-Object System.Windows.Forms.ComboBox; $cbSaved.Location = New-Object System.Drawing.Point(30,355); $cbSaved.Width = 270; $cbSaved.Font = $f_font; $cbSaved.DropDownStyle = 'DropDownList'; $cbSaved.FlatStyle = 'Flat' >> "%PS_SCRIPT%"
echo $btnDelDev = New-Object System.Windows.Forms.Button; $btnDelDev.Text = 'X'; $btnDelDev.Location = New-Object System.Drawing.Point(305,354); $btnDelDev.Size = New-Object System.Drawing.Size(40, 29); $btnDelDev.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold); $btnDelDev.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnDelDev 40 29 8 $true >> "%PS_SCRIPT%"

echo function Load-SavedDevices { >> "%PS_SCRIPT%"
echo     $cbSaved.Items.Clear() >> "%PS_SCRIPT%"
echo     [void]$cbSaved.Items.Add('-- Select a Saved Device --') >> "%PS_SCRIPT%"
echo     if (Test-Path $global:devFile) { >> "%PS_SCRIPT%"
echo         $lines = Get-Content $global:devFile >> "%PS_SCRIPT%"
echo         for ($i = $lines.Count - 1; $i -ge 0; $i--) { >> "%PS_SCRIPT%"
echo             $line = $lines[$i] >> "%PS_SCRIPT%"
echo             if ($line -match '==') { $parts = $line -split '==', 2; [void]$cbSaved.Items.Add("$($parts[0]) [$($parts[1])]") } >> "%PS_SCRIPT%"
echo         } >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     $cbSaved.SelectedIndex = 0 >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo function Update-SavedDevice($model, $ipPort) { >> "%PS_SCRIPT%"
echo     $lines = @(); if (Test-Path $global:devFile) { $lines = Get-Content $global:devFile } >> "%PS_SCRIPT%"
echo     $newLines = @() >> "%PS_SCRIPT%"
echo     foreach ($line in $lines) { if ($line -match '\S') { $parts = $line -split '==', 2; if ($parts[0] -ne $model) { $newLines += $line } } } >> "%PS_SCRIPT%"
echo     $newLines += "$model==$ipPort" >> "%PS_SCRIPT%"
echo     if ($newLines.Count -gt 5) { $newLines = $newLines[-5..-1] } >> "%PS_SCRIPT%"
echo     $newLines ^| Out-File $global:devFile -Encoding UTF8 >> "%PS_SCRIPT%"
echo     Load-SavedDevices >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo function Remove-SavedDevice($selText) { >> "%PS_SCRIPT%"
echo     if ($selText -match '^(.*) \[(.*)\]$') { >> "%PS_SCRIPT%"
echo         $model = $matches[1] >> "%PS_SCRIPT%"
echo         $lines = @(); if (Test-Path $global:devFile) { $lines = Get-Content $global:devFile } >> "%PS_SCRIPT%"
echo         $newLines = @() >> "%PS_SCRIPT%"
echo         foreach ($line in $lines) { if ($line -match '\S') { $parts = $line -split '==', 2; if ($parts[0] -ne $model) { $newLines += $line } } } >> "%PS_SCRIPT%"
echo         $newLines ^| Out-File $global:devFile -Encoding UTF8 >> "%PS_SCRIPT%"
echo         Load-SavedDevices >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo Load-SavedDevices >> "%PS_SCRIPT%"

echo $btnDelDev.Add_Click({ >> "%PS_SCRIPT%"
echo     if ($cbSaved.SelectedIndex -gt 0) { Remove-SavedDevice $cbSaved.SelectedItem.ToString() } >> "%PS_SCRIPT%"
echo     $lblPro.Focus() >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"

echo $l1_tip = New-Object System.Windows.Forms.Label; $l1_tip.Text = '* Tip: Connect USB once to auto-fill IP Port'; $l1_tip.Location = New-Object System.Drawing.Point(30,390); $l1_tip.AutoSize = $true; $l1_tip.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Italic) >> "%PS_SCRIPT%"

echo $bWifi = New-Object System.Windows.Forms.Button; $bWifi.Text = 'Connect Wirelessly'; $bWifi.Location = New-Object System.Drawing.Point(30,415); $bWifi.Width = 315; $bWifi.Height = 45; $bWifi.BackColor = [System.Drawing.Color]::FromArgb(16, 137, 62); $bWifi.ForeColor = [System.Drawing.Color]::White; $bWifi.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $bWifi.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $bWifi 315 45 10 $true >> "%PS_SCRIPT%"

echo $f.Controls.AddRange(@($lblUsbSec,$lblStatus1,$lblStatus2,$bUsb,$lblWifiSec,$l1,$l1_sub,$t_o1,$d1,$t_o2,$d2,$t_o3,$d3,$t_o4,$colon,$t_p,$cbSaved,$btnDelDev,$l1_tip,$bWifi)) >> "%PS_SCRIPT%"

:: Right Side Elements
echo $lblPro = New-Object System.Windows.Forms.Label; $lblPro.Text = 'Advanced Settings'; $lblPro.Location = New-Object System.Drawing.Point(410,40); $lblPro.AutoSize = $true; $lblPro.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"

echo $lblCap = New-Object System.Windows.Forms.Label; $lblCap.Text = 'Capture Source:'; $lblCap.Location = New-Object System.Drawing.Point(410,85); $lblCap.AutoSize = $true; $lblCap.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $cbSrc = New-Object System.Windows.Forms.ComboBox; $cbSrc.Location = New-Object System.Drawing.Point(410,110); $cbSrc.Width = 150; $cbSrc.Font = $f_font; $cbSrc.DropDownStyle = 'DropDownList'; $cbSrc.FlatStyle = 'Flat'; @('Screen Mirroring', 'Camera (Webcam)') ^| ForEach-Object { [void]$cbSrc.Items.Add($_) } >> "%PS_SCRIPT%"

echo $lblRot = New-Object System.Windows.Forms.Label; $lblRot.Text = 'Window Rotation:'; $lblRot.Location = New-Object System.Drawing.Point(570,85); $lblRot.AutoSize = $true; $lblRot.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $cbRot = New-Object System.Windows.Forms.ComboBox; $cbRot.Location = New-Object System.Drawing.Point(570,110); $cbRot.Width = 120; $cbRot.Font = $f_font; $cbRot.DropDownStyle = 'DropDownList'; $cbRot.FlatStyle = 'Flat' >> "%PS_SCRIPT%"

echo $lblFace = New-Object System.Windows.Forms.Label; $lblFace.Text = 'Camera Lens:'; $lblFace.Location = New-Object System.Drawing.Point(710,85); $lblFace.AutoSize = $true; $lblFace.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $cbFace = New-Object System.Windows.Forms.ComboBox; $cbFace.Location = New-Object System.Drawing.Point(710,110); $cbFace.Width = 130; $cbFace.Font = $f_font; $cbFace.DropDownStyle = 'DropDownList'; $cbFace.FlatStyle = 'Flat'; @('Back Camera', 'Front Camera') ^| ForEach-Object { [void]$cbFace.Items.Add($_) } >> "%PS_SCRIPT%"
echo if ('!LAST_FACE!' -match '^\d$') { if ([int]'!LAST_FACE!' -lt 2) { $cbFace.SelectedIndex = [int]'!LAST_FACE!' } else { $cbFace.SelectedIndex = 1 } } else { $cbFace.SelectedIndex = 1 } >> "%PS_SCRIPT%"

echo $lblQ = New-Object System.Windows.Forms.Label; $lblQ.Text = 'Resolution:'; $lblQ.Location = New-Object System.Drawing.Point(410,160); $lblQ.AutoSize = $true; $lblQ.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $cbQ = New-Object System.Windows.Forms.ComboBox; $cbQ.Location = New-Object System.Drawing.Point(410,185); $cbQ.Width = 135; $cbQ.Font = $f_font; $cbQ.DropDownStyle = 'DropDownList'; $cbQ.FlatStyle = 'Flat'; @('Original', '4K (UHD)', '2K (QHD)', '1080p (FHD)', '720p', '480p') ^| ForEach-Object { [void]$cbQ.Items.Add($_) } >> "%PS_SCRIPT%"
echo if ('!LAST_Q!' -match '^\d$') { $cbQ.SelectedIndex = [int]'!LAST_Q!' } else { $cbQ.SelectedIndex = 0 } >> "%PS_SCRIPT%"

echo $lblFps = New-Object System.Windows.Forms.Label; $lblFps.Text = 'Max FPS:'; $lblFps.Location = New-Object System.Drawing.Point(555,160); $lblFps.AutoSize = $true; $lblFps.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $cbFps = New-Object System.Windows.Forms.ComboBox; $cbFps.Location = New-Object System.Drawing.Point(555,185); $cbFps.Width = 100; $cbFps.Font = $f_font; $cbFps.DropDownStyle = 'DropDownList'; $cbFps.FlatStyle = 'Flat'; @('Uncapped', '120', '90', '60', '30') ^| ForEach-Object { [void]$cbFps.Items.Add($_) } >> "%PS_SCRIPT%"
echo $cbFps.SelectedItem = '!LAST_FPS!'; if ($cbFps.SelectedIndex -eq -1) { $cbFps.SelectedIndex = 3 } >> "%PS_SCRIPT%"

echo $lblBitrate = New-Object System.Windows.Forms.Label; $lblBitrate.Text = 'Video Quality:'; $lblBitrate.Location = New-Object System.Drawing.Point(665,160); $lblBitrate.AutoSize = $true; $lblBitrate.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $cbBitrate = New-Object System.Windows.Forms.ComboBox; $cbBitrate.Location = New-Object System.Drawing.Point(665,185); $cbBitrate.Width = 175; $cbBitrate.Font = $f_font; $cbBitrate.DropDownStyle = 'DropDownList'; $cbBitrate.FlatStyle = 'Flat'; @('Auto (Balanced)', 'Ultra Clear (32 Mbps)', 'High (16 Mbps)', 'Medium (4 Mbps)', 'Low Lag (2 Mbps)') ^| ForEach-Object { [void]$cbBitrate.Items.Add($_) } >> "%PS_SCRIPT%"
echo if ('!LAST_BITRATE!' -match '^\d$') { $cbBitrate.SelectedIndex = [int]'!LAST_BITRATE!' } else { $cbBitrate.SelectedIndex = 0 } >> "%PS_SCRIPT%"

echo $cbTop = New-Object System.Windows.Forms.CheckBox; $cbTop.Text = ' Always on Top'; $cbTop.Location = New-Object System.Drawing.Point(410, 235); $cbTop.Width = 135; $cbTop.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_TOP!' -match 'True') { $cbTop.Checked = $true } >> "%PS_SCRIPT%"

echo $cbScrOff = New-Object System.Windows.Forms.CheckBox; $cbScrOff.Text = ' Mobile Screen Off'; $cbScrOff.Location = New-Object System.Drawing.Point(550, 235); $cbScrOff.Width = 155; $cbScrOff.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_SCROFF!' -match 'True') { $cbScrOff.Checked = $true } >> "%PS_SCRIPT%"

echo $cbA = New-Object System.Windows.Forms.CheckBox; $cbA.Text = ' Keep Screen Awake'; $cbA.Location = New-Object System.Drawing.Point(710, 235); $cbA.Width = 165; $cbA.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_A!' -match 'True') { $cbA.Checked = $true } >> "%PS_SCRIPT%"

echo $cbOtgK = New-Object System.Windows.Forms.CheckBox; $cbOtgK.Text = ' HID Keyboard'; $cbOtgK.Location = New-Object System.Drawing.Point(410, 270); $cbOtgK.Width = 135; $cbOtgK.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_OTGK!' -match 'True') { $cbOtgK.Checked = $true } >> "%PS_SCRIPT%"
echo $cbOtgM = New-Object System.Windows.Forms.CheckBox; $cbOtgM.Text = ' HID Mouse'; $cbOtgM.Location = New-Object System.Drawing.Point(550, 270); $cbOtgM.Width = 135; $cbOtgM.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_OTGM!' -match 'True') { $cbOtgM.Checked = $true } >> "%PS_SCRIPT%"
echo $cbDesk = New-Object System.Windows.Forms.CheckBox; $cbDesk.Text = ' Desktop Mode'; $cbDesk.Location = New-Object System.Drawing.Point(710, 270); $cbDesk.Width = 135; $cbDesk.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_DESKTOP!' -match 'True') { $cbDesk.Checked = $true } >> "%PS_SCRIPT%"

echo $cbRec = New-Object System.Windows.Forms.CheckBox; $cbRec.Location = New-Object System.Drawing.Point(410, 310); $cbRec.Width = 135; $cbRec.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_REC!' -match 'True') { $cbRec.Checked = $true } >> "%PS_SCRIPT%"
echo if ('!LAST_SRC!' -eq '1') { $cbRec.Text = ' Record Camera' } else { $cbRec.Text = ' Record Screen' } >> "%PS_SCRIPT%"

echo $t_recPath = New-Object System.Windows.Forms.TextBox; $t_recPath.Location = New-Object System.Drawing.Point(545, 311); $t_recPath.Width = 235; $t_recPath.Font = New-Object System.Drawing.Font('Segoe UI', 8.5); $t_recPath.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $defaultPath = [Environment]::GetFolderPath('Desktop') + '\MobileLink_Record.mkv' >> "%PS_SCRIPT%"
echo if ('!LAST_RECPATH!' -ne '') { $t_recPath.Text = '!LAST_RECPATH!' } else { $t_recPath.Text = $defaultPath } >> "%PS_SCRIPT%"

echo $btnBrowse = New-Object System.Windows.Forms.Button; $btnBrowse.Text = 'Browse'; $btnBrowse.Location = New-Object System.Drawing.Point(790, 310); $btnBrowse.Width = 70; $btnBrowse.Height = 26; $btnBrowse.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold); $btnBrowse.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnBrowse 70 26 10 $true >> "%PS_SCRIPT%"

echo $btnBrowse.Add_Click({ >> "%PS_SCRIPT%"
echo     $dlg = New-Object System.Windows.Forms.SaveFileDialog >> "%PS_SCRIPT%"
echo     $dlg.Filter = 'MKV Video (*.mkv)^|*.mkv^|MP4 Video (*.mp4)^|*.mp4' >> "%PS_SCRIPT%"
echo     $dlg.Title = 'Select Recording Save Location' >> "%PS_SCRIPT%"
echo     $dlg.FileName = 'MobileLink_Record.mkv' >> "%PS_SCRIPT%"
echo     if ($dlg.ShowDialog() -eq 'OK') { $t_recPath.Text = $dlg.FileName } >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"

echo $cbAudio = New-Object System.Windows.Forms.CheckBox; $cbAudio.Text = ' Forward Audio'; $cbAudio.Location = New-Object System.Drawing.Point(410, 350); $cbAudio.Width = 135; $cbAudio.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo if ('!LAST_AUDIO!' -match 'True') { $cbAudio.Checked = $true } >> "%PS_SCRIPT%"
echo $cbMic = New-Object System.Windows.Forms.ComboBox; $cbMic.Location = New-Object System.Drawing.Point(550, 349); $cbMic.Width = 150; $cbMic.Font = $f_font; $cbMic.DropDownStyle = 'DropDownList'; $cbMic.FlatStyle = 'Flat'; @('Device Sound', 'Device Mic') ^| ForEach-Object { [void]$cbMic.Items.Add($_) } >> "%PS_SCRIPT%"
echo if ('!LAST_MIC!' -match '^\d$') { $cbMic.SelectedIndex = [int]'!LAST_MIC!' } else { $cbMic.SelectedIndex = 0 } >> "%PS_SCRIPT%"

:: =========================================
:: PERFECTED SPLIT BUTTON
:: =========================================
echo $btnFtp = New-Object System.Windows.Forms.Button; $btnFtp.Text = 'Open Phone Storage'; $btnFtp.Location = New-Object System.Drawing.Point(410,415); $btnFtp.Width = 165; $btnFtp.Height = 45; $btnFtp.BackColor = [System.Drawing.Color]::FromArgb(16, 137, 62); $btnFtp.ForeColor = [System.Drawing.Color]::White; $btnFtp.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold); $btnFtp.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-LeftRounded $btnFtp 165 45 10 $true >> "%PS_SCRIPT%"

echo $btnFtpHelp = New-Object System.Windows.Forms.Button; $btnFtpHelp.Text = '?'; $btnFtpHelp.Location = New-Object System.Drawing.Point(575,415); $btnFtpHelp.Width = 35; $btnFtpHelp.Height = 45; $btnFtpHelp.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $btnFtpHelp.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-RightRounded $btnFtpHelp 35 45 10 $true >> "%PS_SCRIPT%"

echo $ftpToolTip = New-Object System.Windows.Forms.ToolTip; $ftpToolTip.ToolTipTitle = 'WiFi FTP Server Setup'; $ftpToolTip.ToolTipIcon = [System.Windows.Forms.ToolTipIcon]::Info; $ftpToolTip.IsBalloon = $true; >> "%PS_SCRIPT%"
echo $btnFtpHelp.Add_Click({ $ftpToolTip.Show("1. Install 'WiFi FTP Server' app from Play Store.`n2. Open the app and tap 'Start'.`n3. Ensure Port is set to 2221.`n4. Click 'Open Phone Storage' to browse files!", $btnFtpHelp, 0, -90, 10000); $lblPro.Focus() }) >> "%PS_SCRIPT%"

echo $btnHelp = New-Object System.Windows.Forms.Button; $btnHelp.Text = 'Setup Guide'; $btnHelp.Location = New-Object System.Drawing.Point(645,415); $btnHelp.Width = 205; $btnHelp.Height = 45; $btnHelp.BackColor = [System.Drawing.Color]::FromArgb(16, 137, 62); $btnHelp.ForeColor = [System.Drawing.Color]::White; $btnHelp.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold); $btnHelp.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnHelp 205 45 10 $true >> "%PS_SCRIPT%"

echo $f.Controls.AddRange(@($lblPro,$lblCap,$cbSrc,$lblRot,$cbRot,$lblFace,$cbFace,$lblQ,$cbQ,$lblFps,$cbFps,$lblBitrate,$cbBitrate,$cbTop,$cbScrOff,$cbA,$cbOtgK,$cbOtgM,$cbDesk,$cbRec,$t_recPath,$btnBrowse,$cbAudio,$cbMic,$btnFtp,$btnFtpHelp,$btnHelp)) >> "%PS_SCRIPT%"

:: =========================================
:: System Shortcuts Panel
:: =========================================
echo $lblSC1 = New-Object System.Windows.Forms.Label; $lblSC1.Text = "[ALT] + [F] = Toggle Fullscreen`n[ALT] + [Left/Right] = Rotate Display`n[ALT] + [Up/Down] = Volume Control"; $lblSC1.Location = New-Object System.Drawing.Point(30, 515); $lblSC1.AutoSize = $true; $lblSC1.Font = New-Object System.Drawing.Font('Segoe UI', 9) >> "%PS_SCRIPT%"

echo $lblSC2 = New-Object System.Windows.Forms.Label; $lblSC2.Text = "[ALT] + [O] = Mobile Screen Off`n[ALT] + [Shift] + [O] = Mobile Screen On`n[Right-Click] = Power On / Go Back"; $lblSC2.Location = New-Object System.Drawing.Point(330, 515); $lblSC2.AutoSize = $true; $lblSC2.Font = New-Object System.Drawing.Font('Segoe UI', 9) >> "%PS_SCRIPT%"

echo $lblSC3 = New-Object System.Windows.Forms.Label; $lblSC3.Text = "[ALT] + [H] = Home Button`n[ALT] + [S] = Recent Apps Menu`n[ALT] + [C] = Copy to PC Clipboard"; $lblSC3.Location = New-Object System.Drawing.Point(630, 515); $lblSC3.AutoSize = $true; $lblSC3.Font = New-Object System.Drawing.Font('Segoe UI', 9) >> "%PS_SCRIPT%"

echo $f.Controls.AddRange(@($lblSC1, $lblSC2, $lblSC3)) >> "%PS_SCRIPT%"

:: =========================================
:: PAINT EVENT: NATIVE WIN11 CARD BORDERS
:: =========================================
echo $f.Add_Paint({ >> "%PS_SCRIPT%"
echo     param($sender, $e) >> "%PS_SCRIPT%"
echo     $g = $e.Graphics; $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias >> "%PS_SCRIPT%"
echo     if ($global:cardBg -eq $null) { return } >> "%PS_SCRIPT%"
echo     $brush = New-Object System.Drawing.SolidBrush($global:cardBg) >> "%PS_SCRIPT%"
echo     $pen = New-Object System.Drawing.Pen($global:cardBorder, 1.5) >> "%PS_SCRIPT%"
echo     $rad = 12 >> "%PS_SCRIPT%"
echo     $r1 = New-Object System.Drawing.Rectangle(15, 25, 345, 170) >> "%PS_SCRIPT%"
echo     $p1 = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p1.AddArc($r1.X, $r1.Y, $rad, $rad, 180, 90); $p1.AddArc(($r1.Right - $rad), $r1.Y, $rad, $rad, 270, 90) >> "%PS_SCRIPT%"
echo     $p1.AddArc(($r1.Right - $rad), ($r1.Bottom - $rad), $rad, $rad, 0, 90); $p1.AddArc($r1.X, ($r1.Bottom - $rad), $rad, $rad, 90, 90) >> "%PS_SCRIPT%"
echo     $p1.CloseFigure(); $g.FillPath($brush, $p1); $g.DrawPath($pen, $p1) >> "%PS_SCRIPT%"
echo     $r2 = New-Object System.Drawing.Rectangle(15, 210, 345, 265) >> "%PS_SCRIPT%"
echo     $p2 = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p2.AddArc($r2.X, $r2.Y, $rad, $rad, 180, 90); $p2.AddArc(($r2.Right - $rad), $r2.Y, $rad, $rad, 270, 90) >> "%PS_SCRIPT%"
echo     $p2.AddArc(($r2.Right - $rad), ($r2.Bottom - $rad), $rad, $rad, 0, 90); $p2.AddArc($r2.X, ($r2.Bottom - $rad), $rad, $rad, 90, 90) >> "%PS_SCRIPT%"
echo     $p2.CloseFigure(); $g.FillPath($brush, $p2); $g.DrawPath($pen, $p2) >> "%PS_SCRIPT%"
echo     $r3 = New-Object System.Drawing.Rectangle(380, 25, 510, 450) >> "%PS_SCRIPT%"
echo     $p3 = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p3.AddArc($r3.X, $r3.Y, $rad, $rad, 180, 90); $p3.AddArc(($r3.Right - $rad), $r3.Y, $rad, $rad, 270, 90) >> "%PS_SCRIPT%"
echo     $p3.AddArc(($r3.Right - $rad), ($r3.Bottom - $rad), $rad, $rad, 0, 90); $p3.AddArc($r3.X, ($r3.Bottom - $rad), $rad, $rad, 90, 90) >> "%PS_SCRIPT%"
echo     $p3.CloseFigure(); $g.FillPath($brush, $p3); $g.DrawPath($pen, $p3) >> "%PS_SCRIPT%"
echo     $r4 = New-Object System.Drawing.Rectangle(15, 495, 875, 85) >> "%PS_SCRIPT%"
echo     $p4 = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p4.AddArc($r4.X, $r4.Y, $rad, $rad, 180, 90); $p4.AddArc(($r4.Right - $rad), $r4.Y, $rad, $rad, 270, 90) >> "%PS_SCRIPT%"
echo     $p4.AddArc(($r4.Right - $rad), ($r4.Bottom - $rad), $rad, $rad, 0, 90); $p4.AddArc($r4.X, ($r4.Bottom - $rad), $rad, $rad, 90, 90) >> "%PS_SCRIPT%"
echo     $p4.CloseFigure(); $g.FillPath($brush, $p4); $g.DrawPath($pen, $p4) >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"

:: =========================================
:: CUSTOM GREEN CHECKBOX PAINT EVENT
:: =========================================
echo $cbPaint = { >> "%PS_SCRIPT%"
echo     param($sender, $e) >> "%PS_SCRIPT%"
echo     $g = $e.Graphics; $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias >> "%PS_SCRIPT%"
echo     $bSize = 14; $y = [math]::Truncate(($sender.Height - $bSize) / 2) >> "%PS_SCRIPT%"
echo     $rect = New-Object System.Drawing.Rectangle(0, $y, $bSize, $bSize) >> "%PS_SCRIPT%"
echo     $bgBrush = New-Object System.Drawing.SolidBrush($sender.BackColor) >> "%PS_SCRIPT%"
echo     $g.FillRectangle($bgBrush, 0, $y, $bSize + 1, $bSize + 1) >> "%PS_SCRIPT%"
echo     if ($sender.Checked) { >> "%PS_SCRIPT%"
echo         $greenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(16, 137, 62)) >> "%PS_SCRIPT%"
echo         $g.FillRectangle($greenBrush, $rect) >> "%PS_SCRIPT%"
echo         $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 2) >> "%PS_SCRIPT%"
echo         $g.DrawLine($pen, 3, $y + 7, 6, $y + 10); $g.DrawLine($pen, 6, $y + 10, 11, $y + 4) >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Gray, 1.5) >> "%PS_SCRIPT%"
echo         $g.DrawRectangle($pen, $rect) >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"
echo @($cbTop, $cbScrOff, $cbA, $cbOtgK, $cbOtgM, $cbDesk, $cbRec, $cbAudio) ^| ForEach-Object { $_.Add_Paint($cbPaint) } >> "%PS_SCRIPT%"

:: =========================================
:: REMOVE BLUE HIGHLIGHT (FOCUS STEALING MAGIC)
:: =========================================
echo @($cbSrc, $cbFace, $cbQ, $cbFps, $cbRot, $cbMic, $cbSaved, $cbBitrate) ^| ForEach-Object { >> "%PS_SCRIPT%"
echo     $_.Add_SelectedIndexChanged({ $lblPro.Focus() }) >> "%PS_SCRIPT%"
echo     $_.Add_DropDownClosed({ $lblPro.Focus() }) >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"
echo @($cbTop, $cbScrOff, $cbA, $cbOtgK, $cbOtgM, $cbDesk, $cbRec, $cbAudio, $btnDelDev) ^| ForEach-Object { >> "%PS_SCRIPT%"
echo     $_.Add_Click({ $lblPro.Focus() }) >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

:: COMBOBOX AUTO-FILL LOGIC
echo $cbSaved.Add_SelectedIndexChanged({ >> "%PS_SCRIPT%"
echo     if ($cbSaved.SelectedIndex -gt 0) { >> "%PS_SCRIPT%"
echo         $sel = $cbSaved.SelectedItem.ToString() >> "%PS_SCRIPT%"
echo         if ($sel -match '\[([0-9\.]+):(\d+)\]') { >> "%PS_SCRIPT%"
echo             $ipPart = $matches[1]; $pPart = $matches[2] >> "%PS_SCRIPT%"
echo             if ($ipPart -match '(\d+)\.(\d+)\.(\d+)\.(\d+)') { >> "%PS_SCRIPT%"
echo                 $t_o1.Text = $matches[1]; $t_o2.Text = $matches[2]; $t_o3.Text = $matches[3]; $t_o4.Text = $matches[4]; $t_p.Text = $pPart >> "%PS_SCRIPT%"
echo             } >> "%PS_SCRIPT%"
echo         } >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     $lblPro.Focus() >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"

:: =========================================
:: RESET BUTTON LOGIC
:: =========================================
echo $btnReset.Add_Click({ >> "%PS_SCRIPT%"
echo     $cbSrc.SelectedIndex = 0; $cbFace.SelectedIndex = 1; $cbQ.SelectedIndex = 0; $cbFps.SelectedItem = '60'; $cbRot.SelectedIndex = 0; $cbBitrate.SelectedIndex = 0 >> "%PS_SCRIPT%"
echo     $cbTop.Checked = $false; $cbScrOff.Checked = $true; $cbA.Checked = $true; $cbOtgK.Checked = $false; $cbOtgM.Checked = $false; $cbDesk.Checked = $false >> "%PS_SCRIPT%"
echo     $cbRec.Checked = $false; $cbAudio.Checked = $true; $cbMic.SelectedIndex = 0 >> "%PS_SCRIPT%"
echo     $t_recPath.Text = [Environment]::GetFolderPath('Desktop') + '\MobileLink_Record.mkv'; $lblPro.Focus() >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"

:: =========================================
:: Dynamic Logic Engine
:: =========================================
echo $cbRec.Add_CheckedChanged({ $t_recPath.Visible = $cbRec.Checked; $btnBrowse.Visible = $cbRec.Checked }) >> "%PS_SCRIPT%"
echo $t_recPath.Visible = $cbRec.Checked; $btnBrowse.Visible = $cbRec.Checked >> "%PS_SCRIPT%"

echo $cbAudio.Add_CheckedChanged({ $cbMic.Visible = $cbAudio.Checked }) >> "%PS_SCRIPT%"
echo $cbMic.Visible = $cbAudio.Checked >> "%PS_SCRIPT%"

echo $cbSrc.Add_SelectedIndexChanged({ >> "%PS_SCRIPT%"
echo     $isCam = ($cbSrc.SelectedIndex -eq 1) >> "%PS_SCRIPT%"
echo     $lblFace.Visible = $isCam; $cbFace.Visible = $isCam >> "%PS_SCRIPT%"
echo     $cbOtgK.Visible = (-not $isCam); $cbOtgM.Visible = (-not $isCam); $cbDesk.Visible = (-not $isCam) >> "%PS_SCRIPT%"
echo     if ($isCam) { >> "%PS_SCRIPT%"
echo         $lblFace.Location = New-Object System.Drawing.Point(570, 85); $cbFace.Location = New-Object System.Drawing.Point(570, 110) >> "%PS_SCRIPT%"
echo         $lblRot.Location = New-Object System.Drawing.Point(710, 85); $cbRot.Location = New-Object System.Drawing.Point(710, 110) >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $lblRot.Location = New-Object System.Drawing.Point(570, 85); $cbRot.Location = New-Object System.Drawing.Point(570, 110) >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     $cbRot.Items.Clear() >> "%PS_SCRIPT%"
echo     if ($isCam) { >> "%PS_SCRIPT%"
echo         $cbRec.Text = ' Record Camera' >> "%PS_SCRIPT%"
echo         @('Portrait Right', 'Landscape Left') ^| ForEach-Object { [void]$cbRot.Items.Add($_) } >> "%PS_SCRIPT%"
echo         if ('!LAST_ROT!' -match '^\d$') { if ([int]'!LAST_ROT!' -lt 2) { $cbRot.SelectedIndex = [int]'!LAST_ROT!' } else { $cbRot.SelectedIndex = 0 } } else { $cbRot.SelectedIndex = 0 } >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $cbRec.Text = ' Record Screen' >> "%PS_SCRIPT%"
echo         @('Portrait', 'Landscape') ^| ForEach-Object { [void]$cbRot.Items.Add($_) } >> "%PS_SCRIPT%"
echo         if ('!LAST_ROT!' -match '^\d$') { if ([int]'!LAST_ROT!' -lt 2) { $cbRot.SelectedIndex = [int]'!LAST_ROT!' } else { $cbRot.SelectedIndex = 0 } } else { $cbRot.SelectedIndex = 0 } >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"
echo if ('!LAST_SRC!' -match '^\d$') { $cbSrc.SelectedIndex = [int]'!LAST_SRC!' } else { $cbSrc.SelectedIndex = 0 } >> "%PS_SCRIPT%"

:: =========================================
:: Microsoft Fluent Theme System (THE ULTIMATE PERFECT THEME)
:: =========================================
echo function Apply-Theme { >> "%PS_SCRIPT%"
echo     $greenC = [System.Drawing.Color]::FromArgb(16, 137, 62) >> "%PS_SCRIPT%"
echo     if ($global:isDark) { >> "%PS_SCRIPT%"
echo         $bg = [System.Drawing.Color]::FromArgb(20, 20, 20); $fg = [System.Drawing.Color]::White; $fgS = [System.Drawing.Color]::FromArgb(180, 180, 180); $inputBg = [System.Drawing.Color]::FromArgb(35, 35, 35); $tfg = [System.Drawing.Color]::White; $btnThemeBg = [System.Drawing.Color]::FromArgb(50, 50, 50); $goldC = [System.Drawing.Color]::FromArgb(252, 211, 77) >> "%PS_SCRIPT%"
echo         $global:cardBg = [System.Drawing.Color]::FromArgb(30, 30, 30); $global:cardBorder = [System.Drawing.Color]::FromArgb(55, 55, 55) >> "%PS_SCRIPT%"
echo         $dynLblC = [System.Drawing.Color]::White >> "%PS_SCRIPT%"
echo         try { $trueVal = 1; [void][WinAPI]::DwmSetWindowAttribute($f.Handle, 20, [ref]$trueVal, 4) } catch {} >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $bg = [System.Drawing.Color]::FromArgb(243, 243, 243); $fg = [System.Drawing.Color]::Black; $fgS = [System.Drawing.Color]::FromArgb(90, 90, 90); $inputBg = [System.Drawing.Color]::FromArgb(248, 248, 248); $tfg = [System.Drawing.Color]::Black; $btnThemeBg = [System.Drawing.Color]::FromArgb(220, 220, 220); $goldC = [System.Drawing.Color]::FromArgb(217, 119, 6) >> "%PS_SCRIPT%"
echo         $global:cardBg = [System.Drawing.Color]::White; $global:cardBorder = [System.Drawing.Color]::FromArgb(220, 220, 220) >> "%PS_SCRIPT%"
echo         $dynLblC = $greenC >> "%PS_SCRIPT%"
echo         try { $falseVal = 0; [void][WinAPI]::DwmSetWindowAttribute($f.Handle, 20, [ref]$falseVal, 4) } catch {} >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     $f.BackColor = $bg; $btnTheme.Text = if($global:isDark){'Light Mode'}else{'Dark Mode'} >> "%PS_SCRIPT%"
echo     @($lblUsbSec,$lblWifiSec,$lblPro,$d1,$d2,$d3,$colon,$cbA,$cbTop,$cbScrOff,$cbOtgK,$cbOtgM,$cbDesk,$cbRec,$cbAudio) ^| ForEach-Object { $_.ForeColor = $fg } >> "%PS_SCRIPT%"
echo     @($lblStatus1,$lblStatus2) ^| ForEach-Object { $_.ForeColor = $greenC } >> "%PS_SCRIPT%"
echo     @($lblCap,$lblFace,$lblFps,$lblRot,$lblQ,$lblBitrate) ^| ForEach-Object { $_.ForeColor = $dynLblC } >> "%PS_SCRIPT%"
echo     @($lblUsbSec,$lblStatus1,$lblStatus2,$lblWifiSec,$lblPro,$d1,$d2,$d3,$colon,$lblCap,$lblFace,$lblFps,$lblRot,$lblQ,$lblBitrate,$cbA,$cbTop,$cbScrOff,$cbOtgK,$cbOtgM,$cbDesk,$cbRec,$cbAudio,$l1,$l1_sub,$l1_tip,$lblSC1,$lblSC2,$lblSC3) ^| ForEach-Object { $_.BackColor = $global:cardBg } >> "%PS_SCRIPT%"
echo     @($cbA,$cbTop,$cbScrOff,$cbOtgK,$cbOtgM,$cbDesk,$cbRec,$cbAudio) ^| ForEach-Object { $_.FlatStyle = 'Flat'; $_.FlatAppearance.CheckedBackColor = $greenC } >> "%PS_SCRIPT%"
echo     @($l1,$l1_sub,$lblSC1,$lblSC2,$lblSC3) ^| ForEach-Object { $_.ForeColor = $fgS } >> "%PS_SCRIPT%"
echo     @($t_o1,$t_o2,$t_o3,$t_o4,$t_p,$cbQ,$cbSrc,$cbFace,$cbFps,$cbRot,$cbBitrate,$t_recPath,$cbMic,$cbSaved) ^| ForEach-Object { $_.BackColor=$inputBg; $_.ForeColor=$tfg } >> "%PS_SCRIPT%"
echo     $btnBrowse.BackColor = $btnThemeBg; $btnBrowse.ForeColor = $goldC >> "%PS_SCRIPT%"
echo     @($btnReset, $btnTheme) ^| ForEach-Object { $_.BackColor = $greenC; $_.ForeColor = [System.Drawing.Color]::White } >> "%PS_SCRIPT%"
echo     $btnDelDev.BackColor = [System.Drawing.Color]::FromArgb(211, 47, 47); $btnDelDev.ForeColor = [System.Drawing.Color]::White >> "%PS_SCRIPT%"
echo     $btnFtpHelp.BackColor = $goldC; $btnFtpHelp.ForeColor = if($global:isDark){[System.Drawing.Color]::Black}else{[System.Drawing.Color]::White} >> "%PS_SCRIPT%"
echo     $l1_tip.ForeColor = $goldC; $f.Invalidate() >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

:: =========================================
:: Independent Scrcpy Launcher Engine
:: =========================================
echo function Launch-Scrcpy($act) { >> "%PS_SCRIPT%"
echo     Save-Settings; $scrcpyArgs = @(); $model = 'Mobile Device' >> "%PS_SCRIPT%"
echo     if ($act -eq 'USB') { >> "%PS_SCRIPT%"
echo         $out = (.\adb.exe -d shell getprop ro.product.model 2^>^&1) -join '' >> "%PS_SCRIPT%"
echo         if ($out -notmatch 'error^|daemon^|offline^|not found') { $m = $out.Trim(); if ($m -ne '') { $model = $m } } >> "%PS_SCRIPT%"
echo         $title = "$model (USB)"; $scrcpyArgs += '-d' >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $ip = "$($t_o1.Text).$($t_o2.Text).$($t_o3.Text).$($t_o4.Text)"; $port = $t_p.Text; $fullIp = "$ip`:$port" >> "%PS_SCRIPT%"
echo         Start-Process -FilePath '.\adb.exe' -ArgumentList "connect $fullIp" -Wait -WindowStyle Hidden >> "%PS_SCRIPT%"
echo         $out = (.\adb.exe -s $fullIp shell getprop ro.product.model 2^>^&1) -join '' >> "%PS_SCRIPT%"
echo         if ($out -notmatch 'error^|daemon^|offline^|not found') { $m = $out.Trim(); if ($m -ne '') { $model = $m; Update-SavedDevice $model $fullIp } } >> "%PS_SCRIPT%"
echo         $title = "$model (Wi-Fi)"; $scrcpyArgs += '-s'; $scrcpyArgs += $fullIp >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     $scrcpyArgs += '--window-title'; $scrcpyArgs += $title >> "%PS_SCRIPT%"
echo     if ($cbTop.Checked) { $scrcpyArgs += '--always-on-top' } >> "%PS_SCRIPT%"
echo     $src = $cbSrc.SelectedIndex; $rot = $cbRot.SelectedIndex; $face = $cbFace.SelectedIndex >> "%PS_SCRIPT%"
echo     if ($src -eq 0) { >> "%PS_SCRIPT%"
echo         if ($cbA.Checked) { $scrcpyArgs += '-w' } >> "%PS_SCRIPT%"
echo         if ($cbScrOff.Checked) { $scrcpyArgs += '-S' } >> "%PS_SCRIPT%"
echo         if ($cbOtgK.Checked) { $scrcpyArgs += '--keyboard=uhid' } >> "%PS_SCRIPT%"
echo         if ($cbOtgM.Checked) { $scrcpyArgs += '--mouse=uhid' } >> "%PS_SCRIPT%"
echo         if ($cbDesk.Checked) { $scrcpyArgs += '--new-display' } >> "%PS_SCRIPT%"
echo         if ($rot -eq 1) { $scrcpyArgs += '--display-orientation=270' } >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $scrcpyArgs += '--video-source=camera' >> "%PS_SCRIPT%"
echo         if ($face -eq 0) { $scrcpyArgs += '--camera-facing=back' } >> "%PS_SCRIPT%"
echo         if ($face -eq 1) { $scrcpyArgs += '--camera-facing=front' } >> "%PS_SCRIPT%"
echo         if ($face -eq 1) { >> "%PS_SCRIPT%"
echo             if ($rot -eq 0) { $scrcpyArgs += '--display-orientation=flip90' } >> "%PS_SCRIPT%"
echo             if ($rot -eq 1) { $scrcpyArgs += '--display-orientation=flip0' } >> "%PS_SCRIPT%"
echo         } else { >> "%PS_SCRIPT%"
echo             if ($rot -eq 0) { $scrcpyArgs += '--display-orientation=flip270' } >> "%PS_SCRIPT%"
echo             if ($rot -eq 1) { $scrcpyArgs += '--display-orientation=flip0' } >> "%PS_SCRIPT%"
echo         } >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     $q = $cbQ.SelectedIndex >> "%PS_SCRIPT%"
echo     if ($q -eq 1) { $scrcpyArgs += '-m'; $scrcpyArgs += '3840' } >> "%PS_SCRIPT%"
echo     if ($q -eq 2) { $scrcpyArgs += '-m'; $scrcpyArgs += '2560' } >> "%PS_SCRIPT%"
echo     if ($q -eq 3) { $scrcpyArgs += '-m'; $scrcpyArgs += '1920' } >> "%PS_SCRIPT%"
echo     if ($q -eq 4) { $scrcpyArgs += '-m'; $scrcpyArgs += '1280' } >> "%PS_SCRIPT%"
echo     if ($q -eq 5) { $scrcpyArgs += '-m'; $scrcpyArgs += '800' } >> "%PS_SCRIPT%"
echo     $fps = $cbFps.SelectedItem >> "%PS_SCRIPT%"
echo     if ($fps -ne 'Uncapped' -and $fps -ne '') { $scrcpyArgs += '--max-fps'; $scrcpyArgs += $fps } >> "%PS_SCRIPT%"
echo     $br = $cbBitrate.SelectedIndex >> "%PS_SCRIPT%"
echo     if ($br -eq 1) { $scrcpyArgs += '-b'; $scrcpyArgs += '32M' } >> "%PS_SCRIPT%"
echo     if ($br -eq 2) { $scrcpyArgs += '-b'; $scrcpyArgs += '16M' } >> "%PS_SCRIPT%"
echo     if ($br -eq 3) { $scrcpyArgs += '-b'; $scrcpyArgs += '4M' } >> "%PS_SCRIPT%"
echo     if ($br -eq 4) { $scrcpyArgs += '-b'; $scrcpyArgs += '2M' } >> "%PS_SCRIPT%"
echo     if ($cbRec.Checked) { >> "%PS_SCRIPT%"
echo         $ts = Get-Date -Format 'yyyyMMdd_HHmmss'; $bp = $t_recPath.Text >> "%PS_SCRIPT%"
echo         $dir = [System.IO.Path]::GetDirectoryName($bp); $fn = [System.IO.Path]::GetFileNameWithoutExtension($bp) >> "%PS_SCRIPT%"
echo         $ext = [System.IO.Path]::GetExtension($bp); if ($ext -eq '') { $ext = '.mkv' } >> "%PS_SCRIPT%"
echo         $fp = Join-Path $dir "$fn`_$ts$ext"; $scrcpyArgs += '--record'; $scrcpyArgs += $fp >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     if (-not $cbAudio.Checked) { $scrcpyArgs += '--no-audio' } else { if ($cbMic.SelectedIndex -eq 1) { $scrcpyArgs += '--audio-source=mic' } } >> "%PS_SCRIPT%"
echo     $exeToUse = if (Test-Path (Join-Path $global:baseDir 'scrcpy-noconsole.exe')) { Join-Path $global:baseDir 'scrcpy-noconsole.exe' } else { Join-Path $global:baseDir 'scrcpy.exe' } >> "%PS_SCRIPT%"
echo     $pinfo = New-Object System.Diagnostics.ProcessStartInfo; $pinfo.FileName = $exeToUse; $pinfo.WorkingDirectory = $global:baseDir >> "%PS_SCRIPT%"
echo     $pinfo.UseShellExecute = $false; $pinfo.CreateNoWindow = $true; $argStr = '' >> "%PS_SCRIPT%"
echo     foreach ($a in $scrcpyArgs) { if ($a -match '\s') { $argStr += "`"$a`" " } else { $argStr += "$a " } } >> "%PS_SCRIPT%"
echo     $pinfo.Arguments = $argStr.Trim(); [System.Diagnostics.Process]::Start($pinfo) ^| Out-Null >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo function Save-Settings { >> "%PS_SCRIPT%"
echo     $th_v = if ($global:isDark) { 'Dark' } else { 'Light' } >> "%PS_SCRIPT%"
echo     "$($t_o1.Text).$($t_o2.Text).$($t_o3.Text).$($t_o4.Text):$($t_p.Text);$($cbQ.SelectedIndex);$($cbA.Checked);$th_v;$($cbSrc.SelectedIndex);$($cbOtgK.Checked);$($cbOtgM.Checked);$($cbFps.SelectedItem);$($cbRot.SelectedIndex);$($cbFace.SelectedIndex);$($cbTop.Checked);$($cbScrOff.Checked);$($cbRec.Checked);$($t_recPath.Text);$($cbAudio.Checked);$($cbMic.SelectedIndex);$($cbDesk.Checked);$($cbBitrate.SelectedIndex)" ^| Out-File $global:savePath -Encoding ascii >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo Apply-Theme; $btnTheme.Add_Click({ $global:isDark = -not $global:isDark; Apply-Theme; Save-Settings; $lblPro.Focus() }) >> "%PS_SCRIPT%"
echo $bUsb.Add_Click({ $bUsb.Text='Connecting...'; $bUsb.Enabled=$false; $bWifi.Enabled=$false; [System.Windows.Forms.Application]::DoEvents(); Launch-Scrcpy 'USB'; Start-Sleep -Milliseconds 600; $bUsb.Text='Connect via USB'; $bUsb.Enabled=$true; $bWifi.Enabled=$true; $lblPro.Focus() }) >> "%PS_SCRIPT%"
echo $bWifi.Add_Click({ $bWifi.Text='Connecting...'; $bUsb.Enabled=$false; $bWifi.Enabled=$false; [System.Windows.Forms.Application]::DoEvents(); Launch-Scrcpy 'WIFI'; Start-Sleep -Milliseconds 600; $bWifi.Text='Connect Wirelessly'; $bUsb.Enabled=$true; $bWifi.Enabled=$true; $lblPro.Focus() }) >> "%PS_SCRIPT%"
echo $btnFtp.Add_Click({ Save-Settings; $ip = "$($t_o1.Text).$($t_o2.Text).$($t_o3.Text).$($t_o4.Text)"; Start-Process explorer "ftp://$ip`:2221"; $lblPro.Focus() }) >> "%PS_SCRIPT%"
echo $btnHelp.Add_Click({ Start-Process 'help.html'; $lblPro.Focus() }) >> "%PS_SCRIPT%"

:: Strict USB Detection logic
echo $global:setup = $false; $global:dropCount = 0; $timer = New-Object System.Windows.Forms.Timer; $timer.Interval = 1000 >> "%PS_SCRIPT%"
echo $timer.Add_Tick({ >> "%PS_SCRIPT%"
echo     $adbPath = Join-Path $global:baseDir 'adb.exe' >> "%PS_SCRIPT%"
echo     $adb_out = ((^& $adbPath -d get-state 2^>^&1) -join ' ').Trim() >> "%PS_SCRIPT%"
echo     if ($adb_out -eq 'device') { >> "%PS_SCRIPT%"
echo         $lblStatus1.Text = 'USB Detected'; $lblStatus1.ForeColor = [System.Drawing.Color]::FromArgb(16, 137, 62) >> "%PS_SCRIPT%"
echo         $lblStatus2.Text = 'USB Debugging ON (Ready)'; $lblStatus2.ForeColor = [System.Drawing.Color]::FromArgb(16, 137, 62) >> "%PS_SCRIPT%"
echo         if (-not $bUsb.Text.Contains('Connecting')) { $bUsb.Enabled = $true }; $bUsb.BackColor = [System.Drawing.Color]::FromArgb(16, 137, 62); $bUsb.ForeColor = [System.Drawing.Color]::White >> "%PS_SCRIPT%"
echo         $global:dropCount = 0 >> "%PS_SCRIPT%"
echo         if (-not $global:setup) { >> "%PS_SCRIPT%"
echo             $global:setup = $true >> "%PS_SCRIPT%"
echo             $modelOut = ((^& $adbPath -d shell getprop ro.product.model 2^>^&1) -join '').Trim() >> "%PS_SCRIPT%"
echo             $ip=(^& $adbPath -d shell ip addr show wlan0 2^>^&1) -join ' ' >> "%PS_SCRIPT%"
echo             if($ip -match 'inet\s+(\d+)\.(\d+)\.(\d+)\.(\d+)') { $t_o1.Text=$matches[1]; $t_o2.Text=$matches[2]; $t_o3.Text=$matches[3]; $t_o4.Text=$matches[4] } >> "%PS_SCRIPT%"
echo             $p=Get-Random -Min 30000 -Max 50000; $t_p.Text=$p; Start-Process -FilePath $adbPath -ArgumentList "-d tcpip $p" -WindowStyle Hidden; Save-Settings >> "%PS_SCRIPT%"
echo             if ($modelOut -notmatch 'error^|daemon^|offline^|not found' -and $modelOut -ne '') { $newIp = "$($t_o1.Text).$($t_o2.Text).$($t_o3.Text).$($t_o4.Text):$p"; Update-SavedDevice $modelOut $newIp } >> "%PS_SCRIPT%"
echo         } >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $lblStatus1.Text = 'USB Not Detected'; $lblStatus1.ForeColor = [System.Drawing.Color]::FromArgb(218, 59, 1); $lblStatus2.Text = ''; >> "%PS_SCRIPT%"
echo         $global:dropCount++; if ($global:dropCount -gt 3) { $global:setup = $false } >> "%PS_SCRIPT%"
echo         $bUsb.Enabled = $false; if ($global:isDark) { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50); $bUsb.ForeColor = [System.Drawing.Color]::FromArgb(180,180,180) } else { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(220, 220, 220); $bUsb.ForeColor = [System.Drawing.Color]::FromArgb(90,90,90) } >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo }); $timer.Start(); >> "%PS_SCRIPT%"

:: KILL INSTANT SPLASH SCREEN RIGHT BEFORE SHOWING MAIN FORM
echo Get-Process mshta -ErrorAction SilentlyContinue ^| Stop-Process >> "%PS_SCRIPT%"

:: ENSURE HANDLE IS CREATED BEFORE DWM CALL
echo $dummy = $f.Handle >> "%PS_SCRIPT%"
echo $f.Add_FormClosing({ Save-Settings }) >> "%PS_SCRIPT%"
echo $f.ShowDialog() ^| Out-Null >> "%PS_SCRIPT%"

:: Start the completely decoupled UI
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%PS_SCRIPT%"
del "%PS_SCRIPT%" >nul 2>&1
exit