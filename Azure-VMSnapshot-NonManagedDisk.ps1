Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $VMName

    )

$ResourceGroup = Get-AutomationVariable -Name "ResourceGroupRWEUS2"


# Get VM Info in Variable

$VM = Get-AzureRmVm -ResourceGroupName $ResourceGroup -Name $VMName


# Stop VM if running

$VMStatus = (Get-AzureRmVm -ResourceGroupName $ResourceGroup -Name $VMName -Status).Statuses

if ($VMStatus[-1].Code -ne "PowerState/deallocated") {
    $VM | Stop-AzureRmVm -Force
}

# Identify VM disks

$VMDisks = @()

$VMDisks += $VM.StorageProfile.OSDisk.vhd.Uri

Foreach ($VMDisk in $VM.StorageProfile.DataDisks) {

        $VMDisks += $VMDisk.vhd.Uri
}

# Define Context for Storage Account

$StorageAccountName = $vmDisks[0].Substring(8).Split('.')[0]

$StorageContext = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageAccountName).Context

# Create "backups" container in Storage Account

$DestContainer = "backups-" + (Get-Date -Format o).Replace(":","-").Replace(".","-").ToLower()

New-AzureStorageContainer -Name $DestContainer -Context $StorageContext

# Create backup copy of each VM disk to backup container

ForEach ($I in $VMDisks) {

    $SrcContainer = $I.Split('/')[3]

    $SrcBlob = $I.Split('/')[4]

    Start-AzureStorageBlobCopy `
        -Context $StorageContext `
        -SrcContainer $SrcContainer `
        -SrcBlob $SrcBlob `
        -DestContainer $DestContainer

}

# Wait for copy to complete for each disk

ForEach ($I in $vmDisks) {

    $srcContainer = $I.Split('/')[3]

    $srcBlob = $I.Split('/')[4]

    Get-AzureStorageBlobCopyState `
        -Context $StorageContext `
        -Container $DestContainer `
        -Blob $SrcBlob `
        -WaitForComplete

}

# Start VM

if ($vmStatus[-1].Code -ne "PowerState/deallocated") {
    $vm | Start-AzureRmVm 
}