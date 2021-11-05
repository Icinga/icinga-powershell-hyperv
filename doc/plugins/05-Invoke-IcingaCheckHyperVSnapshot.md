
# Invoke-IcingaCheckHyperVSnapshot

## Description

Monitors age, disk space, count and file size of VM snapshots.

Invoke-IcingaCheckHyperVSnapshot monitors age, disk space, count, each snapshots file size and the total size of the snapshots for each vms.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Virtualization\v2
* Root\Cimv2

### Performance Counter

* Processor(*)\% processor time

### Required User Groups

* Performance Monitor Users
* Hyper-V Administrator

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| IncludeVms | Array | false | @() | Include only virtual machines with a specific name. Supports wildcard usage (*) |
| ExcludeVms | Array | false | @() | Exclude virtual machines with a specific name. Supports wildcard usage (*) |
| ActiveVms | SwitchParameter | false | False | Include only virtual machines that are currently running |
| CountSnapshotWarning | Object | false |  | Warning threshold for each individual vms how many snapshots they may have. |
| CountSnapshotCritical | Object | false |  | Critical threshold for each individual vms how many snapshots they may have |
| CreationTimeWarning | Object | false |  | Warning threshold for each individual vms snapshots, how old they must be in seconds. |
| CreationTimeCritical | Object | false |  | Critical threshold for each individual vms snapshots, how old they must be in seconds. |
| TotalSnapshotSizeWarning | Object | false |  | Warning threshold for each individual vms total snapshots size. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| TotalSnapshotSizeCritical | Object | false |  | Critical threshold for each individual vms total snapshots size. It is also possible to enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B) |
| SnapshotSizeWarning | Object | false |  | Warning threshold for each individual vms snapshot size in Byte. |
| SnapshotSizeCritical | Object | false |  | Critical threshold for each individual vms snapshot size in Byte. |
| SnapshotSizePredictionWarning | Object | false |  | Warning threshold for predicting the size of snapshots taken for each Vm before the partition becomes full. |
| SnapshotSizePredictionCritical | Object | false |  | Critical threshold for predicting the size of snapshots taken for each Vm before the partition becomes full. |
| EmptySnapshotCritical | SwitchParameter | false | False | Sets the CheckPackage CRITICAL if the Hyper-V VM has no snapshots. |
| AvoidEmptyCheck | SwitchParameter | false | False | Overrides the default behaviour of the plugin in case no virtual machine is present on the system. Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin. |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
icinga { Invoke-IcingaCheckHyperVSnapshot -ActiveVms -IncludeVms '*vm*' -Verbosity 2 }
```

### Example Output 1

```powershell
[OK] Check package "VM Snapshots" (Match All)\_ [OK] Check package "icinga-vm" (Match All)\_ [OK] Check package "Bright" (Match All)\_ [OK] Snapshot Creation Time [18.02.2020 10:21:19]: 21859435s\_ [OK] Snapshot Size: 51090B\_ [OK] Check package "icinga-vm-snapshot-1" (Match All)\_ [OK] Snapshot Creation Time [15.10.2020 15:43:41]: 1107693s\_ [OK] Snapshot Size: 51697B\_ [OK] icinga-vm I: Count: 6\_ [OK] icinga-vm I: Snapshots count prediction: 25473978.46\_ [OK] icinga-vm I: TotalSnapshot Size: 309038B\_ [OK] icinga-vm: Latest Snapshot Creation Delta: 1130216s\_ [OK] Check package "icinga-vm-snapshot-2" (Match All)\_ [OK] Snapshot Creation Time [15.10.2020 15:41:26]: 1107828s\_ [OK] Snapshot Size: 51569B\_ [OK] Check package "icinga-vm-snapshot-3" (Match All)\_ [OK] Snapshot Creation Time [21.02.2020 10:44:33]: 21598841s\_ [OK] Snapshot Size: 51412B\_ [OK] Check package "icinga-vm-snapshot-4" (Match All)\_ [OK] Snapshot Creation Time [18.02.2020 10:11:02]: 21860052s\_ [OK] Snapshot Size: 51002B\_ [OK] Check package "icinga-vm-snapshot-5" (Match All)\_ [OK] Snapshot Creation Time [18.02.2020 09:22:52]: 21862942s\_ [OK] Snapshot Size: 52268B\_ [OK] Check package "icinga-vm" (Match All)\_ [OK] Check package "icinga-vm-snapshot-1" (Match All)\_ [OK] Snapshot Creation Time [18.02.2020 10:11:21]: 21860034s\_ [OK] Snapshot Size: 48674B\_ [OK] icinga-vm I: Count: 2\_ [OK] icinga-vm I: Snapshots count prediction: 27065675.15\_ [OK] icinga-vm I: TotalSnapshot Size: 96954B\_ [OK] icinga-vm: Latest Snapshot Creation Delta: 9007s\_ [OK] Check package "icinga-vm-snapshot-2" (Match All)\_ [OK] Snapshot Creation Time [18.02.2020 09:22:47]: 21862948s\_ [OK] Snapshot Size: 48280B| 'icingavm_i_count'=6;; 'icingavm_i_snapshots_size_prediction'=25473978.46;; 'icingavm_i_totalsnapshot_size'=309038B;; 'icingavm_latest_snapshots_creation_delta'=1130216s;; 'icingavm_i_count'=2;; 'icingavm_i_snapshots_size_prediction'=27065675.15;; 'icingavm_i_totalsnapshot_size'=96954B;; 'icingavm_latest_snapshots_creation_delta'=9007s;;0
```
