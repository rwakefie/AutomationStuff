Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $VMName

    )

$ResourceGroup = Get-AutomationVariable -Name "ResourceGroupRWEUS2"

# Select VM to re-provision
$VM = Get-AzureRmVm -ResourceGroupName $ResourceGroup -Name $VMName
$Location = $VM.Location

# Create a new Azure availability set
    $AvailSetName = $VMName + "-" + "AvailSet"

    $AvailSet = New-AzureRmAvailabilitySet -Name $AvailSetName -ResourceGroupName $ResourceGroup -Location $Location

# Stop and Deprovision existing Azure VM, retaining Disks

    $VM | Stop-AzureRmVm -Force

    $VM | Remove-AzureRmVm -Force

# Set VM config to include new Availability Set

    $AvailSetRef = New-Object Microsoft.Azure.Management.Compute.Models.SubResource

    $AvailSetRef.Id = $AvailSet.Id

    $VM.AvailabilitySetReference = $AvailSetRef # To remove VM from Availability Set, set to $null

# Clean-up VM config to reflect deployment from attached disks

    $VM.StorageProfile.OSDisk.Name = $VMName

    $VM.StorageProfile.OSDisk.CreateOption = "Attach"

    $VM.StorageProfile.DataDisks | 
        ForEach-Object { $_.CreateOption = "Attach" }

    $VM.StorageProfile.ImageReference = $null

    $VM.OSProfile = $null

# Re-provision VM with attached disks

    $VM | New-AzureRmVm -ResourceGroupName $ResourceGroup -Location $Location

