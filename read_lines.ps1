$lines = [System.IO.File]::ReadAllLines('E:\Made_with_ai\Project_1\lib\ui\chat_screen.dart')
for ($idx = 733; $idx -le 741; $idx++) {
    $line = $lines[$idx]
    $num = $idx + 1
    Write-Host "${num}: |${line}|"
}
