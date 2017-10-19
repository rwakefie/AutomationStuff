$vmName = "Win7nosysprep"
$rgName = "RWEUS2"
$location = "EastUS2"
$imageName = "Win7x86nounattend"

Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force

Set-AzureRmVm -ResourceGroupName $rgName -Name $vmName -Generalized

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName

$image = New-AzureRmImageConfig -Location $location -SourceVirtualMachineId $vm.ID 

New-AzureRmImage -Image $image -ImageName $imageName -ResourceGroupName $rgName