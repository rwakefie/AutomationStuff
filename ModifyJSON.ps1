Set-Location 
$JSONContent = Get-Content 
$Temp = "C:\Temp"
if(!(Test-Path -Path $Temp )){
   New-Item -ItemType directory -Path $Temp
}

Test-Path -Path C:\Temp 

#Download ARM Template files from Git
$WebClient = New-Object -TypeName System.Net.WebClient
$uri = "https://github.com/mycompany/myrepo/blob/master/myfile.zip"
$targetPath = $Temp
$WebClient.DownloadFile($uri, $targetPath)