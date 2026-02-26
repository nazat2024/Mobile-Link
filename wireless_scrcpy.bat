@echo off
setlocal enabledelayedexpansion
title Mobile Link - Dashboard
cd /d "%~dp0"

:: =========================================
:: ১. ডাটা রিড করা এবং সেফটি চেক
:: =========================================
set "APP_DATA_DIR=%APPDATA%\MobileLink"
if not exist "%APP_DATA_DIR%" mkdir "%APP_DATA_DIR%"
set "SAVE_FILE=%APP_DATA_DIR%\nazat_save.txt"

set "SAVED_IP="
set "LAST_Q=2"
set "LAST_A=y"
set "SAVED_THEME=Dark"

if exist "%SAVE_FILE%" (
    for /f "usebackq tokens=1,2,3,4 delims=," %%a in ("%SAVE_FILE%") do (
        if not "%%a"=="" set "SAVED_IP=%%a"
        if not "%%b"=="" set "LAST_Q=%%b"
        if not "%%c"=="" set "LAST_A=%%c"
        if not "%%d"=="" set "SAVED_THEME=%%d"
    )
)

set "JUST_IP=192.168.1.106"
set "JUST_PORT=5555"

if not "!SAVED_IP!"=="" (
    for /f "tokens=1,2 delims=:" %%i in ("!SAVED_IP!") do (
        set "JUST_IP=%%i"
        if not "%%j"=="" set "JUST_PORT=%%j"
    )
)

set "o1=192" & set "o2=168" & set "o3=1" & set "o4=106"
for /f "tokens=1,2,3,4 delims=." %%a in ("!JUST_IP!") do (
    if not "%%a"=="" set "o1=%%a"
    if not "%%b"=="" set "o2=%%b"
    if not "%%c"=="" set "o3=%%c"
    if not "%%d"=="" set "o4=%%d"
)

echo Force Cleaning ADB Tasks...
taskkill /f /im adb.exe /t >nul 2>&1
adb start-server >nul 2>&1

:: =========================================
:: ২. মেইন ড্যাশবোর্ড লুপ (Ultimate Edition)
:: =========================================
:MainMenu
cls
echo Preparing Smart Dashboard...

set "PS_SCRIPT=%temp%\nazat_gui.ps1"
echo Add-Type -AssemblyName System.Windows.Forms > "%PS_SCRIPT%"
echo Add-Type -AssemblyName System.Drawing >> "%PS_SCRIPT%"

echo $global:savePath = '!SAVE_FILE!' >> "%PS_SCRIPT%"
echo $global:isDark = ('!SAVED_THEME!' -ne 'Light') >> "%PS_SCRIPT%"

:: Rounded Corners Function
echo function Make-Rounded($btn, $w, $h, $rad) { >> "%PS_SCRIPT%"
echo     $btn.FlatStyle = 'Flat'; $btn.FlatAppearance.BorderSize = 0 >> "%PS_SCRIPT%"
echo     $p = New-Object System.Drawing.Drawing2D.GraphicsPath >> "%PS_SCRIPT%"
echo     $p.AddArc(0, 0, $rad, $rad, 180, 90) ^| Out-Null >> "%PS_SCRIPT%"
echo     $p.AddArc(($w - $rad), 0, $rad, $rad, 270, 90) ^| Out-Null >> "%PS_SCRIPT%"
echo     $p.AddArc(($w - $rad), ($h - $rad), $rad, $rad, 0, 90) ^| Out-Null >> "%PS_SCRIPT%"
echo     $p.AddArc(0, ($h - $rad), $rad, $rad, 90, 90) ^| Out-Null >> "%PS_SCRIPT%"
echo     $p.CloseFigure() >> "%PS_SCRIPT%"
echo     $btn.Region = New-Object System.Drawing.Region($p) >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo $f = New-Object System.Windows.Forms.Form >> "%PS_SCRIPT%"
echo $f.Text = 'Mobile Link - Dashboard' >> "%PS_SCRIPT%"
echo $f.Size = New-Object System.Drawing.Size(360,610) >> "%PS_SCRIPT%"
echo $f.StartPosition = 'CenterScreen' >> "%PS_SCRIPT%"
echo $f.FormBorderStyle = 'FixedDialog' >> "%PS_SCRIPT%"
echo $f.MaximizeBox = $false >> "%PS_SCRIPT%"

:: Theme Toggle Button
echo $btnTheme = New-Object System.Windows.Forms.Button; $btnTheme.Location = New-Object System.Drawing.Point(230,15); $btnTheme.Size = New-Object System.Drawing.Size(100, 30); $btnTheme.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold); $btnTheme.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnTheme 100 30 15 >> "%PS_SCRIPT%"
echo $f.Controls.Add($btnTheme) >> "%PS_SCRIPT%"

