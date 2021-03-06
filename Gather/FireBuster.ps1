<#
.SYNOPSIS
This script is part of Nishang. FireBuster is a PowerShell script that does egress testing. It is to be run on the target machine.

.DESCRIPTION
FireBuster sends packets to FireListener, which hosts a listening server. By default, FireBuster sends packets to all ports (which could be VERY slow).

.EXAMPLE
.\FireBuster.ps1 10.10.10.10 1000-1020

.EXAMPLE
.\FireBuster.ps1 10.10.10.10 1000-1020 -Verbose
Use above for increased verbosity.

.LINK
http://labofapenetrationtester.blogspot.com/
http://code.google.com/p/nishang
http://roo7break.co.uk

.NOTES
Major part of the script is written by Nikhil ShreeKumar (@roo7break)
#>

[CmdletBinding()]
Param( [Parameter(Position = 0, Mandatory = $True)] [String] $targetip = $(throw "Please specify an EndPoint (Host or IP Address)"),
       [Parameter(Position = 1, Mandatory = $False)] [String] $portrange = "1-65535")

function FireBuster{
    
    $ErrorActionPreference = 'SilentlyContinue'    
    [int] $lowport = $portrange.split("-")[0]
    [int] $highport = $portrange.split("-")[1]
	
    $hostaddr = [system.net.IPAddress]::Parse($targetip)
    Write-Verbose "Trying to connect to $hostaddr from $lowport to $highport"
	[int] $ports = 0
	Write-Host "Sending...."
	for($ports=$lowport; $ports -le $highport ; $ports++){
        try{
            Write-Verbose "Trying port $ports"
            $client = New-Object System.Net.Sockets.TcpClient
            $beginConnect = $client.BeginConnect($hostaddr,$ports,$null,$null)
            $TimeOut = 300
            if($client.Connected)
            {
                Write-Host "Connected to port $ports" -ForegroundColor Green
            }
            else 
            {
                Start-Sleep -Milli $TimeOut
                if($client.Connected) 
                {
                    Write-Host "Connected to port $ports" -ForegroundColor Green
                }
            }
            $client.Close()
        }catch { Write-Error $Error[0]}
    }        
	Write-Host "Data sent to all ports"
}

FireBuster