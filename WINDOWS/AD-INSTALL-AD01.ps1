
#--------------------------------------------------------------------------
#- Created by:             David Rodriguez                                -
#- Blog:                   www.sysadmintutorials.com                      -
#- Modified by:            Maximilian Neu                                 -
#--------------------------------------------------------------------------
#-------------
#- Variables -                                         -
#-------------

# Network Variables
$ethipaddress = '172.16.10.20' # static IP Address of the server
$ethprefixlength = '24' # subnet mask - 24 = 255.255.255.0
$ethdefaultgw = '172.16.10.254' # default gateway
$ethdns = '127.0.0.1,172.16.10.21' # for multiple DNS you can append DNS entries with comma's
$globalsubnet = '172.16.10.0/24' # Global Subnet will be used in DNS Reverse Record and AD Sites and Services Subnet
$subnetlocation = 'Colmar'
$sitename = 'Colmar-Site' # Renames Default-First-Site within AD Sites and Services

# Active Directory Variables
$domainname = 'haut-rhin.gouv' # enter in your active directory domain

# Remote Desktop Variable
$enablerdp = 'yes' # to enable RDP, set this variable to yes. to disable RDP, set this variable to no

# Hostname Variables
$computername = 'VAD68COL01' # enter in your server name

# NTP Variables
$ntpserver1 = '0.fr.pool.ntp.org'
$ntpserver2 = '1.fr.pool.ntp.org'

# Timestamp
Function Timestamp {
    $Global:timestamp = Get-Date -Format "dd-MM-yyy_hh:mm:ss"
}

# Log File Location
$logfile = "C:\AD-Install\Windows-2022-AD-Deployment-log.txt"

# Create Log File
Write-Host "-= Get timestamp =-" -ForegroundColor Green

Timestamp

IF (Test-Path $logfile) {
    Write-Host "-= Logfile Exists =-" -ForegroundColor Yellow
}

ELSE {

    Write-Host "-= Creating Logfile =-" -ForegroundColor Green

    Try {
        New-Item -Path 'C:\AD-Install' -ItemType Directory | Out-Null
        New-Item -ItemType File -Path $logfile -ErrorAction Stop | Out-Null
        Write-Host "-= The file $($logfile) has been created =-" -ForegroundColor Green
    }
    Catch {
        Write-Warning -Message $("Could not create logfile. Error: " + $_.Exception.Message)
        Break;
    }
}

# Check Script Progress via Logfile

$firstcheck = Select-String -Path $logfile -Pattern "1-Basic-Server-Config-Complete"