:: Section 1: USB Connection
echo $lblUsbSec = New-Object System.Windows.Forms.Label; $lblUsbSec.Text = 'USB Connection'; $lblUsbSec.Location = New-Object System.Drawing.Point(20,20); $lblUsbSec.AutoSize = $true; $lblUsbSec.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $f.Controls.Add($lblUsbSec) >> "%PS_SCRIPT%"

echo $lblStatus1 = New-Object System.Windows.Forms.Label; $lblStatus1.Text = 'USB Not Detected'; $lblStatus1.Location = New-Object System.Drawing.Point(20,55); $lblStatus1.AutoSize = $true; $lblStatus1.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold); $lblStatus1.ForeColor = [System.Drawing.Color]::FromArgb(244, 63, 94) >> "%PS_SCRIPT%"
echo $f.Controls.Add($lblStatus1) >> "%PS_SCRIPT%"

echo $lblStatus2 = New-Object System.Windows.Forms.Label; $lblStatus2.Text = ''; $lblStatus2.Location = New-Object System.Drawing.Point(20,78); $lblStatus2.AutoSize = $true; $lblStatus2.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold); $lblStatus2.ForeColor = [System.Drawing.Color]::FromArgb(244, 63, 94) >> "%PS_SCRIPT%"
echo $f.Controls.Add($lblStatus2) >> "%PS_SCRIPT%"

:: USB Button
echo $bUsb = New-Object System.Windows.Forms.Button; $bUsb.Text = 'Connect via USB'; $bUsb.Location = New-Object System.Drawing.Point(20,105); $bUsb.Width = 301; $bUsb.Height = 45; $bUsb.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $bUsb.Enabled = $false >> "%PS_SCRIPT%"
echo Make-Rounded $bUsb 301 45 16 >> "%PS_SCRIPT%"
echo $bUsb.Add_MouseEnter({ if ($bUsb.Enabled) { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(5, 150, 105) } }) >> "%PS_SCRIPT%"
echo $bUsb.Add_MouseLeave({ if ($bUsb.Enabled) { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(16, 185, 129) } }) >> "%PS_SCRIPT%"
echo $bUsb.Add_Click({ Save-Settings; $global:res = "USB,USB_MODE,5555," + $cbQ.SelectedItem + "," + $cbA.SelectedItem; $f.Close() }) >> "%PS_SCRIPT%"
echo $f.Controls.Add($bUsb) >> "%PS_SCRIPT%"

:: Section 2: Wireless Connection
echo $lblWifiSec = New-Object System.Windows.Forms.Label; $lblWifiSec.Text = 'Wireless Connection'; $lblWifiSec.Location = New-Object System.Drawing.Point(20,175); $lblWifiSec.AutoSize = $true; $lblWifiSec.Font = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $f.Controls.Add($lblWifiSec) >> "%PS_SCRIPT%"

echo $l1 = New-Object System.Windows.Forms.Label; $l1.Text = 'Device IP Address and Port:'; $l1.Location = New-Object System.Drawing.Point(20,210); $l1.AutoSize = $true; $l1.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo $f.Controls.Add($l1) >> "%PS_SCRIPT%"

echo $l1_sub = New-Object System.Windows.Forms.Label; $l1_sub.Text = 'Wi-Fi only IP or wireless debug IP ^& Port'; $l1_sub.Location = New-Object System.Drawing.Point(20,230); $l1_sub.AutoSize = $true; $l1_sub.Font = New-Object System.Drawing.Font('Segoe UI', 8.5) >> "%PS_SCRIPT%"
echo $f.Controls.Add($l1_sub) >> "%PS_SCRIPT%"

echo $f_font = New-Object System.Drawing.Font('Segoe UI', 12) >> "%PS_SCRIPT%"

