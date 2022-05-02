# Icinga Powershell Hyperv CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](30-Upgrading-Plugins.md)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-hyperv/milestones?state=closed).

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
