# Generates assets/keys.png, the keyboard map embedded in the README.
# Windows PowerShell 5.1+ with System.Drawing. Deterministic text rendering,
# so every label is exact and can be edited without an image generator.
# Run: powershell -ExecutionPolicy Bypass -File assets/keys.ps1

Add-Type -AssemblyName System.Drawing

$W = 1920; $H = 1080
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

function C([string]$hex) { return [System.Drawing.ColorTranslator]::FromHtml($hex) }

$minus  = [string][char]0x2212
$times  = [string][char]0x00D7
$endash = [string][char]0x2013
$nln    = [string][char]10
$dot    = [string][char]0x00B7
$arrUp  = [string][char]0x2191
$arrDn  = [string][char]0x2193
$arrLf  = [string][char]0x2190
$arrRt  = [string][char]0x2192

$amber      = C '#FCBE11'
$amberSoft  = C '#FFD86B'
$amberDim   = C '#C99A26'
$warmWhite  = C '#F2E8CE'
$white      = C '#E6E6E9'
$greyText   = C '#6B6B72'
$bgTop      = C '#0B0B0C'
$bgBottom   = C '#161310'
$dimFillA   = C '#1B1B1E'
$dimFillB   = C '#121215'
$dimBorder  = C '#2D2D33'
$actFillA   = C '#2B230A'
$actFillB   = C '#171204'

