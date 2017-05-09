
$Temp = "C:\Temp"
if(!(Test-Path -Path $Temp )){
   New-Item -ItemType directory -Path $Temp
}

Test-Path -Path C:\Temp 

#Download ARM Template files from Git
Invoke-WebRequest "http://raw.github.com/rwakefie/AutomationStuff/blob/master/ARM/Deploy.params.json" -OutFile "$Temp\Deploy.params.json"
$WebClient = New-Object -TypeName System.Net.WebClient
$URI = "http://github.com/rwakefie/AutomationStuff/blob/master/ARM/Deploy.params.json"
$TargetPath = "$Temp\Deploy.params.json"
$WebClient.DownloadFile($URI, $TargetPath)

$JSONContent = Get-Content $targetPath | ConvertFrom-Json
$JSONContent.update | 
