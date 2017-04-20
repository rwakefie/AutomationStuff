Param
    (   
        [Parameter(Mandatory=$true)]
        [String]
        $VMName

    )

$ResourceGroup = Get-AutomationVariable -Name "ResourceGroupRWEUS2"

# Import Minimum Required Module Version(s)

    Import-Module `
        -Name AzureRM.Compute `
        -MinimumVersion 2.8.0

# Select Azure Cloud Environment
    $AzureEnv = (Get-AzureRmEnvironment).Name
# Get Azure VM Object    $VM = Get-AzureRmVm -ResourceGroupName $ResourceGroup -Name $VMName# Get New Azure VM Size for scale-up or scale-down    $currentVmSize = $vm.HardwareProfile.VmSize    $vmFamily = $currentVmSize -replace '[0-9]', '*'    $newVmSize = (Get-AzureRmVMSize -Location $vm.Location).Name |        Where-Object {$_ -Like $vmFamily} |        Out-GridView `
            -Title "Select a new VM Size ..." `
            -PassThru    $vm.HardwareProfile.VmSize = $newVmSize    $vm | Update-AzureRmVM 