$fKey    = New-Object System.Drawing.Font('Bahnschrift', 8.5, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fLabel  = New-Object System.Drawing.Font('Bahnschrift SemiBold SemiConden', 10, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fLabelL = New-Object System.Drawing.Font('Bahnschrift SemiBold SemiConden', 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fDigit  = New-Object System.Drawing.Font('Bahnschrift SemiBold', 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fArrow  = New-Object System.Drawing.Font('Segoe UI Symbol', 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fArrowL = New-Object System.Drawing.Font('Bahnschrift SemiBold SemiConden', 11, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fTitle  = New-Object System.Drawing.Font('Bahnschrift SemiBold Condensed', 46, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fSub    = New-Object System.Drawing.Font('Bahnschrift Condensed', 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fSmall  = New-Object System.Drawing.Font('Bahnschrift Condensed', 14, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fTiny   = New-Object System.Drawing.Font('Bahnschrift', 9, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$fCombo  = New-Object System.Drawing.Font('Bahnschrift SemiBold SemiConden', 13, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)

function RoundRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

$sfCenter = New-Object System.Drawing.StringFormat
$sfCenter.Alignment = [System.Drawing.StringAlignment]::Center
$sfCenter.LineAlignment = [System.Drawing.StringAlignment]::Center
$sfNear = New-Object System.Drawing.StringFormat
$sfNear.Alignment = [System.Drawing.StringAlignment]::Near
$sfNear.LineAlignment = [System.Drawing.StringAlignment]::Center

function DrawKey {
    param(
        [float]$x, [float]$y, [float]$w, [float]$h,
        [string]$name, [string]$label, [bool]$active,
        [string]$style = 'normal'
    )

    $path = RoundRect $x $y $w $h 7

    if ($active) {
        for ($i = 3; $i -ge 1; $i--) {
            $gp = RoundRect ($x - $i * 2.5) ($y - $i * 2.5) ($w + $i * 5) ($h + $i * 5) (7 + $i * 2.5)
            $gb = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(8, 252, 190, 17))
            $g.FillPath($gb, $gp)
            $gb.Dispose(); $gp.Dispose()
        }
        $fill = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            (New-Object System.Drawing.PointF($x, $y)),
            (New-Object System.Drawing.PointF($x, ($y + $h))),
            $actFillA, $actFillB)
        $border = New-Object System.Drawing.Pen($amber, 1.5)
    } else {
        $fill = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            (New-Object System.Drawing.PointF($x, $y)),
            (New-Object System.Drawing.PointF($x, ($y + $h))),
            $dimFillA, $dimFillB)
        $border = New-Object System.Drawing.Pen($dimBorder, 1)
    }

    $g.FillPath($fill, $path)
    $g.DrawPath($border, $path)
    $fill.Dispose(); $border.Dispose(); $path.Dispose()

    $nameColor = if ($active) { $amberDim } else { $greyText }
    $labelColor = if ($active) { $warmWhite } else { $greyText }

    if ($null -ne $name -and $name -ne '') {
        $nr = New-Object System.Drawing.RectangleF(($x + 7), ($y + 4), ($w - 14), 16)
        $g.DrawString($name, $fKey, (New-Object System.Drawing.SolidBrush($nameColor)), $nr, $sfNear)
    }

    if ($null -ne $label -and $label -ne '') {
        if ($style -eq 'digit') {
            $lr = New-Object System.Drawing.RectangleF($x, ($y + 2), $w, ($h - 6))
            $g.DrawString($label, $fDigit, (New-Object System.Drawing.SolidBrush($labelColor)), $lr, $sfCenter)
        } elseif ($style -eq 'arrow') {
            $lr = New-Object System.Drawing.RectangleF($x, ($y + 6), $w, 34)
            $g.DrawString($name, $fArrow, (New-Object System.Drawing.SolidBrush($labelColor)), $lr, $sfCenter)
            $tr = New-Object System.Drawing.RectangleF($x, ($y + 40), $w, 22)
            $g.DrawString($label, $fArrowL, (New-Object System.Drawing.SolidBrush($labelColor)), $tr, $sfCenter)
        } else {
            $size = if ($style -eq 'big') { $fLabelL } else { $fLabel }
            $lr = New-Object System.Drawing.RectangleF(($x + 3), ($y + 17), ($w - 6), ($h - 20))
            $g.DrawString($label, $size, (New-Object System.Drawing.SolidBrush($labelColor)), $lr, $sfCenter)
        }
    }
}

# ---------- background ----------
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(0, 0)),
    (New-Object System.Drawing.Point(0, $H)),
    $bgTop, $bgBottom)
$g.FillRectangle($bgBrush, 0, 0, $W, $H)

$gridPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(9, 255, 216, 107)), 1
for ($x = 0; $x -lt $W; $x += 64) { $g.DrawLine($gridPen, $x, 0, $x, $H) }
for ($y = 0; $y -lt $H; $y += 64) { $g.DrawLine($gridPen, 0, $y, $W, $y) }

# soft amber glow behind the keyboard
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(260, 200, 1400, 620)
$pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$pgb.CenterColor = [System.Drawing.Color]::FromArgb(26, 252, 190, 17)
$pgb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 252, 190, 17))
$g.FillPath($pgb, $glowPath)

# HUD frame
$framePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(40, 252, 190, 17)), 1
$g.DrawRectangle($framePen, 26, 26, $W - 52, $H - 52)

# ---------- header ----------
$g.DrawString('MPV KEYS', $fTitle, (New-Object System.Drawing.SolidBrush($amber)), 138, 62)
$g.DrawString("personal mpv config  ${dot}  keyboard map", $fSub, (New-Object System.Drawing.SolidBrush($greyText)), 144, 136)
$g.DrawString('v1.2.0', $fTiny, (New-Object System.Drawing.SolidBrush($greyText)), 1770, 92)

$rulePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(70, 252, 190, 17)), 1
$g.DrawLine($rulePen, 140, 178, 1782, 178)

# ---------- geometry ----------
$KW = 74; $KH = 70; $GAP = 7; $U = $KW + $GAP
$X0 = 140
$yF = 252
$y1 = $yF + $U
$y2 = $y1 + $U
$y3 = $y2 + $U
$y4 = $y3 + $U
$y5 = $y4 + $U

function X([double]$n) { return $X0 + $n * $U }

# ---------- function row ----------
DrawKey (X 0) $yF $KW $KH 'ESC' 'QUIT' $true 'big'
for ($i = 1; $i -le 12; $i++) {
    $keyName = "F$i"
    if ($i -eq 10) {
        DrawKey (X $i) $yF $KW $KH $keyName 'SHOT (ALT)' $true 'normal'
    } else {
        DrawKey (X $i) $yF $KW $KH $keyName '' $false 'normal'
    }
}
DrawKey (X 14) $yF $KW $KH 'PRINT' 'SHOT' $true 'normal'
DrawKey (X 15) $yF $KW $KH 'SCROLL' '' $false 'normal'
DrawKey (X 16) $yF $KW $KH 'PAUSE' '' $false 'normal'