:: IP Inputs
echo $t_o1 = New-Object System.Windows.Forms.TextBox; $t_o1.Text = '!o1!'; $t_o1.Location = New-Object System.Drawing.Point(20,250); $t_o1.Width = 45; $t_o1.Font = $f_font; $t_o1.TextAlign = 'Center'; $t_o1.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $d1 = New-Object System.Windows.Forms.Label; $d1.Text = '.'; $d1.Location = New-Object System.Drawing.Point(66,252); $d1.AutoSize = $true; $d1.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $d1.BackColor = [System.Drawing.Color]::Transparent >> "%PS_SCRIPT%"

echo $t_o2 = New-Object System.Windows.Forms.TextBox; $t_o2.Text = '!o2!'; $t_o2.Location = New-Object System.Drawing.Point(82,250); $t_o2.Width = 45; $t_o2.Font = $f_font; $t_o2.TextAlign = 'Center'; $t_o2.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $d2 = New-Object System.Windows.Forms.Label; $d2.Text = '.'; $d2.Location = New-Object System.Drawing.Point(128,252); $d2.AutoSize = $true; $d2.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $d2.BackColor = [System.Drawing.Color]::Transparent >> "%PS_SCRIPT%"

echo $t_o3 = New-Object System.Windows.Forms.TextBox; $t_o3.Text = '!o3!'; $t_o3.Location = New-Object System.Drawing.Point(144,250); $t_o3.Width = 45; $t_o3.Font = $f_font; $t_o3.TextAlign = 'Center'; $t_o3.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"
echo $d3 = New-Object System.Windows.Forms.Label; $d3.Text = '.'; $d3.Location = New-Object System.Drawing.Point(190,252); $d3.AutoSize = $true; $d3.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $d3.BackColor = [System.Drawing.Color]::Transparent >> "%PS_SCRIPT%"

echo $t_o4 = New-Object System.Windows.Forms.TextBox; $t_o4.Text = '!o4!'; $t_o4.Location = New-Object System.Drawing.Point(206,250); $t_o4.Width = 45; $t_o4.Font = $f_font; $t_o4.TextAlign = 'Center'; $t_o4.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"

echo $colon = New-Object System.Windows.Forms.Label; $colon.Text = ':'; $colon.Location = New-Object System.Drawing.Point(252,250); $colon.AutoSize = $true; $colon.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $colon.BackColor = [System.Drawing.Color]::Transparent >> "%PS_SCRIPT%"
echo $t_p = New-Object System.Windows.Forms.TextBox; $t_p.Text = '!JUST_PORT!'; $t_p.Location = New-Object System.Drawing.Point(266,250); $t_p.Width = 55; $t_p.Font = $f_font; $t_p.TextAlign = 'Center'; $t_p.BorderStyle = 'FixedSingle' >> "%PS_SCRIPT%"

echo $f.Controls.AddRange(@($t_o1,$d1,$t_o2,$d2,$t_o3,$d3,$t_o4,$colon,$t_p)) >> "%PS_SCRIPT%"

:: Golden Tip
echo $lblTip = New-Object System.Windows.Forms.Label; $lblTip.Text = '* Tip: Connect USB once to auto-fill IP ^& Port'; $lblTip.Location = New-Object System.Drawing.Point(20,282); $lblTip.AutoSize = $true; $lblTip.Font = New-Object System.Drawing.Font('Segoe UI', 8.5, [System.Drawing.FontStyle]::Italic); $lblTip.ForeColor = [System.Drawing.Color]::FromArgb(245, 158, 11) >> "%PS_SCRIPT%"
echo $f.Controls.Add($lblTip) >> "%PS_SCRIPT%"

:: Side-by-Side Dropdown Menus
echo $lblQ = New-Object System.Windows.Forms.Label; $lblQ.Text = 'Video Quality:'; $lblQ.Location = New-Object System.Drawing.Point(20,310); $lblQ.AutoSize = $true; $lblQ.Font = New-Object System.Drawing.Font('Segoe UI', 10) >> "%PS_SCRIPT%"
echo $cbQ = New-Object System.Windows.Forms.ComboBox; $cbQ.Location = New-Object System.Drawing.Point(20,335); $cbQ.Width = 145; $cbQ.Font = $f_font; $cbQ.DropDownStyle = 'DropDownList' >> "%PS_SCRIPT%"
echo @('1 - Ultra', '2 - High', '3 - Medium', '4 - Low') ^| ForEach-Object { $cbQ.Items.Add($_) ^| Out-Null } >> "%PS_SCRIPT%"
echo if ('!LAST_Q!' -eq '1') { $cbQ.SelectedIndex = 0 } elseif ('!LAST_Q!' -eq '3') { $cbQ.SelectedIndex = 2 } elseif ('!LAST_Q!' -eq '4') { $cbQ.SelectedIndex = 3 } else { $cbQ.SelectedIndex = 1 } >> "%PS_SCRIPT%"

