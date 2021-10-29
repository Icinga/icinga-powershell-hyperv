# Icinga Powershell Hyperv CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](30-Upgrading-Plugins.md)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-hyperv/milestones?state=closed).

## 1.1.0 (2021-11-09)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/2?closed=1)

### Bugfixes

* [#41](https://github.com/Icinga/icinga-powershell-hyperv/issues/41) Fixes `UNKNOWN` on overcommitment check, in case no virtual machines are present on the host

### Enhancements

* [#42](https://github.com/Icinga/icinga-powershell-hyperv/issues/42) Adds switch to `Invoke-IcingaCheckHyperVSnapshot` and `Invoke-IcingaCheckHyperVVirtualSwitches` to mitigate state from `Unknown` to `Ok`, in case no virtual machines or virtual switches are present on the system

## 1.0.0 (2021-06-10)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/1?closed=1)

### New Plugins

This release adds the following new plugins:

* Invoke-IcingaCheckHyperVHealth
* Invoke-IcingaCheckHyperVOverCommitment
* Invoke-IcingaCheckHyperVSnapshot
* Invoke-IcingaCheckHyperVVirtualSwitches
* Invoke-IcingaCheckHyperVVMHealth