# ---------- number row ----------
DrawKey (X 0) $y1 $KW $KH '`' '' $false 'normal'
DrawKey (X 1) $y1 $KW $KH '1' 'OFF' $true 'normal'
DrawKey (X 2) $y1 $KW $KH '2' 'SOFT' $true 'normal'
DrawKey (X 3) $y1 $KW $KH '3' 'BALANCED' $true 'normal'
DrawKey (X 4) $y1 $KW $KH '4' 'NIGHT' $true 'normal'
DrawKey (X 5) $y1 $KW $KH '5' '' $false 'normal'
DrawKey (X 6) $y1 $KW $KH '6' '' $false 'normal'
DrawKey (X 7) $y1 $KW $KH '7' '' $false 'normal'
DrawKey (X 8) $y1 $KW $KH '8' '' $false 'normal'
DrawKey (X 9) $y1 $KW $KH '9' '' $false 'normal'
DrawKey (X 10) $y1 $KW $KH '0' '' $false 'normal'
DrawKey (X 11) $y1 $KW $KH '-' '' $false 'normal'
DrawKey (X 12) $y1 $KW $KH '=' '' $false 'normal'
DrawKey (X 13) $y1 (2 * $U - $GAP) $KH 'BACKSPACE' "SPEED 1${times}" $true 'normal'

# ---------- tab row ----------
DrawKey (X 0) $y2 (1.5 * $U - $GAP) $KH 'TAB' '' $false 'normal'
DrawKey (X 1.5) $y2 $KW $KH 'Q' 'SUBS UP' $true 'normal'
DrawKey (X 2.5) $y2 $KW $KH 'W' 'SUBS DOWN' $true 'normal'
DrawKey (X 3.5) $y2 $KW $KH 'E' '' $false 'normal'
DrawKey (X 4.5) $y2 $KW $KH 'R' '' $false 'normal'
DrawKey (X 5.5) $y2 $KW $KH 'T' '' $false 'normal'
DrawKey (X 6.5) $y2 $KW $KH 'Y' '' $false 'normal'
DrawKey (X 7.5) $y2 $KW $KH 'U' '' $false 'normal'
DrawKey (X 8.5) $y2 $KW $KH 'I' '' $false 'normal'
DrawKey (X 9.5) $y2 $KW $KH 'O' '' $false 'normal'
DrawKey (X 10.5) $y2 $KW $KH 'P' '' $false 'normal'
DrawKey (X 11.5) $y2 $KW $KH '[' 'SLOWER' $true 'normal'
DrawKey (X 12.5) $y2 $KW $KH ']' 'FASTER' $true 'normal'
DrawKey (X 13.5) $y2 (1.5 * $U - $GAP) $KH '\' '' $false 'normal'

# ---------- caps row ----------
DrawKey (X 0) $y3 (1.75 * $U - $GAP) $KH 'CAPS' '' $false 'normal'
DrawKey (X 1.75) $y3 $KW $KH 'A' "DELAY ${minus}" $true 'normal'
DrawKey (X 2.75) $y3 $KW $KH 'S' 'DELAY +' $true 'normal'
DrawKey (X 3.75) $y3 $KW $KH 'D' '' $false 'normal'
DrawKey (X 4.75) $y3 $KW $KH 'F' '' $false 'normal'
DrawKey (X 5.75) $y3 $KW $KH 'G' '' $false 'normal'
DrawKey (X 6.75) $y3 $KW $KH 'H' '' $false 'normal'
DrawKey (X 7.75) $y3 $KW $KH 'J' '' $false 'normal'
DrawKey (X 8.75) $y3 $KW $KH 'K' '' $false 'normal'
DrawKey (X 9.75) $y3 $KW $KH 'L' '' $false 'normal'
DrawKey (X 10.75) $y3 $KW $KH ';' '' $false 'normal'
DrawKey (X 11.75) $y3 $KW $KH "'" '' $false 'normal'
DrawKey (X 12.75) $y3 (2.25 * $U - $GAP) $KH 'ENTER' '' $false 'normal'

