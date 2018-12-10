."C:\tmp\serverlist\Invoke-Parallel.ps1"

#GetHostByName
#GetHostByAddress
        
     #get-adcomputer -properties * -Filter {Operatingsystem -like "windows server*" } | Select-Object name | Export-CSV "C:\tmp\serverlist\remotelist1.txt" -NoTypeInformation -Encoding UTF8
     
     ##################################################################################         
     $reportname = "t_serverdet_tmp"   
     $upload = "serverlist.csv"   
     $error1 = "error.csv"
     $pingfailed = "failed.csv"
     
     
     
     $serverlist = "C:\tmp\serverlist\list.txt"
     
     ##################################################################################
     Remove-Item "C:\tmp\serverlist\raw\*.1" | Where { ! $_.PSIsContainer }     
     Remove-Item "C:\tmp\serverlist\raw\*.2" | Where { ! $_.PSIsContainer }  
     Remove-Item "C:\tmp\serverlist\raw\*.3" | Where { ! $_.PSIsContainer }  
     #Remove-Item "C:\tmp\serverlist\raw\*.csv" | Where { ! $_.PSIsContainer }    
     ##################################################################################
     
     $checkrep = Test-Path "C:\tmp\serverlist\report\$upload"
 
     If ($checkrep -like "True") 
         { 
            Remove-Item "C:\tmp\serverlist\report\$upload" -Force
         }
            New-Item "C:\tmp\serverlist\report\$upload" -type file

     ##################################################################################
          ##################################################################################
     
     $checkrep = Test-Path "C:\tmp\serverlist\raw\header.h"
 
     If ($checkrep -like "True") 
         { 
            Remove-Item "C:\tmp\serverlist\raw\header.h" -Force
         }
            New-Item "C:\tmp\serverlist\raw\header.h"  -type file

     ##################################################################################

     $checkrep = Test-Path "C:\tmp\serverlist\raw\$pingfailed"
 
     If ($checkrep -like "True") 
         { 
            Remove-Item "C:\tmp\serverlist\raw\$pingfailed" -Force
         }
            New-Item "C:\tmp\serverlist\raw\$pingfailed" -type file
     
     ##################################################################################
     ##################################################################################
     $checkrep = Test-Path "C:\tmp\serverlist\raw\$error1"
 
     If ($checkrep -like "True") 
         { 
            Remove-Item "C:\tmp\serverlist\raw\$error1" -Force
         }
            New-Item "C:\tmp\serverlist\raw\$error1" -type file
     
    ##################################################################################
  


    ####################################################################################### 
    #$colname = get-content -path "C:\tmp\serverlist\headers.h"   
    #######################################################################################
    $servers = get-content $serverlist    



    invoke-parallel -InputObject $servers -throttle 20 -runspaceTimeout 120 -ScriptBlock { 

    if($ping = Test-Connection -ComputerName $_ -BufferSize 16 -quiet -count 2){ 
 
 
    Try {   

        
    ################################################################################# 
 
    
    $BIOSInfo = Get-WmiObject win32_BIOS -ComputerName $_ #Get Network Information
    $sn = $BIOSInfo.SerialNumber

    $OS = Get-WmiObject Win32_Computersystem -ComputerName $_ #Get Network Information
    $RAM =   [math]::round($OS.TotalPhysicalMemory / 1MB, 2)

    $CompSystem_TotalVirtualMemorySize = [math]::round($OS.TotalVirtualMemorySize / 1MB, 2)
    $CompSystem_TotalVisibleMemorySize = [math]::round(($OS.TotalVisibleMemorySize / 1MB), 2) 
    
    $CompSystem = Get-WmiObject Win32_Computersystem -ComputerName $_ #Get Network Information

    $CompSystem_model = $CompSystem.model
    $CompSystem_DNSHostName = $CompSystem.DNSHostName 
    $CompSystem_Domain = $CompSystem.Domain    
    $CompSystem_Description = $CompSystem.Description
    $CompSystem_Caption = $CompSystem.Caption
    $CompSystem_OSArchitecture = $CompSystem.OSArchitecture
    $CompSystem_ServicePackMajorVersion = $CompSystem.ServicePackMajorVersion
    
    
    

    $CPUInfo = Get-WmiObject Win32_Processor -ComputerName $_ #Get CPU Information
    $CPUInfo_Name = $CPUInfo.Name
    $CPUInfo_Description = $CPUInfo.Description
    $CPUInfo_Manufacturer = $CPUInfo.Manufacturer
    $CPUInfo_CurrentClockSpeed = $CPUInfo.CurrentClockSpeed
    $CPUInfo_NumberOfCores = $CPUInfo.NumberOfCores
    $CPUInfo_NumberOfLogicalProcessors = $CPUInfo.NumberOfLogicalProcessors


    $NetInfo = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } #Get Network Information


    $Hive = [Microsoft.Win32.RegistryHive]::LocalMachine
    $KeyPath1 = 'SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters'
    $KeyPath2 = 'SOFTWARE\Microsoft\Virtual Machine\Auto'
    
    $Value0 = 'VirtualMachineName' 
    $Value1 = 'PhysicalHostName'     
    $Value2 = 'PhysicalHostNameFullyQualified' 
    $Value3 = 'VirtualMachineId'

    $Value4 = 'FullyQualifiedDomainName'
    $Value5 = 'OSName'
    $Value6 = 'RDPAddressIPv4'

    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $_)
    $key1 = $reg.OpenSubKey($KeyPath1)
    $key2 = $reg.OpenSubKey($KeyPath2)
    #############################################################   

    
         
    #################################################################################   
    #################################################################################  
    $header       = "fqdn,"     
    $rowdata_csv  = "$($key2.GetValue($Value4))," #'fqdn'
    #################################################################################   
    #################################################################################  
    $header      += "domainname,"
    $rowdata_csv += "$CompSystem_Domain," # domainname
    #################################################################################   
    #################################################################################  
    $header      += "hostname,"    
    $rowdata_csv += "$_," #hostname
    #################################################################################   
    #################################################################################  
    $header      += "virtualmachinename,"    
    $rowdata_csv += "$($key1.GetValue($Value0))," #'virtualmachinename'
    
    #################################################################################   
    #################################################################################  
    $header      += "host,"
    $rowdata_csv += "$($key1.GetValue($Value1))," #'host'
    
    #################################################################################   
    #################################################################################  
    $header      += "host-fqdn,"
    $rowdata_csv += "$($key1.GetValue($Value2))," #'host-fqdn' 
    
    #################################################################################   
    #################################################################################  
    $header      += "vmid,"
    $rowdata_csv += "$($key1.GetValue($Value3))," #'vmid'
    #################################################################################  
    #################################################################################  
    $header      += "machinetype,"       
    if($CompSystem_model -like "Virtual Machine") #machinetype
        {
            $rowdata_csv += "Virtual,"    
        }
    else
        {    
            $rowdata_csv += "Physical,"
        }
    #################################################################################      
    #################################################################################  
    #$header      += "rdp-ipv4,"
    #$rowdata_csv += "$($key2.GetValue($Value6))," #rdp-ipv4
    #################################################################################      
    
    #################################################################################  
    $header      += "rdp-ipv4,"    
    $rowdata_csv += (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select IPAddress -First 1).IPAddress[0]+","

    ################################################################################# 
    #################################################################################  
    $header      += "rdp-mac,"    
    $rowdata_csv += (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select MACAddress -First 1).MACAddress+","

    ################################################################################# 
    #################################################################################  
    #$header      += "rdp-ipv4-mac,"    
    #$str =  (gwmi -Class Win32_NetworkAdapterConfiguration  -ComputerName $_ | where { $_.IpAddress -eq $rdp_ipv4x }).MACAddress
    #$rowdata_csv += "$str," #rdp-ipv4-mac
    ################################################################################# 
     
    #################################################################################  
    $header      += "defaultgateway,"    
    $rowdata_csv += (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select DefaultIPGateway -First 1).DefaultIPGateway[0]+","
    #################################################################################      
    #################################################################################  
    $header      += "dns1,"    
    $rowdata_csv += (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select DNSServerSearchOrder -First 1).DNSServerSearchOrder[0]+","
    #################################################################################      
    #################################################################################  
    $header      += "dns2,"    
    $rowdata_csv += (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select DNSServerSearchOrder -First 1).DNSServerSearchOrder[1]+","    
    #################################################################################  
    $header      += "subnetmask,"    
    $rowdata_csv += (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ | where { (($_.IPEnabled -ne $null) -and ($_.DefaultIPGateway -ne $null)) } | select ipsubnet -First 1).ipsubnet[0]+","    
    #################################################################################  




    $header      += "otheripv4,"
    $otherIPv4 = [System.Net.Dns]::GetHostAddresses($_)    
    $rowdata_csv += "$otherIPv4," #otheripv4     

    ################################################################################# 
    $header      += "dhcpenabled,"
    $IsDHCPEnabled = $false            
    If($NetInfo.DHCPEnabled) {            
     $IsDHCPEnabled = $true            
    }          
    $rowdata_csv += "$IsDHCPEnabled," #dhcpenabled     
    #################################################################################  
    $header      += "serialnumber,"
    $rowdata_csv += "$sn," #serialnumber    
    #################################################################################  
    $header      += "model,"    
    $rowdata_csv += "$CompSystem_model," #model
    #################################################################################  
    $header      += "osname,"
    $rowdata_csv += "$($key2.GetValue($Value5))," #'osname' 
    #################################################################################  
    $header      += "oscaption,"
    $rowdata_csv += "$CompSystem_Caption," #oscaption
    #################################################################################  
    $header      += "osarch,"
    $rowdata_csv += "$CompSystem_OSArchitecture," #osarch
    #################################################################################  
    $header      += "ossp,"
    $rowdata_csv += "$CompSystem_ServicePackMajorVersion," #ossp
    #################################################################################  
    $header      += "totalvisiblememory,"
    $rowdata_csv += "$RAM," #totalvisiblememory CompSystem_TotalVirtualMemorySize
    #################################################################################  
    $header      += "cpuname,"    
    $rowdata_csv += "$CPUInfo_Name," #cpuname
    #################################################################################  
    $header      += "cpudesc,"
    $rowdata_csv += "$CPUInfo_Description," #cpudesc
    #################################################################################  
    $header      += "cpumanufacturer,"
    $rowdata_csv += "$CPUInfo_Manufacturer," #cpumanufacturer
    #################################################################################  
    $header      += "cpuclockspeed,"
    $rowdata_csv += "$CPUInfo_CurrentClockSpeed," #cpuclockspeed  
    #################################################################################  
    $header      += "cpunumberofcore,"
    $rowdata_csv += "$CPUInfo_NumberOfCores," #cpunumberofcore
    #################################################################################  
    $header      += "cpunumberoflogicalprocessor,"
    $rowdata_csv += "$CPUInfo_NumberOfLogicalProcessors," #cpunumberoflogicalprocessor
    #################################################################################  


    
    
    $header      += "pcsystemtype,"    
    $x = $CompSystem.PCSystemTypex
    $Type = Switch ($x) 
            {
                1 {"Desktop"}
                2 {"Mobile / Laptop"}
                3 {"Workstation"}
                4 {"Enterprise Server"}
                5 {"Small Office and Home Office (SOHO) Server"}
                6 {"Appliance PC"}
                7 {"Performance Server"}
                8 {"Maximum"}
                default {"Not a known Product Type"}
            } 
    $rowdata_csv += "$Type," #pcsystemtype
    #################################################################################      
    $header      += "domainrole," 
    $y = $CompSystem.DomainRole      
    $Role = Switch ($y) 
        {
            0 {"Standalone Workstation"}
            1 {"Member Workstation"}
            2 {"Standalone Server"}
            3 {"Member Server"}
            4 {"Backup Domain Controller"}
            5 {"Primary Domain Controller"}
            default {"Not a known Domain Role"}
        }
    $rowdata_csv += "$Role," #domainrole 
    
    #################################################################################      
    #################################################################################             
    #################################################################################      
    $namef = $_.ToString().ToLower()
    $rowdata_csv = $rowdata_csv.ToString().ToLower()
    add-content -path "C:\tmp\serverlist\raw\$namef.1" -value $rowdata_csv
    add-content -path "C:\tmp\serverlist\raw\header.h" -value $header
    #################################################################################
    }#Try  
