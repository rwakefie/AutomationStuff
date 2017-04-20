$nodes = ("RWSSD1", "RWSSD2")
Invoke-Command $nodes {Install-WindowsFeature Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools} 
Invoke-Command $nodes {Install-WindowsFeature FS-FileServer}

Test-Cluster -node $nodes

#Create Cluster
New-Cluster -Name "S2D" -Node $nodes –NoStorage –StaticAddress 172.16.1.200

#Configure Cloud Witness
Set-ClusterQuorum –CloudWitness –AccountName rwcloudwitness -AccessKey "UaTavn86MNc78Cxl/DJY4f9Rg1TUX5gzKOuPNkgEVQxS6yvkQf3oQH30qgKgm1R6P2fh/PzumTYc/bpF1Q74XA=="

#List Unpooled Drives
Get-PhysicalDisk -CanPool $true | sort Model

#Enable Storage Spaces Direct
Enable-ClusterStorageSpacesDirect


#Create 2 100GB Volumes
Get-ClusterNode |% {New-Volume -StoragePoolFriendlyName S2D* -FriendlyName $_ -FileSystem CSVFS_ReFS -Size 100GB -PhysicalDiskRedundancy 1}

#Get Disk/Volume Info
Get-VirtualDisk
Get-Volume

#Delete Volume if Needed
# Remove-VirtualDisk RWSSD1

#Scale-Out
Add-ClusterNode -Name RWSSD3
Get-PhysicalDisk -CanPool $true | sort Model
Get-StoragePool S* | Get-PhysicalDisk | Sort Model
Get-StorageJob
Get-StorageSubSystem Cluster* | Get-StorageHealthReport

#Scale-In
Remove-ClusterNode RWSSD3

#List Cluster Nodes
Get-ClusterNode

#List Unpooled Drives
Get-PhysicalDisk -CanPool $true | sort Model

#List Pooled Drives
Get-StoragePool S* | Get-PhysicalDisk | Sort Model
$Disks = Get-StoragePool S* | Get-PhysicalDisk | Sort Model ; $Disks.count
Remove-Variable Disks


####FT####
$Cluster = Get-StorageSubSystem Cluster*
$Volumes = Get-StorageSubSystem Cluster* | Get-Volume
Get-ClusterNode

$StorageNodes = $Cluster | Get-StorageNode
ForEach ($Node in $StorageNodes) {
    $Node | Get-PhysicalDisk -PhysicallyConnected | Sort Model | Group MediaType -NoElement
    Write-Host -ForegroundColor Yellow $Node Name
    Write-Host "-----"
}

#Shows number of disks
Get-StoragePool s2d* | Get-PhysicalDisk | Group OperationalStatus -NoElement
#Shows status of each disk
Get-StoragePool s2d* | Get-PhysicalDisk | Sort Model, OperationalStatus

Get-VirtualDisk

$Cluster | Debug-StorageSubSystem
$Volumes | Debug-Volume

Get-StorageJob | ? JobState -EQ Running

Get-PhysicalDisk -Usage Retired 

#Get Storage Health Report
Get-StorageSubSystem Cluster* | Get-StorageHealthReport


####Cleanup####
Remove-VirtualDisk RWSSD1
Remove-VirtualDisk RWSSD2
Disable-ClusterStorageSpacesDirect
Get-Cluster S2D | Remove-Cluster #Remove from Failover Cluster Manager
Get-StoragePool -FriendlyName "S2D on S2D" | Set-StoragePool -IsReadOnly $false
Get-StoragePool -FriendlyName "S2D on S2D" | Remove-StoragePool
#Get-VirtualDisk | Where {$_.OperationalStatus -eq "Detached"} | Remove-VirtualDisk

