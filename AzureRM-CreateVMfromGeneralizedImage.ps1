Param
    (   
        [Parameter(Mandatory=$true)][String]$vmName,
        [Parameter(Mandatory=$true)][String]$computerName,
        [Parameter(Mandatory=$true)][String]$destinationResourceGroup
    )

$VnetRG = Get-AutomationVariable -Name "VnetRG"
$virtualNetworkName = Get-AutomationVariable -Name "RWVnetEUS2"
$Cred = Get-AutomationPSCredential -Name "DesktopCred"
$location = "EastUS2"
$virtualMachineSize = 'Standard_A1_v2'
$imageName = "win7x86nounattend"
$image = Get-AzureRMImage -ImageName $imageName -ResourceGroupName "RWEUS2"

#Virtual Networking
$virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $VnetRG -Name $virtualNetworkName
$nic = New-AzureRmNetworkInterface -ResourceGroupName $destinationResourceGroup -Name $vmName -Location $location -SubnetId $virtualNetwork.Subnets[0].Id
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $VnetRG -Name $virtualNetworkName

#Set VM Properties 
$VirtualMachine = New-AzureRmVMConfig -VMName $vmName -VMSize $virtualMachineSize
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -Id $image.Id
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine  -StorageAccountType StandardLRS -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $computerName -Credential $cred #-TimeZone "Central Standard Time" -EnableAutoUpdate -ProvisionVMAgent
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

#Create VM
New-AzureRmVM -VM $VirtualMachine -ResourceGroupName $destinationResourceGroup -Location $location

