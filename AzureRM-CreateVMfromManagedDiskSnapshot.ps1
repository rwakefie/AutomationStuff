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
$virtualMachineSize = 'Standard_DS3'



#Provide the Azure region (e.g. westus) where Managed Disks will be located.
#This location should be same as the snapshot location
#Get all the Azure location using command below:
#Get-AzureRmLocation
$location = 'eastus2'

#Set the context to the subscription Id where Managed Disk will be created
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

$snapshot = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName 
 
$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $location -CreateOption Copy -SourceResourceId $snapshot.Id
 
New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $diskName