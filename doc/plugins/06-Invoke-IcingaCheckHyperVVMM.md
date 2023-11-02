# Invoke-IcingaCheckHyperVVMM

## Description

Plugin for checking the Virtual Machine Manager (VMM) host to
   fetch all hosts assigned to view their status from VMM view

Checks hosts assigned to the Virtual Machine Manager, allowing to
properly fetch the current status of these hosts from the VMM view
and respond to possible error states

## Permissions

No special permissions required.

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Hostname | String | false |  | The VMM host to check against |
| Username | String | false |  | Allows to specify a username to run this check with specific user credentials. This is optional. |
| Password | SecureString | false |  | The password used to authenticate the specified user for the `Username` argument. Empty passwords are not supported. |
| IncludeHost | Array | false | @() | List of hosts to be included within the check output for checking |
| ExcludeHost | Array | false | @() | List of hosts to be excluded from the check output for checking |
| VMMState | Array | false | @() | A list of states which will return `Ok` if being present. States not inside the list will return `Critical` |
| AvoidEmptyCheck | SwitchParameter | false | False | Overrides the default behaviour of the plugin in case no VMM host is returned by the plugin. Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set. |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHyperVVMM -Hostname 'example-hyperv' -VMMState 'Ok', 'Updating' -Verbosity 3;
```

### Example Output 1

```powershell
[OK] Check package "VMM Overview" (Match All)
    \_ [OK] example-hyperv-node1 status is Ok
    \_ [OK] example-hyperv-node2 status is Updating    
```


