#
#   ROBOCOPY Script
#
#   This script calls robocopy over a few folders, and then emails you when they're done

Param(
    [Parameter(Mandatory=$true)]
    [string]$basesrc, #"G:\",
    [Parameter(Mandatory=$true)]
    [string]$basedst, #
    [Parameter(Mandatory=$false)]
    [string[]]$dirs= $(),
    [string]$backup_log_dir = "backuplogs"
)

Set-Location -Path $PSScriptRoot
Write-Host "###### Starting backup script ######"

$robocopy_block = {
    param($src,$dst,$log)
    New-Item -Force $log | Out-Null
    # Execute a command
    robocopy $src $dst /MIR /ZB /MT /XJ /XD Temp /R:3 /LOG:$log /NP
        # /MIR  # mirroring the folders, removing non-existant files. We don't want lots of old files cluttering up the backup and the File Shares should keep a history on their own
        # /ZB   # copies files such that if they are interrupted part-way, they can be restarted (should be default IMHO)
        # /MT   # copies using multiple cores, good for many small files
        # /XJ   # Ignoring junctions, they can cause infinite loops when recursing through folders
        # /XD Temp  # Temp directories shouldn't have important data files
        # /R:3  # Retrying a file only 3 times, we don't want bad permissions or other dumb stuff to halt the entire backup
        # /LOG:$log # Logging to a file internally, the best way to log with the /MT flag
        # /NP   # Removing percentages from the log, they don't format well
    "Backup directory is complete. [$src -> $dst] ($log)"
}

if ((test-path variable:\dirs) -and ($dirs.Length -ne 0)) {
    foreach ($dir in $dirs)
    {
        $src = Join-Path $basesrc $dir
        $dst = Join-Path $basedst $dir
        $log = Join-Path $backup_log_dir "backup_$($dir)_$(get-date -f yyyy-MM-dd_hh-mm-ss).log"

        # Show the loop variable here is correct
        Write-Host "Backing up $dir..."

        # pass the loop variable across the job-context barrier
        Start-Job $robocopy_block -ArgumentList $src,$dst,$log -Name "backup-$dir" | Out-Null
    }
}
else {
    Write-Host "Backing up $basesrc -> $basedst..."
    $log = Join-Path $backup_log_dir "backup_$(get-date -f yyyy-MM-dd_hh-mm-ss).log"
    Invoke-Command $robocopy_block -ArgumentList $basesrc,$basedst,$log | Out-Null
}

# Wait for all to complete
While (Get-Job -State "Running") { Start-Sleep 2 }
# Display output from all jobs
Get-Job | Receive-Job
# Cleanup
Remove-Job *

Send-MailMessage -to "admin <admin@foo.com>" `
    -from "backup <backup@foo.com>" `
    -subject "Backup Finished" `
    -smtpServer smtp.foo.com
Write-Host "###### Backup is complete ######"