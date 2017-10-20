$SA = Get-AzureRmStorageAccount 

$UMD = $SA | Get-AzureStorageContainer | Get-AzureStorageBlob | Where {$_.Name -like '*.vhd'} 
$UMVHDS = $UMD | Where {$_.ICloudBlob.Properties.LeaseStatus -eq "Unlocked"} 
$MVHDS = Get-AzureRmDisk 
$MVHD = $MVHDS | Where {$_.OwnerId -eq $null}

$UMVHDS | Remove-AzureStorageBlob
$MVHD | Remove-AzureRmDisk 

/subscriptions/6462f71c-9cb5-4f4c-bc31-22dc79fbb342/resourceGroups/RWEUS2/providers/Microsoft.Automation/automationAccounts/AutomationAccount/jobs/19e2310a-f1b3-4603-82e3-c51198b7a964