echo $lblA = New-Object System.Windows.Forms.Label; $lblA.Text = 'Screen Awake?'; $lblA.Location = New-Object System.Drawing.Point(175,310); $lblA.AutoSize = $true; $lblA.Font = New-Object System.Drawing.Font('Segoe UI', 10) >> "%PS_SCRIPT%"
echo $cbA = New-Object System.Windows.Forms.ComboBox; $cbA.Location = New-Object System.Drawing.Point(175,335); $cbA.Width = 145; $cbA.Font = $f_font; $cbA.DropDownStyle = 'DropDownList' >> "%PS_SCRIPT%"
echo @('Yes', 'No') ^| ForEach-Object { $cbA.Items.Add($_) ^| Out-Null } >> "%PS_SCRIPT%"
echo if ('!LAST_A!' -eq 'n') { $cbA.SelectedIndex = 1 } else { $cbA.SelectedIndex = 0 } >> "%PS_SCRIPT%"

echo $f.Controls.AddRange(@($lblQ,$cbQ,$lblA,$cbA)) >> "%PS_SCRIPT%"

:: Action Buttons
echo $b = New-Object System.Windows.Forms.Button; $b.Text = 'Connect Wirelessly'; $b.Location = New-Object System.Drawing.Point(20,390); $b.Width = 301; $b.Height = 45; $b.BackColor = [System.Drawing.Color]::FromArgb(14, 165, 233); $b.ForeColor = [System.Drawing.Color]::White; $b.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $b.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $b 301 45 16 >> "%PS_SCRIPT%"
echo $b.Add_MouseEnter({ $b.BackColor = [System.Drawing.Color]::FromArgb(2, 132, 199) }) >> "%PS_SCRIPT%"
echo $b.Add_MouseLeave({ $b.BackColor = [System.Drawing.Color]::FromArgb(14, 165, 233) }) >> "%PS_SCRIPT%"
echo $b.Add_Click({ Save-Settings; $global:res = "WIFI," + $t_o1.Text + "." + $t_o2.Text + "." + $t_o3.Text + "." + $t_o4.Text + "," + $t_p.Text + "," + $cbQ.SelectedItem + "," + $cbA.SelectedItem; $f.Close() }) >> "%PS_SCRIPT%"

