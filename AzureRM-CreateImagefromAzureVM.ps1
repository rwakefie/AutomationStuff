$vmName = "Win7x86test"
$rgName = "TR"
$location = "EastUS2"
$imageName = "Win7x86Generalized"

Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force

Set-AzureRmVm -ResourceGroupName $rgName -Name $vmName -Generalized

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName

$image = New-AzureRmImageConfig -Location $location -SourceVirtualMachineId $vm.ID 

New-AzureRmImage -Image $image -ImageName $imageName -ResourceGroupName $rgName