workflow Shutdown-Start-VMs-By-Resource-Group
{
	Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $AzureResourceGroup,
		[Parameter(Mandatory=$true)]
        [Boolean]
		$Shutdown
    )
	
$connectionName = "AzureRunAsConnection"
 # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
	
	if($Shutdown -eq $true){
		Write-Output "Stopping VMs in '$($AzureResourceGroup)' resource group";
	}
	else{
		Write-Output "Starting VMs in '$($AzureResourceGroup)' resource group";
	}
	
	#ARM VMs
	Write-Output "ARM VMs:";
	  
	Get-AzureRmVM -ResourceGroupName $AzureResourceGroup | ForEach-Object {
	
		if($Shutdown -eq $true){
			
				Write-Output "Stopping '$($_.Name)' ...";
				Stop-AzureRmVM -ResourceGroupName $AzureResourceGroup -Name $_.Name -Force;
		}
		else{
			Write-Output "Starting '$($_.Name)' ...";			
			Start-AzureRmVM -ResourceGroupName $AzureResourceGroup -Name $_.Name;			
		}			
	}
}