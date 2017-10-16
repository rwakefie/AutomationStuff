$vm = "RWHyperV"
$resourceGroup = "RWEUS2"
$nicName = "RWHyperV3"


Stop-AzureRmVM -Name $vm -ResourceGroupName $resourceGroup

$vm = Get-AzureRmVm -Name $vm -ResourceGroupName $resourceGroup
#if VM already has nic, set it to primary
$VM.NetworkProfile.NetworkInterfaces.Item(0).primary = $true

# Get info for the back end subnet
$myVnet = Get-AzureRmVirtualNetwork -Name "RWVnetEUS2" -ResourceGroupName "ScorchDev"
$backEnd = $myVnet.Subnets|?{$_.Name -eq 'RWBE'}

# Create a virtual NIC
$myNic3 = New-AzureRmNetworkInterface -ResourceGroupName $resourceGroup `
    -Name $nicName `
    -Location "EastUs2" `
    -SubnetId $backEnd.Id

# Get the ID of the new virtual NIC and add to VM
$nicId = (Get-AzureRmNetworkInterface -ResourceGroupName $resourceGroup -Name $nicName).Id
Add-AzureRmVMNetworkInterface -VM $vm -Id $nicId | Update-AzureRmVm -ResourceGroupName $resourceGroup