# ---------- shift row ----------
DrawKey (X 0) $y4 (2.25 * $U - $GAP) $KH 'SHIFT' "SHIFT + Z${nln}ZOOM OUT" $true 'normal'
DrawKey (X 2.25) $y4 $KW $KH 'Z' 'ZOOM IN' $true 'normal'
DrawKey (X 3.25) $y4 $KW $KH 'X' '' $false 'normal'
DrawKey (X 4.25) $y4 $KW $KH 'C' 'AUTOCROP' $true 'normal'
DrawKey (X 5.25) $y4 $KW $KH 'V' 'LEVELS' $true 'normal'
DrawKey (X 6.25) $y4 $KW $KH 'B' 'DEBAND' $true 'normal'
DrawKey (X 7.25) $y4 $KW $KH 'N' '' $false 'normal'
DrawKey (X 8.25) $y4 $KW $KH 'M' 'MUTE' $true 'normal'
DrawKey (X 9.25) $y4 $KW $KH ',' '' $false 'normal'
DrawKey (X 10.25) $y4 $KW $KH '.' '' $false 'normal'
DrawKey (X 11.25) $y4 $KW $KH '/' '' $false 'normal'
DrawKey (X 12.25) $y4 (2.75 * $U - $GAP) $KH 'SHIFT' '' $false 'normal'

# ---------- bottom row ----------
DrawKey (X 0) $y5 (1.25 * $U - $GAP) $KH 'CTRL' '' $false 'normal'
DrawKey (X 1.25) $y5 (1.25 * $U - $GAP) $KH 'WIN' '' $false 'normal'
DrawKey (X 2.5) $y5 (1.25 * $U - $GAP) $KH 'ALT' '' $false 'normal'
DrawKey (X 3.75) $y5 (6.25 * $U - $GAP) $KH 'SPACE' '' $false 'normal'
DrawKey (X 10) $y5 (1.25 * $U - $GAP) $KH 'ALT' '' $false 'normal'
DrawKey (X 11.25) $y5 (1.25 * $U - $GAP) $KH 'FN' '' $false 'normal'
DrawKey (X 12.5) $y5 (1.25 * $U - $GAP) $KH 'MENU' '' $false 'normal'
DrawKey (X 13.75) $y5 (1.25 * $U - $GAP) $KH 'CTRL' '' $false 'normal'

# ---------- numpad ----------
$NX = 1498
function NX([double]$n) { return $NX + $n * $U }
$nA = $y1; $nB = $y2; $nC = $y3; $nD = $y4; $nE = $y5

DrawKey (NX 0) $nA $KW $KH 'NUM' '' $false 'normal'
DrawKey (NX 1) $nA $KW $KH '/' "VOL ${minus}2" $true 'normal'
DrawKey (NX 2) $nA $KW $KH '*' 'VOL +2' $true 'normal'
DrawKey (NX 3) $nA $KW $KH $minus "SUBS${nln}SIZE ${minus}" $true 'normal'

DrawKey (NX 0) $nB $KW $KH '' '7' $true 'digit'
DrawKey (NX 1) $nB $KW $KH '' '8' $true 'digit'
DrawKey (NX 2) $nB $KW $KH '' '9' $true 'digit'
DrawKey (NX 3) $nB $KW (2 * $KH + $GAP) '+' "SUBS${nln}SIZE +" $true 'normal'

DrawKey (NX 0) $nC $KW $KH '' '4' $true 'digit'
DrawKey (NX 1) $nC $KW $KH '' '5' $true 'digit'
DrawKey (NX 2) $nC $KW $KH '' '6' $true 'digit'

DrawKey (NX 0) $nD $KW $KH '' '1' $true 'digit'
DrawKey (NX 1) $nD $KW $KH '' '2' $true 'digit'
DrawKey (NX 2) $nD $KW $KH '' '3' $true 'digit'
DrawKey (NX 3) $nD $KW (2 * $KH + $GAP) 'ENTER' '' $false 'normal'

DrawKey (NX 0) $nE (2 * $U - $GAP) $KH '' '0' $true 'digit'
DrawKey (NX 2) $nE $KW $KH '.' '' $false 'normal'

