Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $VMName

    )
#Setting Variables 
$ResourceGroup = Get-AutomationVariable -Name "ResourceGroupRWEUS2"
$Location = (Get-AzureRmResourceGroup $ResourceGroup).location 
$VM = Get-AzureRmVm -ResourceGroupName $ResourceGroup -Name $VMName
$DataDiskName = $vm.StorageProfile.OsDisk.Name 
$TimeStamp = (Get-Date -Format o).Replace(":","-").Replace(".","-").ToLower()
$SnapshotName = $DataDiskName + $TimeStamp  

#Get disk for Snapshot
$Disk = Get-AzureRmDisk -ResourceGroupName $ResourceGroup -DiskName $dataDiskName

#Snapshot Configuration
$Snapshot =  New-AzureRmSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $Location 

#Take Snapshot
New-AzureRmSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $ResourceGroup

#View Snapshot
#Get-AzureRmSnapshot -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroup