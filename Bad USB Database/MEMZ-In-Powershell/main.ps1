<# ================================================ POWERSHELL MEMZ PRANK ========================================================

SYNOPSIS
This script plays random windows default sounds and various screen effects until it is closed (in task manager)

USAGE
Run the script
stop in task manager (when console is hidden)

#>

# Hide the powershell console
$hide = 1
if ($hide -eq 1){
    $Async = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $Type = Add-Type -MemberDefinition $Async -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
    $hwnd = (Get-Process -PID $pid).MainWindowHandle
    
    if ($hwnd -ne [System.IntPtr]::Zero) {
        $Type::ShowWindowAsync($hwnd, 0)
    }
    else {
        $Host.UI.RawUI.WindowTitle = 'hideme'
        $Proc = (Get-Process | Where-Object { $_.MainWindowTitle -eq 'hideme' })
        $hwnd = $Proc.MainWindowHandle
        $Type::ShowWindowAsync($hwnd, 0)
    }
}

# Turn off screen for short period
$joboff = {

Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class Screen {[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, uint Msg, int wParam, int lParam);public static void TurnOff() {SendMessage(0xFFFF, 0x0112, 0xF170, 2);}}'
[Screen]::TurnOff()

}

# Balloon popup
$job0 = {

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = [System.Drawing.SystemIcons]::Warning
$notify.Visible = $true
$balloonTipTitle = "System Error (0x00060066e)"
$balloonTipText = "WARNING! - System Breach Detected"
$notify.ShowBalloonTip(30000, $balloonTipTitle, $balloonTipText, [System.Windows.Forms.ToolTipIcon]::WARNING)

}

# Mouse error icon
$job1 = {

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms


$desktopHandle = [System.IntPtr]::Zero
$graphics = [System.Drawing.Graphics]::FromHwnd($desktopHandle)
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\DFDWiz.exe")

function Get-MousePosition {
    $point = [System.Windows.Forms.Cursor]::Position
    return $point
}

while ($true) {

    $mousePosition = Get-MousePosition
    $graphics.DrawIcon($icon, $mousePosition.X, $mousePosition.Y)
    Start-Sleep -Milliseconds 50
}

$graphics.Clear([System.Drawing.Color]::Transparent)
$graphics.Dispose()
$icon.Dispose()

}

# Screen Glitches
$job2 = {

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


$Filett = "$env:temp\SC.png"
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$Width = $Screen.Width
$Height = $Screen.Height
$Left = $Screen.Left
$Top = $Screen.Top
$bitmap = New-Object System.Drawing.Bitmap $Width, $Height
$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
$graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
$bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
$savedImage = [System.Drawing.Image]::FromFile($Filett)

$desktopHandle = [System.IntPtr]::Zero
$graphics = [System.Drawing.Graphics]::FromHwnd($desktopHandle)

$random = New-Object System.Random

function Get-RandomSize {
    return $random.Next(100, 500)
}

function Get-RandomPosition {
    param (
        [int]$rectWidth,
        [int]$rectHeight
    )
    $x = $random.Next(0, $Width - $rectWidth)
    $y = $random.Next(0, $Height - $rectHeight)
    return [PSCustomObject]@{X = $x; Y = $y}
}

while ($true) {

    $rectWidth = Get-RandomSize
    $rectHeight = Get-RandomSize

    $srcX = $random.Next(0, $savedImage.Width - $rectWidth)
    $srcY = $random.Next(0, $savedImage.Height - $rectHeight)

    $destPosition = Get-RandomPosition -rectWidth $rectWidth -rectHeight $rectHeight

    $srcRect = New-Object System.Drawing.Rectangle $srcX, $srcY, $rectWidth, $rectHeight
    $destRect = New-Object System.Drawing.Rectangle $destPosition.X, $destPosition.Y, $rectWidth, $rectHeight

    $graphics.DrawImage($savedImage, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

    Start-Sleep -Milliseconds 100
}

$savedImage.Dispose()
$graphics.Dispose()
$bitmap.Dispose()
$graphic.Dispose()
}

# Circular spinning colors
$job3 = {

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$Width = $screen.Bounds.Width
$Height = $screen.Bounds.Height
$X = [math]::Round($Width / 2)
$Y = [math]::Round($Height / 2)

$desktopHandle = [System.IntPtr]::Zero
$graphics = [System.Drawing.Graphics]::FromHwnd($desktopHandle)

function Get-RandomColor {
    $random = New-Object System.Random
    $r = $random.Next(0, 256)
    $g = $random.Next(0, 256)
    $b = $random.Next(0, 256)
    return [System.Drawing.Color]::FromArgb($r, $g, $b)
}

$angle = 0
$length = 10

while ($true) {
    $pen = New-Object System.Drawing.Pen((Get-RandomColor), 20)

    $endX1 = $X + [math]::Round($length * [math]::Cos([math]::PI * $angle / 180))
    $endY1 = $Y + [math]::Round($length * [math]::Sin([math]::PI * $angle / 180))

    $oppositeAngle = $angle + 180
    $endX2 = $X + [math]::Round($length * [math]::Cos([math]::PI * $oppositeAngle / 180))
    $endY2 = $Y + [math]::Round($length * [math]::Sin([math]::PI * $oppositeAngle / 180))

    $graphics.DrawLine($pen, $X, $Y, $endX1, $endY1)
    $graphics.DrawLine($pen, $X, $Y, $endX2, $endY2)

    $random = New-Object System.Random
    $angle += $random.Next(1, 90)
    $length++

    Start-Sleep -Milliseconds 10
    
    if ($angle -ge 360) {
        $angle = 0
    }

    if ($length -ge $height) {
        $length = 10
    }
}

$pen.Dispose()
$graphics.Dispose()

}

# Play random sounds
$job4 = {

while($true){
    $Interval = 1
    Get-ChildItem C:\Windows\Media\ -File -Filter *.wav | Select-Object -ExpandProperty Name | Foreach-Object { 
        Start-Sleep -Seconds $Interval
        (New-Object Media.SoundPlayer "C:\WINDOWS\Media\$_").Play()
    }
}

}

# Display text
$job5 = {

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$Width = $screen.Bounds.Width
$Height = $screen.Bounds.Height
$desktopHandle = [System.IntPtr]::Zero
$graphics = [System.Drawing.Graphics]::FromHwnd($desktopHandle)
$random = New-Object System.Random
function Get-RandomFontSize {
    return $random.Next(20, 101)
}
function Get-RandomPosition {
    param (
        [int]$textWidth,
        [int]$textHeight
    )
    $x = $random.Next(0, $Width - $textWidth)
    $y = $random.Next(0, $Height - $textHeight)
    return [PSCustomObject]@{X = $x; Y = $y}
}
$text = "SYSTEM FAIL!"
$textColor = [System.Drawing.Color]::Red
while ($true) {

    $fontSize = Get-RandomFontSize
    $font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold)
    $textSize = $graphics.MeasureString($text, $font)
    $textWidth = [math]::Ceiling($textSize.Width)
    $textHeight = [math]::Ceiling($textSize.Height)
    $position = Get-RandomPosition -textWidth $textWidth -textHeight $textHeight
    $graphics.DrawString($text, $font, (New-Object System.Drawing.SolidBrush($textColor)), $position.X, $position.Y)
    $font.Dispose()
    Start-Sleep -Milliseconds 500

}

}