IF (!$firstcheck) {

    # Add starting date and time
    Write-Host "-= 1-Basic-Server-Config-Complete, does not exist =-" -ForegroundColor Yellow

    Timestamp
    Add-Content $logfile "$($Timestamp) - Starting Active Directory Script"

    ## 1-Basic-Server-Config ##

    #------------
    #- Settings -
    #------------

    # Set Network
    Timestamp
    Try {
        # Get current IP configuration for the first enabled adapter
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
        $currentIP = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4

        Write-Host "-= Using network adapter: $($adapter.Name) =-" -ForegroundColor Yellow
        Add-Content $logfile "$($Timestamp) - Using network adapter: $($adapter.Name)"

        # Check if settings are already configured
        if ($currentIP.IPAddress -eq $ethipaddress -and 
            $currentIP.PrefixLength -eq $ethprefixlength) {
            Write-Host "-= Network settings already configured, skipping =-" -ForegroundColor Yellow
            Add-Content $logfile "$($Timestamp) - Network settings already configured, no changes needed"
        }
        else {
            New-NetIPAddress -IPAddress $ethipaddress -PrefixLength $ethprefixlength -DefaultGateway $ethdefaultgw -InterfaceIndex $adapter.ifIndex -ErrorAction Stop | Out-Null
            Set-DNSClientServerAddress -ServerAddresses $ethdns.Split(',') -InterfaceIndex $adapter.ifIndex -ErrorAction Stop
            Write-Host "-= IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns) =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns)"
        }
    }
    Catch {
        Write-Warning -Message $("Failed to verify/apply network settings. Error: " + $_.Exception.Message)
        Break;
    }

    # Set RDP
    Timestamp
    Try {
        IF ($enablerdp -eq "yes") {
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -ErrorAction Stop
            Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
            Write-Host "-= RDP Successfully enabled =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - RDP Successfully enabled"
        }
    }
    Catch {
        Write-Warning -Message $("Failed to enable RDP. Error: " + $_.Exception.Message)
        Break;
    }

    IF ($enablerdp -ne "yes") {
        Write-Host "-= RDP remains disabled =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - RDP remains disabled"
    }

    # Set Hostname
    Timestamp
    Try {
        # Check if computer name already matches desired name
        if ($env:computername -eq $computername) {
            Write-Host "-= Computer name already set to $($computername), skipping rename =-" -ForegroundColor Yellow
            Add-Content $logfile "$($Timestamp) - Computer name already set to $($computername), no change needed"
        }
        else {
            Rename-Computer -ComputerName $env:computername -NewName $computername -ErrorAction Stop | Out-Null
            Write-Host "-= Computer name set to $($computername) =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Computer name set to $($computername)"
        }
    }
    Catch {
        Write-Warning -Message $("Failed to set new computer name. Error: " + $_.Exception.Message)
        Break;
    }

    # Add first script complete to logfile
    Timestamp
    Add-Content $logfile "$($Timestamp) - 1-Basic-Server-Config-Complete, starting script 2 =-"
        
    # Ask user before rebooting
    Timestamp
    $rebootChoice = Read-Host "The server needs to restart to apply changes. Do you want to restart now? (Y/N)"
        
    if ($rebootChoice -eq "Y" -or $rebootChoice -eq "y") {
        Write-Host "-= Save your work, computer will restart in 30 seconds =-" -ForegroundColor White -BackgroundColor Red
        Sleep 30

        Try {
            Restart-Computer -ComputerName $env:computername -ErrorAction Stop
            Write-Host "-= Rebooting now!! =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Rebooting now"
            Break;
        }
        Catch {
            Write-Warning -Message $("Failed to restart computer $($env:computername). Error: " + $_.Exception.Message)
            Break;
        }
    }
    else {
        Write-Warning "Restart postponed. Changes won't be applied until the server restarts."
        Add-Content $logfile "$($Timestamp) - Restart postponed by user"
    }

} # Close 'IF (!$firstcheck)'

# Check Script Progress via Logfile
$secondcheck1 = Get-Content $logfile | Where-Object { $_.Contains("1-Basic-Server-Config-Complete") }

IF ($secondcheck1) {
    $secondcheck2 = Get-Content $logfile | Where-Object { $_.Contains("2-Build-Active-Directory-Complete") }

    IF (!$secondcheck2) {

        ## 2-Build-Active-Directory ##

        Timestamp
        
        #-------------
        #- Variables -                                         -
        #-------------

        # Active Directory Variables
        $dsrmpassword = Read-Host "Enter Directory Services Restore Password" -AsSecureString

        #------------
        #- Settings -
        #------------

        # Install Active Directory Services
        Timestamp
        Try {
            Write-Host "-= Active Directory Domain Services installing =-" -ForegroundColor Yellow
            Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
            Write-Host "-= Active Directory Domain Services installed successfully =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Active Directory Domain Services installed successfully"
        }
        Catch {
            Write-Warning -Message $("Failed to install Active Directory Domain Services. Error: " + $_.Exception.Message)
            Break;
        }

        # Configure Active Directory
        Timestamp
        Try {
            Write-Host "-= Configuring Active Directory Domain Services =-" -ForegroundColor Yellow
            Install-ADDSForest -DomainName $domainname -InstallDNS -ErrorAction Stop -NoRebootOnCompletion -SafeModeAdministratorPassword $dsrmpassword -Confirm:$false | Out-Null
            Write-Host "-= Active Directory Domain Services configured successfully =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Active Directory Domain Services configured successfully"
        }
        Catch {
            Write-Warning -Message $("Failed to configure Active Directory Domain Services. Error: " + $_.Exception.Message)
            Break;
        }

        # Add second script complete to logfile
        Timestamp
        Add-Content $logfile "$($Timestamp) - 2-Build-Active-Directory-Complete, starting script 3 =-"

        # Reboot Computer to apply settings
        Write-Host "-= Save all your work, computer rebooting in 30 seconds =-" -ForegroundColor White -BackgroundColor Red
        Sleep 30

        Try {
            Restart-Computer -ComputerName $env:computername -ErrorAction Stop
            Write-Host "Rebooting Now!!" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Rebooting Now!!"
            Break;
        }
        Catch {
            Write-Warning -Message $("Failed to restart computer $($env:computername). Error: " + $_.Exception.Message)
            Break;
        }
    } # Close 'IF ($secondcheck2)'
}# Close 'IF ($secondcheck1)'


