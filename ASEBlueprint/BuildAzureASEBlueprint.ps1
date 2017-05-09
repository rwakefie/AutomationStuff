#Location of Docker Files
$Location = "C:\Git\AutomationStuff\AutomationStuff"

#Name of Dockerfile
$Dockerfile = "MyPowerShellContainerBuildDockerfile"

#Download ARM Template files from Git
$WebClient = New-Object -TypeName System.Net.WebClient
$uri = "https://github.com/mycompany/myrepo/blob/master/myfile.zip"
$targetPath = "c:\temp"
$WebClient.DownloadFile($uri, $targetPath)


#Build Container Host
$VMResourceGroupName = 'RWEUS2'
$TemplateFile = "C:\Users\rowake\Microsoft\OneDrive - Microsoft\Scripts\Azure\Delete.json"
$TemplateParameterFile = "C:\Users\rowake\Microsoft\OneDrive - Microsoft\Scripts\Azure\delete.params.json"


New-AzureRmResourceGroupDeployment -Name InitialDeployment `
                                   -ResourceGroupName $VMResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -TemplateParameterFile $TemplateParameterFile 
#Check for Windows Server Core Image
$dockerimages = @()
$dockerimages = docker images microsoft/windowsservercore:latest
    if ($dockerimages[1].contains("microsoft/windowsservercore") -eq $false) {
        Write-Host "Image not found, pulling image"; docker pull microsoft/windowsservercore
    }

#Provision the Container
Set-Location -Path $Location
docker build -t rwakefie/mypowershellcontainer -f $dockerfile .





#testing
<<<<<<< HEAD
=======
docker build -t rwakefie/runpowershellcode -f RunPowerShellCode .

>>>>>>> 4a5b7fb61e5833ebf86638d7d3014c6ffd58a060
docker build -t rwakefie/mypowershellcontainer -f BuildPowerShellContainer .

docker build -t rwakefie/aseblueprintexecute -f RunPowerShellCode .





