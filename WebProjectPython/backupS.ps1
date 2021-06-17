import-module activedirectory 
 
echo "------------------------------------BACK-UP CONTROLLER--------------------------------------" 
 
echo "1. FULL-BACKUP  " 
echo "2. SCHEDULE-BACKUP  " 
echo "3. SYSTEM-STATE BACKUP " 
$a=read-host "Enter your choice" 
switch ($a) 
{ 
1 { 
$bt=read-host "enter backup target" 
$inc=read-host "enter the drives to include separated by comma" 
wbadmin start backup -backuptarget:$bt -include:$inc  -noverify -quiet 
} 
 
2 { 
$b=read-host "enter backup target" 
$in=read-host "enter the drives to include separated by comma" 
$t=read-host "enter the 24-hour time format to run backup" 
wbadmin enable backup -addtarget:$b  -schedule:$t  -include:$in  -quiet 
} 
 
3 { 
$tar=read-host "enter backup target" 
wbadmin start systemstatebackup -backuptarget:$tar  -quiet 
} 
 
default {"Wrong choice entered"} 
} 