# Add second script complete to logfile

# Check Script Progress via Logfile
$thirdcheck = Get-Content $logfile | Where-Object { $_.Contains("2-Build-Active-Directory-Complete") }

## 3-Build-Active-Directory ##

#------------
#- Settings -
#------------

# Add DNS Reverse Record
Timestamp
Try {
    Add-DnsServerPrimaryZone -NetworkId $globalsubnet -DynamicUpdate Secure -ReplicationScope Domain -ErrorAction Stop
    Write-Host "-= Successfully added in $($globalsubnet) as a reverse lookup within DNS =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully added $($globalsubnet) as a reverse lookup within DNS"
}
Catch {
    Write-Warning -Message $("Failed to create reverse DNS lookups zone for network $($globalsubnet). Error: " + $_.Exception.Message)
    Break;
}

# Add DNS Scavenging
Write-Host "-= Set DNS Scavenging =-" -ForegroundColor Yellow

Timestamp
Try {
    Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Set-DnsServerZoneAging $domainname -Aging $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Add-Content $logfile "$($Timestamp) - DNS Scavenging Complete"
}
Catch {
    Write-Warning -Message $("Failed to DNS Scavenging. Error: " + $_.Exception.Message)
    Break;
}

Get-DnsServerScavenging

Write-Host "-= DNS Scavenging Complete =-" -ForegroundColor Green

# Create Active Directory Sites and Services
Timestamp
Try {
    New-ADReplicationSubnet -Name $globalsubnet -Site "Default-First-Site-Name" -Location $subnetlocation -ErrorAction Stop
    Write-Host "-= Successfully added Subnet $($globalsubnet) with location $($subnetlocation) in AD Sites and Services =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully added Subnet $($globalsubnet) with location $($subnetlocation) in AD Sites and Services"
}
Catch {
    Write-Warning -Message $("Failed to create Subnet $($globalsubnet) in AD Sites and Services. Error: " + $_.Exception.Message)
    Break;
}

# Rename Active Directory Site
Timestamp
Try {
    Get-ADReplicationSite Default-First-Site-Name | Rename-ADObject -NewName $sitename -ErrorAction Stop
    Write-Host "-= Successfully renamed Default-First-Site-Nameto $sitename in AD Sites and Services =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully renamed Default-First-Site-Nameto $sitename in AD Sites and Services"
}
Catch {
    Write-Warning -Message $("Failed to rename site in AD Sites and Services. Error: " + $_.Exception.Message)
    Break;
}

# Add NTP settings to PDC

Timestamp

$serverpdc = Get-AdDomainController -Filter * | Where { $_.OperationMasterRoles -contains "PDCEmulator" }

IF ($serverpdc) {
    Try {
        Start-Process -FilePath "C:\Windows\System32\w32tm.exe" -ArgumentList "/config /manualpeerlist:$($ntpserver1),$($ntpserver2) /syncfromflags:MANUAL /reliable:yes /update" -ErrorAction Stop
        Stop-Service w32time -ErrorAction Stop
        sleep 2
        Start-Service w32time -ErrorAction Stop
        Write-Host "-= Successfully set NTP Servers: $($ntpserver1) and $($ntpserver2) =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - Successfully set NTP Servers: $($ntpserver1) and $($ntpserver2)"
    }
    Catch {
        Write-Warning -Message $("Failed to set NTP Servers. Error: " + $_.Exception.Message)
        Break;
    }
}

# Script Finished

Timestamp
Write-Host "-= 3-Finalize-AD-Config Complete =-" -ForegroundColor Green
Add-Content $logfile "$($Timestamp) - 3-Finalize-AD-Config Complete"
Write-Host "-= Active Directory Script Complete =-" -ForegroundColor Green
Add-Content $logfile "$($Timestamp) - Active Directory Script Complete"