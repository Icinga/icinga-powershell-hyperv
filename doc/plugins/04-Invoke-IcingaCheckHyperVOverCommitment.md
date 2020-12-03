
# Invoke-IcingaCheckHyperVOverCommitment

## Description

Calculates CPU, RAM and Storage overcommitment of a Hyper-V Server

`Invoke-IcingaCheckHyperVOverCommitment` determines the load of a Hyper-V server,
which is consumed by all running virtual machines. With the `IncludeVms` and `ExcludeVms` parameters you can exclude or
include any VMs you want, depending on your needs. Here is an important thing to note, all PerfCounter values are only the
overcommitment values, i.e. from these values the 100% has already been subtracted, e.g. if the CPU overcommitment is 50% in
the plugin output, then with the subtracted value the overcommit would be 150% percent. In this case we would have 50% overcommit
over the maximum value that the Hyper-V server can normally provide.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Virtualization\v2
* Root\Cimv2

### Performance Counter

* Processor(*)\% processor time

### Required User Groups

* Performance Log Users
* Hyper-V Administrator

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| IncludeVms | Array | false | @() | Include only virtual machines with a specific name. Supports wildcard usage (*) |
| ExcludeVms | Array | false | @() | Exclude virtual machines with a specific name. Supports wildcard usage (*) |
| ActiveVms | SwitchParameter | false | False | Include only virtual machines that are currently running |
| CPUCoreOCWarn | Object | false |  | Warning threshold for Hyper-V CPU Cores overcommitment. |
| CPUCoreOCCrit | Object | false |  | Critical threshold for Hyper-V CPU Cores overcommitment. |
| CPUOCPercentWarn | Object | false |  | Warning threshold for Hyper-V average CPU overcommitment. |
| CPUOCPercentCrit | Object | false |  | Critical threshold for Hyper-V average CPU overcommitment. |
| RAMOCByteWarn | Object | false |  | Used to specify a WARNING threshold for the Hyper-V RAM overcommitment in Byte. |
| RAMOCByteCrit | Object | false |  | Used to specify a CRITICAL threshold for the Hyper-V RAM overcommitment in Byte. |
| RAMOCPercentWarn | Object | false |  | Used to specify a WARNING threshold for the Hyper-V average RAM overcommitment. |
| RAMOCPercentCrit | Object | false |  | Used to specify a CRITICAL threshold for the Hyper-V average RAM overcommitment. |
| StorageOCByteWarn | Object | false |  | Used to specify a WARNING threshold for the Hyper-V Storage overcommitment in Byte. |
| StorageOCByteCrit | Object | false |  | Used to specify a CRITICAL threshold for the Hyper-V Storage overcommitment in Byte. |
| StorageOCPercentWarn | Object | false |  | Used to specify a WARNING threshold for the Hyper-V average Storage overcommitment. |
| StorageOCPercentCrit | Object | false |  | Used to specify a CRITICAL threshold for the Hyper-V average Storage overcommitment. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin. Default to FALSE. |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHyperVOverCommitment -Verbosity 2
```

### Example Output 1

```powershell
[OK] Check package "Hyper-V Overcommitment" (Match All)\_ [OK] Check package "CPUOverCommit" (Match All)\_ [OK] hyper-v-01 Used Cores: 46c\_ [OK] hyper-v-01 Used Percent: 91.67%\_ [OK] Check package "RAMOverCommit" (Match All)\_ [OK] hyper-v-01 Used Bytes: 45056B\_ [OK] hyper-v-01 Used Percent: 0%\_ [OK] Check package "StorageOverCommit" (Match All)\_ [OK] Check package "Partition C: Overcommitment" (Match All)\_ [OK] C: Used Bytes: 140486311936B\_ [OK] C: Used Percent: 0%\_ [OK] Check package "Partition I: Overcommitment" (Match All)\_ [OK] I: Used Bytes: 9979156899840B\_ [OK] I: Used Percent: 353.8%| 'hyperv01_used_cores'=46c;;;0;24 'hyperv01_used_percent'=91.67%;;;0;100 'hyperv01_used_bytes'=45056B;;;0;60100288512 'hyperv01_used_percent'=0%;;;0;100 'i_used_bytes'=9979156899840B;;;0;2199021158400 'i_used_percent'=353.8%;;;0;100 'c_used_percent'=0%;;;0;100 'c_used_bytes'=140486311936B;;;0;4789643509760
```
