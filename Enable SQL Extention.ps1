$SubID         = "6462f71c-9cb5-4f4c-bc31-22dc79fbb342"
Set-ExecutionPolicy remotesigned

Login-AzureRmAccount
Get-AzureRmSubscription 
Select-AzureRmSubscription -SubscriptionID $SubID

$RG = "RWEUS2"
$VMname = "RWSQL1"
Set-AzureRmVMSqlServerExtension -ResourceGroupName $RG -VMName $VMname -Name "SQLIaasExtension" -Version "1.2" -Location "East US 2"