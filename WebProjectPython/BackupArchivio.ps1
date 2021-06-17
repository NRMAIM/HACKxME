$path = 'c:\Backup'
$archivePath = 'c:\Backup Archive'
$fileExtension = '*.zip'
 
$weeklyStartDay = 29
$weeklyEndDay = 182
$archiveDays = $weeklyEndDay - 1
 
$CompleteBakupFileList = Get-ChildItem -Path $path -Filter $fileExtension -File |
                        Select-Object -Property *, @{Name = 'fileAgeDays'; Expression = { (New-TimeSpan -Start $_.LastWriteTime -End (Get-Date).Date).Days } },
                                                    @{Name = 'DayOfWeek'; Expression = { $_.LastWriteTime.DayOfWeek } }
If (-not (test-path $archivePath)) { New-Item -ItemType Directory -Force -Path $archivePath | Out-Null }
 
$CompleteBakupFileList |
Where-Object { $_.BaseName -match '_\d{14}$' } |
Group-Object -Property @{Expression = { $_.LastWriteTime.Date } } |
ForEach-Object {
    $_.Group | 
    Sort-Object -Property LastWriteTime -Descending |
    Select-Object -Skip 1 |
    Remove-Item -Force
}
foreach ($BackupFile in $CompleteBakupFileList) {
    if (
        $BackupFile.fileAgeDays -le $archiveDays
    ) {
        Move-Item -Path  $BackupFile.FullName -Destination $archivePath 
    }
    elseif (
        $BackupFile.fileAgeDays -le $weeklyStartDay -and
        $BackupFile.fileAgeDays -ge $weeklyEndDay -and
        $BackupFile.DayOfWeek -ne 'Monday'
    ) {
        Remove-Item -Path $BackupFile.FullName -Force
    }
}