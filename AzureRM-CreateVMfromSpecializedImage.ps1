Param ([Parameter(Mandatory=$true)][String]$vmName,[Parameter(Mandatory=$true)][String]$DestinationResourseGroup )


$VnetRG = Get-AutomationVariable -Name "VnetRG"
$virtualNetworkName = Get-AutomationVariable -Name "RWVnetEUS2"
$location = "EastUS2"
$virtualMachineSize = 'Standard_A1_v2'

#Disk Configuration
$sourceUri = "https://imagerepositorydemo.blob.core.windows.net/images/Win 7 x86 Base.vhd"
$osDiskName = "win7x86test"
$osDisk = New-AzureRmDisk -DiskName $osDiskName -Disk `
    (New-AzureRmDiskConfig -AccountType StandardLRS  -Location $location -CreateOption Import `
    -SourceUri $sourceUri) `
    -ResourceGroupName $destinationRG

#Virtual Networking
$virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $VnetRG -Name $virtualNetworkName
$nic = New-AzureRmNetworkInterface -ResourceGroupName $DestinationResourseGroup -Name $vmName -Location $location -SubnetId $virtualNetwork.Subnets[0].Id
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $VnetRG -Name $virtualNetworkName

#Build VM Config
$VirtualMachine = New-AzureRmVMConfig -VMName $vmName -VMSize $virtualMachineSize
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -ManagedDiskId $osDisk.Id -StorageAccountType StandardLRS -DiskSizeInGB 128 -CreateOption Attach -Windows

#Create VM
New-AzureRmVM -ResourceGroupName $DestinationResourseGroup -Location $location -VM $VirtualMachine