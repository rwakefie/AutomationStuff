$ResourceGroupName = "RWEUS2"
$AutomationAccountName = "AutomationAccount"
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SendEmail' -ContentLink 'https://www.powershellgallery.com/api/v2/package/SendEmail/1.3'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'xDisk' -ContentLink 'https://www.powershellgallery.com/api/v2/package/xdisk'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'xStorage' -ContentLink 'https://www.powershellgallery.com/api/v2/package/xStorage'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'xComputerManagement' -ContentLink 'https://www.powershellgallery.com/api/v2/package/xComputerManagement'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'nx' -ContentLink 'https://www.powershellgallery.com/api/v2/package/nx/1.0'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'nxNetworking' -ContentLink 'https://www.powershellgallery.com/api/v2/package/nxNetworking/1.1'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'nxComputerManagement' -ContentLink 'https://www.powershellgallery.com/api/v2/package/nxComputerManagement/1.1'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'AzureRM.profile' -ContentLink 'https://www.powershellgallery.com/api/v2/package/AzureRM.profile/2.8.0'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'AzureRM.RecoveryServices' -ContentLink 'https://www.powershellgallery.com/api/v2/package/AzureRM.RecoveryServices/2.8.0'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'xDSCDomainjoin' -ContentLink 'https://www.powershellgallery.com/api/v2/package/xDSCDomainjoin/1.1'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'xPendingReboot' -ContentLink 'https://www.powershellgallery.com/api/v2/package/xPendingReboot/0.3.0.0'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SCOrchDev-Exception' -ContentLink 'https://www.powershellgallery.com/api/v2/package/SCOrchDev-Exception/2.2.1'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SCOrchDev-Utility' -ContentLink 'https://www.powershellgallery.com/api/v2/package/SCOrchDev-Utility/2.2.0'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SCOrchDev-File' -ContentLink 'https://www.powershellgallery.com/api/v2/package/SCOrchDev-File/2.1.0'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'SCOrchDev-Networking' -ContentLink 'https://www.powershellgallery.com/api/v2/package/SCOrchDev-Networking/2.1.0'
New-AzureRmAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name 'xPSDesiredStateConfiguration' -ContentLink 'https://www.powershellgallery.com/api/v2/package/xPSDesiredStateConfiguration/6.1.0.0'




