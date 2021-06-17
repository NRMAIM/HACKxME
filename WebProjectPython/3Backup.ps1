$path = 'c:\Backup'
$archivePath = 'c:\Backup Archive'
$fileExtension   = '*.zip'
 
$weeklyStartDay = 29
$weeklyEndDay = 182
$archiveDays = $weeklyEndDay + 1        # Set days for archiving backups to different folder
 
# delete duplicate files for daily backups
echo 'Clean duplicates'
Get-ChildItem -Path $path -Filter $fileExtension -File |                # get files that start with the prefix and have the extension '.zip'
    Where-Object { $_.BaseName -match '_\d{14}$' } |                    # that end with an underscore followed by 14 digits
    Group-Object -Property @{Expression = { $_.LastWriteTime.Date }} |  # create groups based on the date part without time part
        ForEach-Object {
            $_.Group | 
            Sort-Object -Property LastWriteTime -Descending |           # sort on the LastWriteTime property
            Select-Object -Skip 1 |                                     # select them all except for the first (most recent) one
            Remove-Item -Force                                   # delete these files
        }
 
# after X days, remove all backups except Mondays
echo 'Clean older bacckup files, keep Mondays'
Get-ChildItem -Path $path -File |
    ForEach-Object {
        $fileAge = New-TimeSpan -Start $_.LastWriteTime -End (Get-Date).Date
        if(
            $fileAge.Days -ge $weeklyStartDay -and
            #$fileAge.Days -le $weeklyEndDay -and
            $_.LastWriteTime.DayOfWeek -ne 'Monday'
        ){
            #$_
            Remove-Item -Path $_.FullName -Force 
        }
    }
 
# archive files older then specified date
echo "Archive older backups"
If(!(test-path $archivePath)) { New-Item -ItemType Directory -Force -Path $archivePath | Out-Null }
Get-ChildItem -Path $path -File |
    ForEach-Object {
        $fileAge = New-TimeSpan -Start $_.LastWriteTime -End (Get-Date).Date
        if(
            $fileAge.Days -ge $archiveDays
        ){
            #$_
            Move-Item -Path $_.FullName -Destination $archivePath 
        }
   }

   PowerShell
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




