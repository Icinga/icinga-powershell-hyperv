
# Invoke-IcingaCheckHyperVVirtualSwitches

## Description

Checks the state of a Hyper-V virtual switch

Invoke-IcingaCheckHyperVVirtualSwitches checks by default all available Hyper-V virtual switches for
their state, e.g. whether they are still running or the communication between the VM has not been
interrupted. But you can also use the individual parameters see below to filter out or filter in
virtual switches that you want to check or not.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Virtualization\v2
* Root\Cimv2

### Required User Groups

* Performance Monitor Users
* Hyper-V Administrator

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| Include | Array | false | @() | With this parameter you can filter virtual switches for the check in. e.g. testswitch1, testswitch1. |
| Exclude | Array | false | @() | With this parameter you can filter out virtual switches for the check. e.g. testswitch1, testswitch1. |
| Internal | SwitchParameter | false | False | Only the internal virtual switches are added to the check. |
| External | SwitchParameter | false | False | Only the external virtual switches are added to the check. |
| Warning | Array | false | @() | Warning threshold for Switch Status indicates that an element is functioning properly, but is predicating a failure. |
| Critical | Array | false | @() | Critical threshold for Switch Status indicates that an element is functioning properly, but is predicating a failure. |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed: 0 (default): Only service checks/packages with state not OK will be printed 1: Only services with not OK will be printed including OK checks of affected check packages including Package config 2: Everything will be printed regardless of the check state 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | Object |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHyperVVirtualSwitches -Verbosity 2
```

### Example Output 1

```powershell
[OK] Check package "Virtual Switches" (Match All)\_ [OK] Check package "Internal Switch" (Match All)\_ [OK] Internal Switch HealthState: OK\_ [OK] Internal Switch Status: OK\_ [OK] Check package "Internal Switch1" (Match All)\_ [OK] Internal Switch1 HealthState: OK\_ [OK] Internal Switch1 Status: OK\_ [OK] Check package "net-hq" (Match All)\_ [OK] net-hq HealthState: OK\_ [OK] net-hq Status: OK\_ [OK] Check package "net-private-test" (Match All)\_ [OK] net-private-test HealthState: OK\_ [OK] net-private-test Status: OK\_ [OK] Check package "sales-demo" (Match All)\_ [OK] sales-demo HealthState: OK\_ [OK] sales-demo Status: OK| 'netprivatetest_healthstate'=5;;25 'salesdemo_healthstate'=5;;25 'nethq_healthstate'=5;;25 'internal_switch_healthstate'=5;;25 'internal_switch1_healthstate'=5;;250
```
