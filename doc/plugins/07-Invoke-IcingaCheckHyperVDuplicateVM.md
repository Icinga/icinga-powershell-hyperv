# Invoke-IcingaCheckHyperVDuplicateVM

## Description

Checks the Hyper-V cluster for virtual machines with the same name

Invoke-IcingaCheckHyperVDuplicateVM will ensure your cluster is not running virtual machines with the
same name and ouptut every single VM as critical in case there is more than one configured

## Permissions

To execute this plugin you will require to grant the following user permissions.

### Required User Groups

* Hyper-V Administrator

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| IncludeVMs | Array | false | @() | Allows to filter for virtual machines which are included in the check. All others are dropped |
| ExcludeVMs | Array | false | @() | Allows to filter for virtual machines to never check for them and always being dropped |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHyperVDuplicateVM -Verbosity 2
```

### Example Output 1

```powershell
[CRITICAL] Duplicate VM List: 1 Critical [CRITICAL] VM "vmicinga" (2) (All must be [OK])
\_ [CRITICAL] VM "vmicinga": 2
| 'vmicinga::ifw_hypervduplicatevm::duplicate'=2;;    
```