:: =========================================
:: [NEW] CUSTOM FTP UI WITH LIVE IP
:: =========================================
echo $btnFtp = New-Object System.Windows.Forms.Button; $btnFtp.Text = 'Open Phone Storage'; $btnFtp.Location = New-Object System.Drawing.Point(20,445); $btnFtp.Width = 301; $btnFtp.Height = 45; $btnFtp.BackColor = [System.Drawing.Color]::FromArgb(139, 92, 246); $btnFtp.ForeColor = [System.Drawing.Color]::White; $btnFtp.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $btnFtp.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnFtp 301 45 16 >> "%PS_SCRIPT%"
echo $btnFtp.Add_MouseEnter({ $btnFtp.BackColor = [System.Drawing.Color]::FromArgb(124, 58, 237) }) >> "%PS_SCRIPT%"
echo $btnFtp.Add_MouseLeave({ $btnFtp.BackColor = [System.Drawing.Color]::FromArgb(139, 92, 246) }) >> "%PS_SCRIPT%"
echo $btnFtp.Add_Click({ >> "%PS_SCRIPT%"
echo     Save-Settings >> "%PS_SCRIPT%"
echo     $ip = $t_o1.Text + '.' + $t_o2.Text + '.' + $t_o3.Text + '.' + $t_o4.Text >> "%PS_SCRIPT%"
echo     $ftpForm = New-Object System.Windows.Forms.Form >> "%PS_SCRIPT%"
echo     $ftpForm.Text = 'Connect to Phone Storage' >> "%PS_SCRIPT%"
echo     $ftpForm.Size = New-Object System.Drawing.Size(360, 200) >> "%PS_SCRIPT%"
echo     $ftpForm.StartPosition = 'CenterParent' >> "%PS_SCRIPT%"
echo     $ftpForm.FormBorderStyle = 'FixedDialog' >> "%PS_SCRIPT%"
echo     $ftpForm.MaximizeBox = $false; $ftpForm.MinimizeBox = $false >> "%PS_SCRIPT%"
echo     if ($global:isDark) { $ftpForm.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42); $ftpForm.ForeColor = [System.Drawing.Color]::White; $tBg=[System.Drawing.Color]::FromArgb(30, 41, 59); $tFg=[System.Drawing.Color]::White } else { $ftpForm.BackColor = [System.Drawing.Color]::FromArgb(248, 250, 252); $ftpForm.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42); $tBg=[System.Drawing.Color]::White; $tFg=[System.Drawing.Color]::Black } >> "%PS_SCRIPT%"
echo     $lbl1 = New-Object System.Windows.Forms.Label; $lbl1.Text = 'Enter FTP Port from your mobile app:'; $lbl1.Location = New-Object System.Drawing.Point(20,20); $lbl1.AutoSize = $true; $lbl1.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo     $lblIp = New-Object System.Windows.Forms.Label; $lblIp.Text = "ftp://${ip} :"; $lblIp.Location = New-Object System.Drawing.Point(20,55); $lblIp.AutoSize = $true; $lblIp.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold) >> "%PS_SCRIPT%"
echo     $txtP = New-Object System.Windows.Forms.TextBox; $txtP.Text = '2221'; $txtP.Location = New-Object System.Drawing.Point(215,53); $txtP.Width = 90; $txtP.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $txtP.BackColor = $tBg; $txtP.ForeColor = $tFg; $txtP.BorderStyle = 'FixedSingle'; $txtP.TextAlign = 'Center' >> "%PS_SCRIPT%"
echo     $btnGo = New-Object System.Windows.Forms.Button; $btnGo.Text = 'Connect Now'; $btnGo.Location = New-Object System.Drawing.Point(20,100); $btnGo.Size = New-Object System.Drawing.Size(301, 45); $btnGo.BackColor = [System.Drawing.Color]::FromArgb(139, 92, 246); $btnGo.ForeColor = [System.Drawing.Color]::White; $btnGo.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold); $btnGo.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo     Make-Rounded $btnGo 301 45 16 >> "%PS_SCRIPT%"
echo     $btnGo.Add_Click({ $global:ftp_port_result = $txtP.Text; $ftpForm.Close() }) >> "%PS_SCRIPT%"
echo     $ftpForm.Controls.AddRange(@($lbl1, $lblIp, $txtP, $btnGo)) >> "%PS_SCRIPT%"
echo     $global:ftp_port_result = $null >> "%PS_SCRIPT%"
echo     $ftpForm.ShowDialog() ^| Out-Null >> "%PS_SCRIPT%"
echo     if (-not [string]::IsNullOrEmpty($global:ftp_port_result)) { Start-Process explorer "ftp://${ip}:$($global:ftp_port_result)" } >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"

echo $btnHelp = New-Object System.Windows.Forms.Button; $btnHelp.Text = 'How to Connect? (Setup Guide)'; $btnHelp.Location = New-Object System.Drawing.Point(20,500); $btnHelp.Width = 301; $btnHelp.Height = 40; $btnHelp.BackColor = [System.Drawing.Color]::FromArgb(245, 158, 11); $btnHelp.ForeColor = [System.Drawing.Color]::Black; $btnHelp.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold); $btnHelp.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo Make-Rounded $btnHelp 301 40 16 >> "%PS_SCRIPT%"
echo $btnHelp.Add_MouseEnter({ $btnHelp.BackColor = [System.Drawing.Color]::FromArgb(252, 211, 77) }) >> "%PS_SCRIPT%"
echo $btnHelp.Add_MouseLeave({ $btnHelp.BackColor = [System.Drawing.Color]::FromArgb(245, 158, 11) }) >> "%PS_SCRIPT%"
echo $btnHelp.Add_Click({ Start-Process 'help.html' }) >> "%PS_SCRIPT%"

echo $f.Controls.AddRange(@($b,$btnFtp,$btnHelp)) >> "%PS_SCRIPT%"

