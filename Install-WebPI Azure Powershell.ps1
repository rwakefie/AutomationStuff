$DLL = Test-Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$DLL2 = Test-Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
If ($DLL -eq $false) {

Write-Output "Required files not present, installing..."

$WebPiURL = "https://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi"
Invoke-WebRequest -Uri $WebPiURL -OutFile $env:TEMP\WebPlatformInstaller_amd64_en-US.msi

Start-Process msiexec -ArgumentList @("/i $env:TEMP\WebPlatformInstaller_amd64_en-US.msi", "/quiet", "/norestart") -Wait

$WebPiCMD = "$env:ProgramFiles\Microsoft\Web Platform Installer\"
Start-Process $WebPiCMD\WebpiCmd.exe -ArgumentList @("/install", "/products:WindowsAzurePowershell", "/AcceptEula") -wait

}

If ((Test-Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll") -eq $True) {
    Write-Output "Microsoft.IdentityModel.Clients.ActiveDirectory.dll is Present"
    } 
Else {
    Write-Output "Microsoft.IdentityModel.Clients.ActiveDirectory.dll is still missing"
    }

If ((Test-Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll") -eq $True) {
    Write-Output "Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll is Present"
    } 
Else {
    Write-Output "Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll is still missing" 
    }


