# Invoke-IcingaCheckHyperVHealth

## Description

Checks the general availability, state and health of the Hyper-V server.

Invoke-IcingaCheckHyperVHealth determines the availability, state and health of the Hyper-V server.
It also checks if required Hyper-V services are running including the VMM agent.

## Permissions

To execute this plugin you will require to grant the following user permissions.

### WMI Permissions

* Root\Virtualization\v2
* Root\Cimv2

### Required User Groups

* Hyper-V Administrator

## Arguments

| Argument | Type | Required | Default | Description |
| ---      | ---  | ---      | ---     | ---         |
| NodeCountWarning | Object | false |  | Allows to throw warning in case the Hyper-V cluster node count is not matching this threshold |
| NodeCountCritical | Object | false |  | Allows to throw critical in case the Hyper-V cluster node count is not matching this threshold |
| NoPerfData | SwitchParameter | false | False | Disables the performance data output of this plugin |
| Verbosity | Object | false | 0 | Changes the behavior of the plugin output which check states are printed:<br /> 0 (default): Only service checks/packages with state not OK will be printed<br /> 1: Only services with not OK will be printed including OK checks of affected check packages including Package config<br /> 2: Everything will be printed regardless of the check state<br /> 3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK]) |
| ThresholdInterval | String |  |  | Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described [here](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/06-Collect-Metrics-over-Time/). An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring. |

## Examples

### Example Command 1

```powershell
Invoke-IcingaCheckHyperVHealth -Verbosity 2
```

### Example Output 1

```powershell
[CRITICAL] Check package "Hyper-V Health Package" (Match All) - [CRITICAL] vmms Communication Status
\_ [OK] Cluster Node Count: 1
\_ [CRITICAL] Check package "vmms Status" (Match All)
    \_ [OK] vmms Health State: OK
\_ [OK] Check package "Services Package" (Match All)
    \_ [OK] vmcompute Status: Running
    \_ [OK] vmicguestinterface Status: Stopped
    \_ [OK] vmicheartbeat Status: Stopped
    \_ [OK] vmickvpexchange Status: Stopped
    \_ [OK] vmicrdv Status: Stopped
    \_ [OK] vmicshutdown Status: Stopped
    \_ [OK] vmictimesync Status: Stopped
    \_ [OK] vmicvmsession Status: Stopped
    \_ [OK] vmicvss Status: Stopped
    \_ [OK] vmms Status: Running    
```


