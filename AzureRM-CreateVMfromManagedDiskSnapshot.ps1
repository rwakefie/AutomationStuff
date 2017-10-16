#Provide the name of the snapshot that will be used to create Managed Disks
#Provide the name of the Managed Disk
#Provide the size of the disks in GB. It should be greater than the VHD file size
#Provide the storage type for Managed Disk. PremiumLRS or StandardLRS
#Provide the name of the virtual machine

Param
    (   
        [Parameter(Mandatory=$true)][String]$snapshotName,
        [Parameter(Mandatory=$true)][String]$diskName,
        [Parameter(Mandatory=$true)][Int]$diskSize,
        [Parameter(Mandatory=$true)][String]$storageType = "StandardLRS",
        [Parameter(Mandatory=$true)][String]$virtualMachineName
    )
#Provide the subscription Id
$subscriptionId = Get-AutomationVariable -Name "SubscriptionID"

#Provide the name of your resource group
$ResourceGroup = Get-AutomationVariable -Name "ResourceGroupRWEUS2"

#Provide the name of an existing virtual network where virtual machine will be created
$virtualNetworkName = Get-AutomationVariable -Name "RWVnetEUS2"

#Provide the size of the virtual machine
#Get all the vm sizes in a region using below script:
#Get-AzureRmVMSize -Location eastus2
$virtualMachineSize = 'Standard_A1_v2'


#Set the context to the subscription Id where Managed Disk will be created
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

$snapshot = Get-AzureRmSnapshot -ResourceGroupName $resourceGroup -SnapshotName $snapshotName 
 
$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $snapshot.location -CreateOption Copy -SourceResourceId $snapshot.Id
 
$Disk = New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $resourceGroup -DiskName $diskName

###Create VM from Snapshot
#Initialize virtual machine configuration
$VirtualMachine = New-AzureRmVMConfig -VMName $virtualMachineName -VMSize $virtualMachineSize

#Use the Managed Disk Resource Id to attach it to the virtual machine. Please change the OS type to linux if OS disk has linux OS
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Windows

#Get the virtual network where virtual machine will be hosted
$vnet = Get-AzureRmVirtualNetwork -Name $virtualNetworkName -ResourceGroupName "ScorchDev"

# Create NIC in the first subnet of the virtual network 
$nic = New-AzureRmNetworkInterface -Name ($VirtualMachineName.ToLower()+'_nic') -ResourceGroupName $resourceGroup -Location $snapshot.Location -SubnetId $vnet.Subnets[0].Id
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

#Create the virtual machine with Managed Disk -
New-AzureRmVM -VM $VirtualMachine -ResourceGroupName $resourceGroup -Location $snapshot.Location