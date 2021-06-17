
$root = 'D:\someBackupRootFolder'
Get-ChildItem -Path $root -Recurse -File |
    ForEach-Object {
        $fileAge = New-TimeSpan -Start ($_.LastWriteTime).Date -End (Get-Date).Date
        if(
            $fileAge.Days -gt 28 -and
            $fileAge.Days -lt 182 -and
            $_.LastWriteTime.DayOfWeek -ne 'Monday'
        ){
            $_
        }
  }