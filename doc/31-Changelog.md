# Icinga Powershell Hyperv CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](30-Upgrading-Plugins.md)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-hyperv/milestones?state=closed).

## 1.3.0 (2023-08-01)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/4?closed=1)

### Bugfixes

* [#67](https://github.com/Icinga/icinga-powershell-hyperv/issues/67) Fixes Hyper-V Snapshot plugin throwing an exception in case vdisks were deleted from disk or removed from the virtual machine object in Hyper-V Manager
* [#69](https://github.com/Icinga/icinga-powershell-hyperv/issues/69) Fixes a freeze during `Test-IcingaHyperVInstalled` call on some machines, as `Get-WindowsFeature` sometimes takes forever to resolve the feature list

### Enhancements

* [#70](https://github.com/Icinga/icinga-powershell-hyperv/pull/70) Adds new plugin `Invoke-IcingaCheckHyperVDuplicateVM` to check for duplicate virtual machines on your Hyper-V node or cluster, printing critical for every single virtual machine found with duplicates
* [#72](https://github.com/Icinga/icinga-powershell-hyperv/pull/72) Adds support to check the cluster node count for the Hyper-V environment with `Invoke-IcingaCheckHyperVHealth`

#### New Plugin Integrations

* Invoke-IcingaCheckHyperVDuplicateVM

## 1.2.0 (2022-08-30)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/3?closed=1)

### Bugfixes

* [#64](https://github.com/Icinga/icinga-powershell-hyperv/issues/64) Fixes Hyper-V Health plugin always reporting critical because of service exit code `1077`, which simply means this service was never started on the host before and can safely be ignored

### Enhancements

* [#60](https://github.com/Icinga/icinga-powershell-hyperv/issues/60) Adds support for providing a different `Username` and `Password` for `Invoke-IcingaCheckHyperVVMM`, to run the check as different user
* [#63](https://github.com/Icinga/icinga-powershell-hyperv/pull/63) Updates performance metrics to Icinga for Windows v1.10.0 layout and provides default dashboards for Grafana and Icinga Web
* [#65](https://github.com/Icinga/icinga-powershell-hyperv/pull/65) Updates config and dependencies for Icinga for Windows v1.10.0

### Grafana Dashboards

#### New Dashboards

* Hyper-V Base
* Windows-HyperV-Web

#### New Plugin Integrations

* Invoke-IcingaCheckHyperVHealth
* Invoke-IcingaCheckHyperVOverCommitment
* Invoke-IcingaCheckHyperVSnapshot
* Invoke-IcingaCheckHyperVVirtualSwitches
* Invoke-IcingaCheckHyperVVMHealth

## 1.1.0 (2022-05-03)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/2?closed=1)

### Bugfixes

* [#41](https://github.com/Icinga/icinga-powershell-hyperv/issues/41) Fixes `UNKNOWN` on overcommitment check, in case no virtual machines are present on the host
* [#49](https://github.com/Icinga/icinga-powershell-hyperv/issues/49) Fixes an exception in case machines on the system are present with the identical name
* [#52](https://github.com/Icinga/icinga-powershell-hyperv/issues/52) Fixes `This argument does not support the % unit` for `Total Snapshot Size`, caused by duplicate entry
* [#53](https://github.com/Icinga/icinga-powershell-hyperv/pull/53) Fixes exception in case no permission is granted to snapshot directory
* [#55](https://github.com/Icinga/icinga-powershell-hyperv/pull/55) Fixes JEA error which detected `ScriptBlocks` in the plugin collection
* [#57](https://github.com/Icinga/icinga-powershell-hyperv/pull/57) Fixes memory unit which was calculated in `MB` instead of `Bytes` and fixes CPU overcommitment, which could result in negative usage values if there is not overcommitment

### Enhancements

* [#40](https://github.com/Icinga/icinga-powershell-hyperv/issues/40) Adds new plugin `Invoke-IcingaCheckHyperVVMM` to check the state of the Virtual Machine Manager (VMM) for each host if being installed
* [#42](https://github.com/Icinga/icinga-powershell-hyperv/issues/42) Adds switch to `Invoke-IcingaCheckHyperVSnapshot` and `Invoke-IcingaCheckHyperVVirtualSwitches` to mitigate state from `Unknown` to `Ok`, in case no virtual machines or virtual switches are present on the system
* [#58](https://github.com/Icinga/icinga-powershell-hyperv/pull/58) Adds support for Icinga for Windows v1.9.0 module isolation

## 1.0.0 (2021-06-10)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/1?closed=1)

### New Plugins

This release adds the following new plugins:

* Invoke-IcingaCheckHyperVHealth
* Invoke-IcingaCheckHyperVOverCommitment
* Invoke-IcingaCheckHyperVSnapshot
* Invoke-IcingaCheckHyperVVirtualSwitches
* Invoke-IcingaCheckHyperVVMHealth
