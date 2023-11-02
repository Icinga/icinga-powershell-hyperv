# Invoke-IcingaCheckHyperVVMHealth

## Description

Determines the current state of the Hyper-V virtual machine.

Invoke-IcingaCheckHyperVVMHealth determines the current state of all available Hyper-V virtual machines by default.
It also offers you the possibility to ex/include virtual machines with wildcard search i.e. if you enter the
following ``-IncludeVms *test*`` as parameter, only ``VMs`` will be added to the check, which the name of the
VMs contains this wildcard name.

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
| WarningActiveVms | Object | false |  | Allows to monitor on how many active VM's are currently present and throws a warning in case it is within the threshold |
| CriticalActiveVms | Object | false |  | Allows to monitor on how many active VM's are currently present and throws a warning in case it is within the threshold |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin. |
| SkipVMHeartbeat | SwitchParameter | false | False | Skips the current virtual machine heartbeat status check. |
| VmEnabledState | Object | false |  | Critical threshold for the Hyper-V VM current status |
| NegateVMState | SwitchParameter | false | False | Negates the VmEnabledState of this plugin and will then report all Vms CRITICAL, in case they are not matching the VmEnabledState. |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
icinga { Invoke-IcingaCheckHyperVVMHealth -ActiveVms -IncludeVms '*sales*' -Verbosity 2 }
```

### Example Output 1

```powershell
[OK] Check package "Virtual Computers" (Match All)
\_ [OK] Check package "vm-01" (Match All)
    \_ [OK] vm-01 HealthState: OK
    \_ [OK] vm-01 Heartbeat: OK
    \_ [OK] vm-01 State: Enabled
\_ [OK] Check package "vm-02" (Match All)
    \_ [OK] vm-02 HealthState: OK
    \_ [OK] vm-02 Heartbeat: OK
    \_ [OK] vm-02 State: Enabled
\_ [OK] Check package "vm-03" (Match All)
    \_ [OK] vm-03 HealthState: OK
    \_ [OK] vm-03 Heartbeat: OK
    \_ [OK] vm-03 State: Enabled
\_ [OK] Check package "vm-04" (Match All)
    \_ [OK] vm-04 HealthState: OK
    \_ [OK] vm-04 Heartbeat: OK
    \_ [OK] vm-04 State: Enabled
\_ [OK] Check package "vm-05" (Match All)
    \_ [OK] vm-05 HealthState: OK
    \_ [OK] vm-05 Heartbeat: OK
    \_ [OK] vm-05 State: Enabled
\_ [OK] Check package "vm-06" (Match All)
    \_ [OK] vm-06 HealthState: OK
    \_ [OK] vm-06 Heartbeat: OK
    \_ [OK] vm-06 State: Enabled
| 'vm01_healthstate'=5;; 'vm01_state'=2;; 'vm01_heartbeat'=2;; 'vm02_heartbeat'=2;; 'vm02_state'=2;; 'vm02_healthstate'=5;; 'vm03_heartbeat'=2;;
'vm03_healthstate'=5;; 'vm03_state'=2;; 'vm04_heartbeat'=2;; 'vm04_state'=2;; 'vm04_healthstate'=5;; 'vm05_state'=2;; 'vm05_healthstate'=5;; 'vm05_heart
beat'=2;; 'vm06_healthstate'=5;; 'vm06_state'=2;; 'vm06_heartbeat'=2;;
0    
```


