Param ([Parameter(Mandatory=$true)][String]$vmName,[Parameter(Mandatory=$true)][String]$DestinationResourseGroup )

$virtualNetworkName = Get-AutomationVariable -Name "RWVnetEUS2"
$VnetRG = Get-AutomationVariable -Name "VnetRG"
$Cred = Get-AutomationPSCredential -Name "DesktopCred"
$location = "EastUS2"
$virtualMachineSize = 'Standard_A1_v2'

#Virtual Networking
$virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $VnetRG -Name $virtualNetworkName
$nic = New-AzureRmNetworkInterface -ResourceGroupName $DestinationResourseGroup -Name $vmName -Location $location -SubnetId $vnet.Subnets[0].Id
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $VnetRG -Name $virtualNetworkName

#Build VM Config
$VirtualMachine = New-AzureRmVMConfig -VMName $vmName -VMSize $virtualMachineSize
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id
$VirtualMachine = Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred
$VirtualMachine = Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsdesktop" -Offer "Windows-10" -Skus "RS2-Pro" -Version latest

#Create VM
New-AzureRmVM -ResourceGroupName $DestinationResourseGroup -Location $location -VM $VirtualMachine


