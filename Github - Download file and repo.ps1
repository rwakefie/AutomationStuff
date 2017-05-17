#Download ASEB repo
$Location = $env:TEMP
$url = "https://github.com/rwakefie/Blueprints-PaaS-ASE/archive/master.zip"
$output = "$Location\master.zip"
$start_time = Get-Date
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

#Extract zip file
Expand-Archive -LiteralPath $output -DestinationPath $location

$ScriptsLocation = "$Location\Blueprints-PaaS-ASE-master\Blueprints-PaaS-ASE-master\ase-ilb-blueprint"
$Location = $env:TEMP
$url = "https://raw.githubusercontent.com/mayurshintre/Blueprints-PaaS-ASE/master/ase-ilb-blueprint/azuredeploy.parameters.json"
$output = "$Location\azuredeploy.parameters.json"
$start_time = Get-Date
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"