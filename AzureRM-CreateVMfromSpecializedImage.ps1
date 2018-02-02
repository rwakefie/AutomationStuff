#Param ([Parameter(Mandatory=$true)][String]$vmName,[Parameter(Mandatory=$true)][String]$DestinationResourseGroup )


##Varibales 
$vmName = ""
$DestinationResourseGroup = "RWEUS2"
$subnetName = "RWBE"
$VnetRG = "ScorchDev"
$virtualNetworkName = "RWVnetEUS2"
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
$subnetID = $virtualNetwork.Subnets | Where {$_.Name -eq "$subnetName"}
$nic = New-AzureRmNetworkInterface -ResourceGroupName $DestinationResourseGroup -Name $vmName -Location $location -SubnetId $subnetID.ID
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $DestinationResourseGroup -Name $virtualNetworkName

#Build VM Config
$VirtualMachine = New-AzureRmVMConfig -VMName $vmName -VMSize $virtualMachineSize
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -ManagedDiskId $osDisk.Id -StorageAccountType StandardLRS -DiskSizeInGB 128 -CreateOption Attach -Windows

#Create VM
New-AzureRmVM -ResourceGroupName $DestinationResourseGroup -Location $location -VM $VirtualMachine