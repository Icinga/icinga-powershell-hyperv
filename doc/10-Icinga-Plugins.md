# Icinga Plugins

Below you will find a documentation for every single available plugin provided by this repository. Most of the plugins allow the usage of default Icinga threshold range handling, which is defined as follows:

| Argument | Throws error on | Ok range                     |
| ---      | ---             | ---                          |
| 20       | < 0 or > 20     | 0 .. 20                      |
| 20:      | < 20            | between 20 .. ∞              |
| ~:20     | > 20            | between -∞ .. 20             |
| 30:40    | < 30 or > 40    | between {30 .. 40}           |
| `@30:40  | ≥ 30 and ≤ 40   | outside -∞ .. 29 and 41 .. ∞ |

Please ensure that you will escape the `@` if you are configuring it on the Icinga side. To do so, you will simply have to write an *\`* before the `@` symbol: \``@`

To test thresholds with different input values, you can use the Framework Cmdlet `Get-IcingaHelpThresholds`.

Each plugin ships with a constant Framework argument `-ThresholdInterval`. This can be used to modify the value your thresholds are compared against from the current, fetched value to one collected over time by the Icinga for Windows daemon. In case you [Collect Metrics Over Time](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/) for specific time intervals, you can for example set the argument to `15m` to get the average value of 15m as base for your monitoring values. Please note that in this example, you will require to have collected the `15m` average for `Invoke-IcingaCheckCPU`.

```powershell
icinga> icinga { Invoke-IcingaCheckCPU -Warning 20 -Critical 40 -Core _Total -ThresholdInterval 15m }

[WARNING] CPU Load: [WARNING] Core Total (29,14817700%)
\_ [WARNING] Core Total: 29,14817700% is greater than threshold 20% (15m avg.)
| 'core_total_1'=31.545677%;;;0;100 'core_total_15'=29.148177%;20;40;0;100 'core_total_5'=28.827410%;;;0;100 'core_total_20'=30.032942%;;;0;100 'core_total_3'=27.731669%;;;0;100 'core_total'=33.87817%;;;0;100
```

| Plugin Name | Description |
| ---         | --- |
| [Invoke-IcingaCheckHyperVDuplicateVM](plugins/07-Invoke-IcingaCheckHyperVDuplicateVM.md) | Checks the Hyper-V cluster for virtual machines with the same name |
| [Invoke-IcingaCheckHyperVHealth](plugins/01-Invoke-IcingaCheckHyperVHealth.md) | Checks the general availability, state and health of the Hyper-V server. |
| [Invoke-IcingaCheckHyperVOverCommitment](plugins/04-Invoke-IcingaCheckHyperVOverCommitment.md) | Calculates CPU, RAM and Storage overcommitment of a Hyper-V Server |
| [Invoke-IcingaCheckHyperVSnapshot](plugins/05-Invoke-IcingaCheckHyperVSnapshot.md) | Monitors age, disk space, count and file size of VM snapshots. |
| [Invoke-IcingaCheckHyperVVirtualSwitches](plugins/03-Invoke-IcingaCheckHyperVVirtualSwitches.md) | Checks the state of a Hyper-V virtual switch |
| [Invoke-IcingaCheckHyperVVMHealth](plugins/02-Invoke-IcingaCheckHyperVVMHealth.md) | Determines the current state of the Hyper-V virtual machine. |
| [Invoke-IcingaCheckHyperVVMM](plugins/06-Invoke-IcingaCheckHyperVVMM.md) | Plugin for checking the Virtual Machine Manager (VMM) host to    fetch all hosts assigned to view their status from VMM view |
