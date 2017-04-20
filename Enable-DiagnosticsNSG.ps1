
$StorageAccountName = Get-AutomationVariable -Name "diagStorageAccount"
$StorageAccountResourceGroup = Get-AutomationVariable -Name "diagResourceGroup"
$RetentionDays = "7"

try
{
	$ErrorActionPreference = "Stop"
	$Error.Clear()

	$StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $StorageAccountResourceGroup -Name $StorageAccountName
	$NetworkSecurityGroups = Get-AzureRmNetworkSecurityGroup

	foreach ($NetworkSecurityGroup in $NetworkSecurityGroups)
	{
		$DiagnosticSettings = Get-AzureRmDiagnosticSetting -ResourceId $NetworkSecurityGroup.Id
		if ($DiagnosticSettings.StorageAccountId -eq $null)
		{
			if($NetworkSecurityGroup.ResourceGroupName.Contains($StorageAccountResourceGroup))
			{
				Set-AzureRmDiagnosticSetting -ResourceId $NetworkSecurityGroup.Id -StorageAccountId $StorageAccount.Id -Enabled $true -Categories 'NetworkSecurityGroupEvent','NetworkSecurityGroupRuleCounter' -RetentionEnabled $true -RetentionInDays $RetentionDays
			}
		}
	}
}
catch
{
	Write-Output $Error
}

