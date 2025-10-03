#$image = Get-SpectreImage .\wheel.gif -maxWidth 75
#$image = Get-SpectreImage .\spin-12315.gif -maxWidth 75
$random = 25

cls


for($frame = 0; $frame -lt $random; $frame++) {
    [Console]::SetCursorPosition(0, 0)
    $image | Format-SpectrePanel -Title "Frame: $frame" -Color White | Out-SpectreHost
    Start-Sleep -Milliseconds 15
}

cls 

$json = (get-content numbers.json | ConvertFrom-Json)
$num = $json | get-random

$json | Where-Object {$_ -ne $num} | ConvertTo-Json | set-content numbers.json

#Format-SpectrePanel -Data ('Demo number {0}' -f $num) -Title "The Wheel Chooses:" -Border "Rounded" -Color "Red" -Width 30

Write-SpectreFigletText -Text ('Demo number {0}' -f $num) -Color Red
$num | clip