Catch
    {      
    #################################################################################
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    add-content -path "C:\tmp\serverlist\raw\$_.3" -value "NA"
    #################################################################################
    }#catch  
    }#ping 
else
    {
    #################################################################################
    add-content -path "C:\tmp\serverlist\raw\$_.2" -value "$_, Failed"
    #################################################################################
    }#else
    <#######################################################################################################################################>  
    #Create and display object 
    $temp = "" | Select ComputerName, Ping 
    $temp.ComputerName = $_ 
    #$temp."deviceID" = $deviceID 
    #$temp."volName" = $volName 
    #$temp."sizeGB" = $sizeGB 
    #$temp."usedSpaceGB" = $usedSpaceGB 
	#$temp."percentFree" = $percentFree
    #$temp.ping = $ping 
    $temp  
    <#######################################################################################################################################> 
    }#scriptblock
    <#######################################################################################################################################> 
    #$header = "fqdn,driveletter,drivename,totalsizegb,usedsizegb,freesspacegb,percentfreespace" 
    ################################################################################     
    $checkrep = Test-Path "C:\tmp\serverlist\raw\*.1"
    If ($checkrep -like "True") 
    { 
        cat "C:\tmp\serverlist\raw\*.1" | sc "C:\tmp\serverlist\raw\rowdata.1"
        $rowdata_csv1 = get-content "C:\tmp\serverlist\raw\rowdata.1"          
    }
    #################################################################################################                        
    $date1 = get-date -f yyyy-MM-dd-hh-mm-ss


    add-content -path "C:\tmp\serverlist\report\$upload" -value $rowdata_csv1

    $header = Get-Content -path "C:\tmp\serverlist\raw\header.h" -Last 1
   

    #add-content -path "C:\tmp\serverlist\report\$reportname-$date1.csv" -value $header
    #add-content -path "C:\tmp\serverlist\report\$reportname-$date1.csv" -value $rowdata_csv1

    add-content -path "C:\tmp\serverlist\report\$reportname.csv" -value $header
    add-content -path "C:\tmp\serverlist\report\$reportname.csv" -value $rowdata_csv1

    #$date1 = get-date -f yyyy-MM-dd-hh-mm-ss
    #Copy-Item "C:\tmp\serverlist\raw\$reportname" "\\scom3\scriptdata\$reportname-$date.csv"       
    ##################################################################################
    
    ##################################################################################     
    $checkrep = Test-Path "C:\tmp\serverlist\raw\*.2"
 
    If ($checkrep -like "True") 
    { 
        cat "C:\tmp\serverlist\raw\*.2" | sc "C:\tmp\serverlist\raw\rowdata.2"
        $rowdata_csv2 = get-content "C:\tmp\serverlist\raw\rowdata.2"
        add-content -path "C:\tmp\serverlist\raw\$pingfailed" -value $rowdata_csv2
            
    }
    ##################################################################################

  ##################################################################################     
     $checkrep = Test-Path "C:\tmp\serverlist\raw\*.3"
 
     If ($checkrep -like "True") 
         { 
            cat "C:\tmp\serverlist\raw\*.3" | sc "C:\tmp\serverlist\raw\rowdata.3"
            $rowdata_csv3 = get-content "C:\tmp\serverlist\raw\rowdata.3"
            add-content -path "C:\tmp\serverlist\raw\$error" -value $rowdata_csv3
            
         }
  ##################################################################################
  
  
  Remove-Item "C:\tmp\serverlist\raw\*.1" | Where { ! $_.PSIsContainer }
  Remove-Item "C:\tmp\serverlist\raw\*.2" | Where { ! $_.PSIsContainer }
  Remove-Item "C:\tmp\serverlist\raw\*.3" | Where { ! $_.PSIsContainer }
  

   
  #start-process "cmd.exe" "/c C:\tmp\serverlist\upload.bat" 
  #Write-Host "done upload data!"
 
