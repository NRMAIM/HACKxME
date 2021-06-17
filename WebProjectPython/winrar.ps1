function New-RarArchive{
    param(
        [string] $source=$(throw "Invalid source parameter"),   
        [string] $destination=$(throw "Invalid destination parameter"),   
        [string] $name=$(throw "Invalid name parameter"),
        [string] $winrar = "$env:ProgramFiles\WinRAR\WinRAR.exe",
        [switch] $directory
    )

    if($directory){
        if( -not (Test-Path $source -pathType container)){
            write-error "Invalid directory path <$source>";
            break;
         } 

   } else {
        if( -not (Test-Path $source -pathType leaf)){
            write-error "Invalid file path <$source>";
            break;
        }
    }

    if( -not (Test-Path $destination -pathType container)){
        write-error "Invalid destination path <$destination>";
        break;
    }

    # winrar switches:
    # A - Add specified files and folders to an archive.
    # IBCK -  Minimize WinRAR to tray, runs in the background.
    # Y - Yes will be the default and automatic reply to all queries.
    # R - recurse subfolders.   
    # ILOG[name] - log errors to file

    if($directory){
        & $winrar A -IBCK -Y -R "$destination\$name" $("$source\*.*") | out-null
    } else {
        & $winrar A -IBCK -Y -R "$destination\$name" $source | out-null
    }

    if($LASTEXITCODE -match "[01]"){
        # 0 - Successful operation.
        # 1 - Warning. Non fatal error(s) occurred.
        write-host "New archive created <$destination\$name>" -foreground green
        $true;
    } else {
        switch($LASTEXITCODE){
            2       {write-error "A fatal error occurred."}
            3       {write-error "CRC error occurred when unpacking."}
            4       {write-error "Attempt to modify a locked archive."}
            5       {write-error "Write error."}
            6       {write-error "File open error."}
            7       {write-error "Wrong command line option."}
            8       {write-error "Not enough memory."}
            9       {write-error "File create error."}
            255    {write-error "User break."}
        }
        $false;
    }
}

 

Archive c:\scripts directory to \\server\share

>> New-RarArchive -source "c:\scripts" -destination \\server\share -name "test.rar" -director

>> New-RarArchive  -source "C:\Scripts\test.exe" -destination "D:\Backup" -name "test.rar"