# numpad caption
$numCapRect = New-Object System.Drawing.RectangleF($NX, ($nE + $KH + 18), (4 * $U - $GAP), 24)
$g.DrawString("VOLUME 0${endash}100 %", $fLabelL, (New-Object System.Drawing.SolidBrush($amber)), $numCapRect, $sfCenter)
$numCapRect2 = New-Object System.Drawing.RectangleF($NX, ($nE + $KH + 44), (4 * $U - $GAP), 20)
$g.DrawString("11.1 % per step  ${dot}  0 is silent", $fSmall, (New-Object System.Drawing.SolidBrush($greyText)), $numCapRect2, $sfCenter)

# ---------- arrows ----------
$AX = $NX
$ay = 790
DrawKey (NX 1) $ay $KW $KH $arrUp 'SEEK +60' $true 'arrow'
DrawKey (NX 0) ($ay + $U) $KW $KH $arrLf "SEEK ${minus}5" $true 'arrow'
DrawKey (NX 1) ($ay + $U) $KW $KH $arrDn "SEEK ${minus}60" $true 'arrow'
DrawKey (NX 2) ($ay + $U) $KW $KH $arrRt 'SEEK +5' $true 'arrow'
$arrowCap = New-Object System.Drawing.RectangleF($AX, ($ay + 2 * $U + 10), (4 * $U - $GAP), 22)
$g.DrawString("ARROWS  ${dot}  SEEK", $fSmall, (New-Object System.Drawing.SolidBrush($greyText)), $arrowCap, $sfCenter)

# ---------- combos legend ----------
$lx = 140
$ly = 748
$g.DrawString('COMBOS', $fLabelL, (New-Object System.Drawing.SolidBrush($amber)), $lx, $ly)

$combos = @(
    @('SHIFT+ESC', 'quit and save position'),
    @('CTRL+PRINT', 'screenshot with subtitles'),
    @('CTRL+F10', 'screenshot (alt)'),
    @('SHIFT+Z', 'zoom out'),
    @('CTRL+D', 'autodeint'),
    @('CTRL+C', 'force quit')
)
$c1 = 0
foreach ($c in $combos) {
    $cx = $lx
    $cy = $ly + 34 + $c1 * 28
    $keyRect = New-Object System.Drawing.RectangleF($cx, $cy, 150, 24)
    $g.DrawString($c[0], $fCombo, (New-Object System.Drawing.SolidBrush($amberSoft)), $keyRect, $sfNear)
    $actRect = New-Object System.Drawing.RectangleF(($cx + 158), $cy, 420, 24)
    $g.DrawString($c[1], $fSmall, (New-Object System.Drawing.SolidBrush($greyText)), $actRect, $sfNear)
    $c1++
}

# ---------- footer ----------
$footPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(40, 252, 190, 17)), 1
$g.DrawLine($footPen, 140, 952, 1782, 952)

$g.DrawString("ESC in fullscreen leaves fullscreen first; the next press quits  ${dot}  q / w move subtitles into the black bars of 21:9 films", $fSmall, (New-Object System.Drawing.SolidBrush($warmWhite)), 140, 972)
$g.DrawString("numpad + / ${minus} resize subtitles and keep the size between runs  ${dot}  m or MUTE mutes  ${dot}  uosc draws the timeline and volume indicators", $fSmall, (New-Object System.Drawing.SolidBrush($greyText)), 140, 998)

# small amber corner ticks
$tickPen = New-Object System.Drawing.Pen ($amber, 2)
$g.DrawLine($tickPen, 26, 26, 66, 26); $g.DrawLine($tickPen, 26, 26, 26, 66)
$g.DrawLine($tickPen, $W - 26, 26, $W - 66, 26); $g.DrawLine($tickPen, $W - 26, 26, $W - 26, 66)
$g.DrawLine($tickPen, 26, $H - 26, 66, $H - 26); $g.DrawLine($tickPen, 26, $H - 26, 26, $H - 66)
$g.DrawLine($tickPen, $W - 26, $H - 26, $W - 66, $H - 26); $g.DrawLine($tickPen, $W - 26, $H - 26, $W - 26, $H - 66)

$out = Join-Path $PSScriptRoot 'keys.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output "saved $out"