:: =========================================
:: Live Theme & Auto-Save Engine
:: =========================================
echo function Save-Settings { >> "%PS_SCRIPT%"
echo     $q = if ($cbQ.SelectedItem) { $cbQ.SelectedItem.ToString().Substring(0,1) } else { '2' } >> "%PS_SCRIPT%"
echo     $a = if ($cbA.SelectedItem -eq 'Yes') { 'y' } else { 'n' } >> "%PS_SCRIPT%"
echo     $th = if ($global:isDark) { 'Dark' } else { 'Light' } >> "%PS_SCRIPT%"
echo     $ipStr = "$($t_o1.Text).$($t_o2.Text).$($t_o3.Text).$($t_o4.Text):$($t_p.Text)" >> "%PS_SCRIPT%"
echo     "$ipStr,$q,$a,$th" ^| Out-File -FilePath $global:savePath -Encoding ascii >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo function Apply-Theme { >> "%PS_SCRIPT%"
echo     if ($global:isDark) { >> "%PS_SCRIPT%"
echo         $bg = [System.Drawing.Color]::FromArgb(15, 23, 42); $fg = [System.Drawing.Color]::White; $fgS = [System.Drawing.Color]::FromArgb(148, 163, 184); $tbg = [System.Drawing.Color]::FromArgb(30, 41, 59); $tfg = [System.Drawing.Color]::White >> "%PS_SCRIPT%"
echo         $btnTheme.Text = 'Light Mode'; $btnTheme.BackColor = [System.Drawing.Color]::FromArgb(71, 85, 105); $btnTheme.ForeColor = [System.Drawing.Color]::White >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         $bg = [System.Drawing.Color]::FromArgb(248, 250, 252); $fg = [System.Drawing.Color]::FromArgb(15, 23, 42); $fgS = [System.Drawing.Color]::FromArgb(71, 85, 105); $tbg = [System.Drawing.Color]::White; $tfg = [System.Drawing.Color]::Black >> "%PS_SCRIPT%"
echo         $btnTheme.Text = 'Dark Mode'; $btnTheme.BackColor = [System.Drawing.Color]::FromArgb(203, 213, 225); $btnTheme.ForeColor = [System.Drawing.Color]::FromArgb(15, 23, 42) >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo     $f.BackColor = $bg; $lblUsbSec.ForeColor = $fg; $lblWifiSec.ForeColor = $fg >> "%PS_SCRIPT%"
echo     $l1.ForeColor = $fgS; $l1_sub.ForeColor = $fgS; $lblQ.ForeColor = $fgS; $lblA.ForeColor = $fgS >> "%PS_SCRIPT%"
echo     $d1.ForeColor = $fg; $d2.ForeColor = $fg; $d3.ForeColor = $fg; $colon.ForeColor = $fg >> "%PS_SCRIPT%"
echo     $ctrls = @($t_o1,$t_o2,$t_o3,$t_o4,$t_p,$cbQ,$cbA) >> "%PS_SCRIPT%"
echo     foreach ($c in $ctrls) { $c.BackColor = $tbg; $c.ForeColor = $tfg } >> "%PS_SCRIPT%"
::       [FIXED] USB Button Light Mode Fix
echo     if (-not $bUsb.Enabled) { >> "%PS_SCRIPT%"
echo         if ($global:isDark) { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(71, 85, 105); $bUsb.ForeColor = [System.Drawing.Color]::White } >> "%PS_SCRIPT%"
echo         else { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(226, 232, 240); $bUsb.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139) } >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

echo Apply-Theme >> "%PS_SCRIPT%"
echo $btnTheme.Add_Click({ $global:isDark = -not $global:isDark; Apply-Theme; Save-Settings }) >> "%PS_SCRIPT%"
echo $f.Add_FormClosing({ Save-Settings }) >> "%PS_SCRIPT%"

:: =========================================
:: Live USB Detection
:: =========================================
echo $global:device_setup_done = $false >> "%PS_SCRIPT%"
echo $global:disconnect_time = $null >> "%PS_SCRIPT%"
echo $timer = New-Object System.Windows.Forms.Timer >> "%PS_SCRIPT%"
echo $timer.Interval = 1000 >> "%PS_SCRIPT%"
echo $timer.Add_Tick({ >> "%PS_SCRIPT%"
echo     $adb_state = (adb -d get-state 2^>^&1) -join ' ' >> "%PS_SCRIPT%"
echo     if ($adb_state -match 'device' -and $adb_state -notmatch 'error') { >> "%PS_SCRIPT%"
echo         $global:disconnect_time = $null >> "%PS_SCRIPT%"
echo         $lblStatus1.Text = 'USB Detected' >> "%PS_SCRIPT%"
echo         $lblStatus1.ForeColor = [System.Drawing.Color]::FromArgb(34, 197, 94) >> "%PS_SCRIPT%"
echo         $lblStatus2.Text = 'USB Debugging ON (Ready)' >> "%PS_SCRIPT%"
echo         $lblStatus2.ForeColor = [System.Drawing.Color]::FromArgb(34, 197, 94) >> "%PS_SCRIPT%"
echo         $bUsb.Enabled = $true >> "%PS_SCRIPT%"
echo         $bUsb.BackColor = [System.Drawing.Color]::FromArgb(16, 185, 129); $bUsb.ForeColor = [System.Drawing.Color]::White >> "%PS_SCRIPT%"
echo         $bUsb.Cursor = [System.Windows.Forms.Cursors]::Hand >> "%PS_SCRIPT%"
echo         if (-not $global:device_setup_done) { >> "%PS_SCRIPT%"
echo             $global:device_setup_done = $true >> "%PS_SCRIPT%"
echo             $ip_out = (adb -d shell ip addr show wlan0 2^>^&1) -join ' ' >> "%PS_SCRIPT%"
echo             if ($ip_out -match 'inet\s+(\d+)\.(\d+)\.(\d+)\.(\d+)') { >> "%PS_SCRIPT%"
echo                 $t_o1.Text = $matches[1]; $t_o2.Text = $matches[2]; $t_o3.Text = $matches[3]; $t_o4.Text = $matches[4] >> "%PS_SCRIPT%"
echo             } else { >> "%PS_SCRIPT%"
echo                 $route = (adb -d shell ip route 2^>^&1) -join ' ' >> "%PS_SCRIPT%"
echo                 if ($route -match 'src\s+(192)\.(168)\.(\d+)\.(\d+)') { >> "%PS_SCRIPT%"
echo                     $t_o1.Text = $matches[1]; $t_o2.Text = $matches[2]; $t_o3.Text = $matches[3]; $t_o4.Text = $matches[4] >> "%PS_SCRIPT%"
echo                 } >> "%PS_SCRIPT%"
echo             } >> "%PS_SCRIPT%"
echo             $port = Get-Random -Minimum 30000 -Maximum 50000 >> "%PS_SCRIPT%"
echo             $t_p.Text = $port.ToString() >> "%PS_SCRIPT%"
echo             Start-Process -NoNewWindow -FilePath 'adb.exe' -ArgumentList "-d tcpip $port" >> "%PS_SCRIPT%"
echo             Save-Settings >> "%PS_SCRIPT%"
echo         } >> "%PS_SCRIPT%"
echo     } elseif ($adb_state -match 'unauthorized' -or $adb_state -match 'offline') { >> "%PS_SCRIPT%"
echo         $lblStatus1.Text = 'USB Detected' >> "%PS_SCRIPT%"
echo         $lblStatus1.ForeColor = [System.Drawing.Color]::FromArgb(34, 197, 94) >> "%PS_SCRIPT%"
echo         $lblStatus2.Text = 'USB Debugging OFF / Allow Prompt' >> "%PS_SCRIPT%"
echo         $lblStatus2.ForeColor = [System.Drawing.Color]::FromArgb(244, 63, 94) >> "%PS_SCRIPT%"
echo         $bUsb.Enabled = $false >> "%PS_SCRIPT%"
echo         if ($global:isDark) { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(71, 85, 105); $bUsb.ForeColor = [System.Drawing.Color]::White } else { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(226, 232, 240); $bUsb.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139) } >> "%PS_SCRIPT%"
echo     } else { >> "%PS_SCRIPT%"
echo         if ($global:device_setup_done) { >> "%PS_SCRIPT%"
echo             if ($null -eq $global:disconnect_time) { $global:disconnect_time = Get-Date } >> "%PS_SCRIPT%"
echo             elseif (((Get-Date) - $global:disconnect_time).TotalSeconds -gt 5) { $global:device_setup_done = $false; $global:disconnect_time = $null } >> "%PS_SCRIPT%"
echo         } >> "%PS_SCRIPT%"
echo         $wmi = Get-CimInstance Win32_PnPEntity -Filter "PNPClass='WPD' OR PNPClass='AndroidUsbDeviceClass'" -ErrorAction SilentlyContinue >> "%PS_SCRIPT%"
echo         if ($wmi) { >> "%PS_SCRIPT%"
echo             $lblStatus1.Text = 'USB Detected' >> "%PS_SCRIPT%"
echo             $lblStatus1.ForeColor = [System.Drawing.Color]::FromArgb(34, 197, 94) >> "%PS_SCRIPT%"
echo             $lblStatus2.Text = 'USB Debugging OFF' >> "%PS_SCRIPT%"
echo             $lblStatus2.ForeColor = [System.Drawing.Color]::FromArgb(244, 63, 94) >> "%PS_SCRIPT%"
echo             $bUsb.Enabled = $false >> "%PS_SCRIPT%"
echo             if ($global:isDark) { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(71, 85, 105); $bUsb.ForeColor = [System.Drawing.Color]::White } else { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(226, 232, 240); $bUsb.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139) } >> "%PS_SCRIPT%"
echo         } else { >> "%PS_SCRIPT%"
echo             $lblStatus1.Text = 'USB Not Detected' >> "%PS_SCRIPT%"
echo             $lblStatus1.ForeColor = [System.Drawing.Color]::FromArgb(244, 63, 94) >> "%PS_SCRIPT%"
echo             $lblStatus2.Text = '' >> "%PS_SCRIPT%"
echo             $bUsb.Enabled = $false >> "%PS_SCRIPT%"
echo             if ($global:isDark) { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(71, 85, 105); $bUsb.ForeColor = [System.Drawing.Color]::White } else { $bUsb.BackColor = [System.Drawing.Color]::FromArgb(226, 232, 240); $bUsb.ForeColor = [System.Drawing.Color]::FromArgb(100, 116, 139) } >> "%PS_SCRIPT%"
echo         } >> "%PS_SCRIPT%"
echo     } >> "%PS_SCRIPT%"
echo }) >> "%PS_SCRIPT%"
echo $timer.Start() >> "%PS_SCRIPT%"

echo $f.ShowDialog() ^| Out-Null >> "%PS_SCRIPT%"
echo if ($global:res) { Write-Output $global:res } >> "%PS_SCRIPT%"

set "ACTION="
set "PHONE_IP="
set "PHONE_PORT="
set "RAW_QUAL="
set "RAW_AWAKE="

for /f "tokens=1,2,3,4,5 delims=," %%a in ('powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"') do (
    set "ACTION=%%a"
    set "PHONE_IP=%%b"
    set "PHONE_PORT=%%c"
    set "RAW_QUAL=%%d"
    set "RAW_AWAKE=%%e"
)
del "%PS_SCRIPT%"

if "!ACTION!"=="" exit

set "QUAL=!RAW_QUAL:~0,1!"
if /i "!RAW_AWAKE!"=="Yes" (set "AWAKE=y") else (set "AWAKE=n")

:: =========================================
:: Screen Mirroring Logic
:: =========================================
echo Preparing Connection...

set PARAM=--video-bit-rate=4M --max-size=1024 --audio-buffer=200
if "!QUAL!"=="1" set PARAM=--video-bit-rate=8M --max-size=1280 --audio-buffer=100
if "!QUAL!"=="2" set PARAM=--video-bit-rate=4M --max-size=1024 --audio-buffer=200
if "!QUAL!"=="3" set PARAM=--video-bit-rate=2M --max-size=720 --audio-buffer=300
if "!QUAL!"=="4" set PARAM=--video-bit-rate=1M --max-size=640 --audio-buffer=500

if "!ACTION!"=="USB" (
    echo Connecting via USB...
    set EXTRA_OPTS=--turn-screen-off --window-title "Mobile Link (USB)" --power-off-on-close --always-on-top
    if /i "!AWAKE!"=="y" set EXTRA_OPTS=!EXTRA_OPTS! --stay-awake
    scrcpy -d !PARAM! !EXTRA_OPTS!
) else if "!ACTION!"=="WIFI" (
    echo Connecting Wirelessly to !PHONE_IP!:!PHONE_PORT!...
    set EXTRA_OPTS=--turn-screen-off --window-title "Mobile Link (Wireless)" --power-off-on-close --always-on-top
    if /i "!AWAKE!"=="y" set EXTRA_OPTS=!EXTRA_OPTS! --stay-awake
    adb connect !PHONE_IP!:!PHONE_PORT!
    scrcpy -s !PHONE_IP!:!PHONE_PORT! !PARAM! !EXTRA_OPTS!
)

echo.
echo =========================================
echo Process finished or connection failed!
echo =========================================
pause
goto MainMenu