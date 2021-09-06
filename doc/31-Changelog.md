# Icinga Powershell Hyperv CHANGELOG

**The latest release announcements are available on [https://icinga.com/blog/](https://icinga.com/blog/).**

Please read the [upgrading](30-Upgrading-Plugins.md)
documentation before upgrading to a new release.

Released closed milestones can be found on [GitHub](https://github.com/Icinga/icinga-powershell-hyperv/milestones?state=closed).

## 1.1.0 (2021-09-07)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/2?closed=1)

### Bugfixes

* [#41](https://github.com/Icinga/icinga-powershell-hyperv/issues/41) Fixes `UNKNOWN` on overcommitment check, in case no virtual machines are present on the host

## 1.0.0 (2021-06-10)

[Issue and PRs](https://github.com/Icinga/icinga-powershell-hyperv/milestone/1?closed=1)

### New Plugins

This release adds the following new plugins:

* Invoke-IcingaCheckHyperVHealth
* Invoke-IcingaCheckHyperVOverCommitment
* Invoke-IcingaCheckHyperVSnapshot
* Invoke-IcingaCheckHyperVVirtualSwitches
* Invoke-IcingaCheckHyperVVMHealth
