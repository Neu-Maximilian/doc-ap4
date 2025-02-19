#--------------------------------------------------------------------------
#- Created by:             David Rodriguez                                -
#- Blog:                   www.sysadmintutorials.com                      -
#- Modified by:            Maximilian Neu                                 -
#- Modified for:           Secondary Domain Controller Setup              -
#--------------------------------------------------------------------------
#-------------
#- Variables -                                         -
#-------------

# Network Variables
$ethipaddress = '172.16.10.21' # static IP Address of the secondary DC
$ethprefixlength = '24' # subnet mask - 24 = 255.255.255.0
$ethdefaultgw = '172.16.10.254' # default gateway
$ethdns = '172.16.10.20,127.0.0.1' # Primary DC first, then localhost
$globalsubnet = '172.16.10.0/24' # Global Subnet will be used in DNS Reverse Record and AD Sites and Services Subnet
$subnetlocation = 'Colmar'
$sitename = 'Colmar-Site'

# Active Directory Variables
$domainname = 'haut-rhin.gouv' # enter in your active directory domain
$primaryDC = 'VAD68COL01' # name of the primary DC

# Remote Desktop Variable
$enablerdp = 'yes' # to enable RDP, set this variable to yes. to disable RDP, set this variable to no

# Hostname Variables
$computername = 'VAD68COL02' # secondary DC name

# Timestamp
Function Timestamp {
    $Global:timestamp = Get-Date -Format "dd-MM-yyy_hh:mm:ss"
}

# Log File Location
$logfile = "C:\AD-Install\Windows-2022-AD-Secondary-DC-Deployment-log.txt"

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
    Add-Content $logfile "$($Timestamp) - Starting Secondary DC Configuration Script"

    ## 1-Basic-Server-Config ##

    # Set Network
    Timestamp
    Try {
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
        $currentIP = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4

        Write-Host "-= Using network adapter: $($adapter.Name) =-" -ForegroundColor Yellow
        Add-Content $logfile "$($Timestamp) - Using network adapter: $($adapter.Name)"

        if ($currentIP.IPAddress -eq $ethipaddress -and 
            $currentIP.PrefixLength -eq $ethprefixlength) {
            Write-Host "-= Network settings already configured, skipping =-" -ForegroundColor Yellow
            Add-Content $logfile "$($Timestamp) - Network settings already configured, no changes needed"
        }
        else {
            New-NetIPAddress -IPAddress $ethipaddress -PrefixLength $ethprefixlength -DefaultGateway $ethdefaultgw -InterfaceIndex $adapter.ifIndex -ErrorAction Stop | Out-Null
            Set-DNSClientServerAddress -ServerAddresses $ethdns.Split(',') -InterfaceIndex $adapter.ifIndex -ErrorAction Stop
            Write-Host "-= IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns) =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - IP Address successfully set"
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

    # Set Hostname
    Timestamp
    Try {
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
    Add-Content $logfile "$($Timestamp) - 1-Basic-Server-Config-Complete"
        
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
            Write-Warning -Message $("Failed to restart computer. Error: " + $_.Exception.Message)
            Break;
        }
    }
    else {
        Write-Warning "Restart postponed. Changes won't be applied until the server restarts."
        Add-Content $logfile "$($Timestamp) - Restart postponed by user"
    }
}

# Check Script Progress via Logfile
$secondcheck1 = Get-Content $logfile | Where-Object { $_.Contains("1-Basic-Server-Config-Complete") }

IF ($secondcheck1) {
    $secondcheck2 = Get-Content $logfile | Where-Object { $_.Contains("2-Join-Domain-Complete") }

    IF (!$secondcheck2) {
        ## 2-Join-Domain ##

        Timestamp
        
        # Install Active Directory Services
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

        # Join Domain
        Timestamp
        Try {
            $domainCred = Get-Credential -Message "Enter Domain Admin credentials"
            
            Write-Host "-= Joining domain $($domainname) =-" -ForegroundColor Yellow
            Add-Computer -DomainName $domainname -Credential $domainCred -ErrorAction Stop
            
            Write-Host "-= Successfully joined domain $($domainname) =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Successfully joined domain $($domainname)"
        }
        Catch {
            Write-Warning -Message $("Failed to join domain. Error: " + $_.Exception.Message)
            Break;
        }

        # Promote to DC
        Timestamp
        Try {
            $domainCred = Get-Credential -Message "Enter Domain Admin credentials"
            $dsrmpassword = Read-Host "Enter Directory Services Restore Password" -AsSecureString
            
            Write-Host "-= Installing Active Directory Domain Services and promoting to Domain Controller =-" -ForegroundColor Yellow
            Install-ADDSDomainController -DomainName $domainname -InstallDNS -Credential $domainCred -SafeModeAdministratorPassword $dsrmpassword -NoRebootOnCompletion -NoGlobalCatalog:$false -CreateDnsDelegation:$false -CriticalReplicationOnly:$false

            Write-Host "-= Successfully promoted to Domain Controller =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Successfully promoted to Domain Controller"
        }
        Catch {
            Write-Warning -Message $("Failed to promote to Domain Controller. Error: " + $_.Exception.Message)
            Break;
        }

        # Add second script complete to logfile
        Timestamp
        Add-Content $logfile "$($Timestamp) - 2-Join-Domain-Complete"

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
            Write-Warning -Message $("Failed to restart computer. Error: " + $_.Exception.Message)
            Break;
        }
    }
}

# Script Finished
Timestamp
Write-Host "-= Active Directory Secondary DC Setup Complete =-" -ForegroundColor Green
Add-Content $logfile "$($Timestamp) - Active Directory Secondary DC Setup Complete"