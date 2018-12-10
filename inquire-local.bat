echo y | rename  c:\tmp\serverlist\list.txt list.txt.bak
hostname > c:\tmp\serverlist\list.txt




Powershell -Command "& %~dp0serverlist.ps1"

echo y | del c:\tmp\serverlist\list.txt
echo y | copy c:\tmp\serverlist\list.txt.bak c:\tmp\serverlist\list.txt
echo y | del c:\tmp\serverlist\list.txt.bak

c:\tmp\serverlist\upload.bat

pause
