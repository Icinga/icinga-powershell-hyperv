<#
.SYNOPSIS
    Determines the current state of the Hyper-V virtual machine.
.DESCRIPTION
    Invoke-IcingaCheckHyperVVMHealth determines the current state of all available Hyper-V virtual machines by default.
    It also offers you the possibility to ex/include virtual machines with wildcard search i.e. if you enter the
    following ``-IncludeVms *test*`` as parameter, only ``VMs`` will be added to the check, which the name of the
    VMs contains this wildcard name.
.ROLE
    ### WMI Permissions

    * Root\Virtualization\v2
    * Root\Cimv2

    ### Performance Counter

    * Processor(*)\% processor time

    ### Required User Groups

    * Performance Monitor Users
    * Hyper-V Administrator
.PARAMETER IncludeVms
    Include only virtual machines with a specific name. Supports wildcard usage (*)
.PARAMETER ExcludeVms
    Exclude virtual machines with a specific name. Supports wildcard usage (*)
.PARAMETER ActiveVms
    Include only virtual machines that are currently running
.PARAMETER SkipVMHeartbeat
    Skips the current virtual machine heartbeat status check.
.PARAMETER VmEnabledState
    Critical threshold for the Hyper-V VM current status
.PARAMETER NegateVMState
    Negates the VmEnabledState of this plugin and will then report all Vms
    CRITICAL, in case they are not matching the VmEnabledState.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> icinga { Invoke-IcingaCheckHyperVVMHealth -ActiveVms -IncludeVms '*sales*' -Verbosity 2 }
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
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>
function Invoke-IcingaCheckHyperVVMHealth()
{
    param (
        [array]$IncludeVms        = @(),
        [array]$ExcludeVms        = @(),
        [switch]$ActiveVms        = $FALSE,
        [switch]$NoPerfData       = $FALSE,
        [switch]$SkipVMHeartbeat  = $FALSE,
        [ValidateSet('Unknown', 'Other', 'Enabled', 'Disabled', 'Shutting Down', 'Not Applicable', 'Enabled but Offline', 'In Test', 'Deferred', 'Quiesce', 'Starting')]
        $VmEnabledState           = $null,
        [switch]$NegateVMState    = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity                = 0
    );

    # Create a main CheckPackage, under which all following CheckPackages are added
    $CheckPackage     = New-IcingaCheckPackage -Name 'Virtual Computers' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
    $HiddenCheckPackage = New-IcingaCheckPackage -Name 'Hidden PerfData' -Hidden;
    # We get all information about the virtual machine from our provider
    $VirtualComputers = Get-IcingaVirtualComputerInfo -IncludeVms $IncludeVms -ExcludeVms $ExcludeVms -ActiveVms:$ActiveVms;

    foreach ($vm in $VirtualComputers.VMs.Keys) {
        $virtualComputer = $VirtualComputers.VMs[$vm];
        $VMCheckPackage  = New-IcingaCheckPackage -Name $vm -OperatorAnd -Verbose $Verbosity;

        # Heartbeat check is always OK if the VM is not started
        if ($virtualComputer.EnabledState -eq $HypervProviderEnums.VMEnabledStateName.Enabled) {
            $HeartBeatCheck = New-IcingaCheck `
                -Name ([string]::Format('{0} Heartbeat', $vm)) `
                -Value $virtualComputer.Heartbeat `
                -Translation $HypervProviderEnums.VMHeartbeat;

            if ($SkipVMHeartbeat -eq $FALSE) {
                $HeartBeatCheck.WarnIfMatch(
                    $HypervProviderEnums.VMHeartbeatName.'No Contact'
                ).WarnIfMatch(
                    $HypervProviderEnums.VMHeartbeatName.'Lost Communication'
                ).CritIfMatch(
                    $HypervProviderEnums.VMHeartbeatName.Error
                ) | Out-Null;
            }

            $VMCheckPackage.AddCheck($HeartbeatCheck);
        }

        $EnabledStateCheck = New-IcingaCheck `
            -Name ([string]::Format('{0} State', $vm)) `
            -Value $virtualComputer.EnabledState `
            -Translation $HypervProviderEnums.VMEnabledState;

        if ($NegateVMState) {
            $EnabledStateCheck.CritIfNotMatch($HypervProviderEnums.VMEnabledStateName[[string]$VmEnabledState]) | Out-Null;
        } else {
            $EnabledStateCheck.CritIfMatch($HypervProviderEnums.VMEnabledStateName[[string]$VmEnabledState]) | Out-Null;
        }

        $VMCheckPackage.AddCheck($EnabledStateCheck);

        $VMCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} HealthState', $vm)) `
                    -Value $virtualComputer.HealthState `
                    -Translation $HypervProviderEnums.VMHealthState
            ).WarnIfNotMatch(
                $HypervProviderEnums.VMHealthStateName.OK
            )
        );

        $CheckPackage.AddCheck($VMCheckPackage);
    }

    # we create here a hidden checkpackage
    if ($VirtualComputers.Summary.TotalVms -ne 0) {
        foreach ($item in $VirtualComputers.Summary.Keys) {
            if ($item -eq 'AccessDeniedVms') {
                continue;
            }

            $HiddenCheckPackage.AddCheck(
                (
                    New-IcingaCheck -Name $item -Value ($VirtualComputers.Summary[$item])
                )
            );
        }
    }

    if ($HiddenCheckPackage.HasChecks()) {
        $CheckPackage.AddCheck($HiddenCheckPackage);
    }

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
