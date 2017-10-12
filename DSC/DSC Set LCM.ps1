$ComputerName = "RWASR2"

Set-DscLocalConfigurationManager -Path C:\DSCMetaConfigs -ComputerName $ComputerName

#Need WMF 5 installed
$PSVersionTable.PSVersion