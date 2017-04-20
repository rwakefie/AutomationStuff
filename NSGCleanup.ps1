$StorageAccountName = $null
$NetworkSecurityGroups = Get-AzureRmNetworkSecurityGroup

	foreach ($NetworkSecurityGroup in $NetworkSecurityGroups)
	{
		$DiagnosticSettings = Get-AzureRmDiagnosticSetting -ResourceId $NetworkSecurityGroup.Id
			if($NetworkSecurityGroup.ResourceGroupName.Contains($StorageAccountResourceGroup))
			{
				Set-AzureRmDiagnosticSetting -ResourceId $NetworkSecurityGroup.Id -Enabled $false -StorageAccountId $null
			}
		}
