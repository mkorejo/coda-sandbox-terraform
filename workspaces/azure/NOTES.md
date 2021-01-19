## [Snapshot an Azure VM scale set instance](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-faq#how-do-i-take-a-snapshot-of-a-virtual-machine-scale-set-instance)
```
az snapshot list

$rgname = "mkorejo-sandbox-resources"
$vmssname = "mkorejo-sandbox-nginx-plus"
$Id = 0
$location = "Central US"

$vmss1 = Get-AzVmssVM -ResourceGroupName $rgname -VMScaleSetName $vmssname -InstanceId $Id
$snapshotconfig = New-AzSnapshotConfig -Location $location -AccountType Standard_LRS -OsType Windows -CreateOption Copy -SourceUri $vmss1.StorageProfile.OsDisk.ManagedDisk.id
New-AzSnapshot -ResourceGroupName $rgname -SnapshotName 'nginx-plus-base' -Snapshot $snapshotconfig
```

## Create Shared Image Gallery, Image Definition, and Image Version
```

```