# Negative Screen Glitches
$job6 = {

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$Filett = "$env:temp\SC.png"
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$Width = $Screen.Width
$Height = $Screen.Height
$Left = $Screen.Left
$Top = $Screen.Top
$bitmap = New-Object System.Drawing.Bitmap $Width, $Height
$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
$graphic.CopyFromScreen($Left, $Top, 0, 0, $bitmap.Size)
$bitmap.Save($Filett, [System.Drawing.Imaging.ImageFormat]::png)
$savedImage = [System.Drawing.Image]::FromFile($Filett)
$desktopHandle = [System.IntPtr]::Zero
$graphics = [System.Drawing.Graphics]::FromHwnd($desktopHandle)
$random = New-Object System.Random
function Get-RandomSize {
    return $random.Next(100, 500)
}
function Get-RandomPosition {
    param (
        [int]$rectWidth,
        [int]$rectHeight
    )
    $x = $random.Next(0, $Width - $rectWidth)
    $y = $random.Next(0, $Height - $rectHeight)
    return [PSCustomObject]@{X = $x; Y = $y}
}
function Invert-Colors {
    param (
        [System.Drawing.Bitmap]$bitmap,
        [System.Drawing.Rectangle]$rect
    )
    for ($x = $rect.X; $x -lt $rect.X + $rect.Width; $x++) {
        for ($y = $rect.Y; $y -lt $rect.Y + $rect.Height; $y++) {
            $pixelColor = $bitmap.GetPixel($x, $y)
            $invertedColor = [System.Drawing.Color]::FromArgb(255, 255 - $pixelColor.R, 255 - $pixelColor.G, 255 - $pixelColor.B)
            $bitmap.SetPixel($x, $y, $invertedColor)
        }
    }
}
while ($true) {

    $rectWidth = Get-RandomSize
    $rectHeight = Get-RandomSize
    $srcX = $random.Next(0, $savedImage.Width - $rectWidth)
    $srcY = $random.Next(0, $savedImage.Height - $rectHeight)
    $destPosition = Get-RandomPosition -rectWidth $rectWidth -rectHeight $rectHeight
    $srcRect = New-Object System.Drawing.Rectangle $srcX, $srcY, $rectWidth, $rectHeight
    $destRect = New-Object System.Drawing.Rectangle $destPosition.X, $destPosition.Y, $rectWidth, $rectHeight
    $srcBitmap = $savedImage.Clone($srcRect, $savedImage.PixelFormat)
    Invert-Colors -bitmap $srcBitmap -rect (New-Object System.Drawing.Rectangle 0, 0, $rectWidth, $rectHeight)
    $graphics.DrawImage($srcBitmap, $destRect)
    $srcBitmap.Dispose()
    Start-Sleep -Milliseconds 100
}

}

# Start all jobs
Start-Job -ScriptBlock $job0
sleep 5
Start-Job -ScriptBlock $joboff
sleep 5
Start-Job -ScriptBlock $job1
sleep 10
Start-Job -ScriptBlock $job4
Start-Job -ScriptBlock $job2
sleep 5
Start-Job -ScriptBlock $job3
sleep 5 
Start-Job -ScriptBlock $job5
sleep 5
Start-Job -ScriptBlock $job6

# keep script alive
pause
