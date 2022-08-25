<#
.SYNOPSIS
    Checks the state of a Hyper-V virtual switch
.DESCRIPTION
    Invoke-IcingaCheckHyperVVirtualSwitches checks by default all available Hyper-V virtual switches for
    their state, e.g. whether they are still running or the communication between the VM has not been
    interrupted. But you can also use the individual parameters see below to filter out or filter in
    virtual switches that you want to check or not.
.ROLE
    ### WMI Permissions

    * Root\Virtualization\v2
    * Root\Cimv2

    ### Required User Groups

    * Performance Monitor Users
    * Hyper-V Administrator
.PARAMETER Include
    With this parameter you can filter virtual switches for the check in. e.g. testswitch1, testswitch1.
.PARAMETER Exclude
    With this parameter you can filter out virtual switches for the check. e.g. testswitch1, testswitch1.
.PARAMETER Internal
    Only the internal virtual switches are added to the check.
.PARAMETER External
    Only the external virtual switches are added to the check.
.PARAMETER Warning
    Warning threshold for Switch Status indicates that an element is functioning properly, but is predicating a failure.
.PARAMETER Critical
    Critical threshold for Switch Status indicates that an element is functioning properly, but is predicating a failure.
.PARAMETER AvoidEmptyCheck
    Overrides the default behaviour of the plugin in case no virtual switch is present on the system.
    Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> Invoke-IcingaCheckHyperVVirtualSwitches -Verbosity 2
    [OK] Check package "Virtual Switches" (Match All)
    \_ [OK] Check package "Internal Switch" (Match All)
        \_ [OK] Internal Switch HealthState: OK
        \_ [OK] Internal Switch Status: OK
    \_ [OK] Check package "Internal Switch1" (Match All)
        \_ [OK] Internal Switch1 HealthState: OK
        \_ [OK] Internal Switch1 Status: OK
    \_ [OK] Check package "net-hq" (Match All)
        \_ [OK] net-hq HealthState: OK
        \_ [OK] net-hq Status: OK
    \_ [OK] Check package "net-private-test" (Match All)
        \_ [OK] net-private-test HealthState: OK
        \_ [OK] net-private-test Status: OK
    \_ [OK] Check package "sales-demo" (Match All)
        \_ [OK] sales-demo HealthState: OK
        \_ [OK] sales-demo Status: OK
    | 'netprivatetest_healthstate'=5;;25 'salesdemo_healthstate'=5;;25 'nethq_healthstate'=5;;25 'internal_switch_healthstate'=5;;25 'internal_switch1_healthstate'=5;;25
    0
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
    https://github.com/Icinga/icinga-powershell-framework
#>
function Invoke-IcingaCheckHyperVVirtualSwitches()
{
    param (
        [array]$Include          = @(),
        [array]$Exclude          = @(),
        [switch]$Internal        = $FALSE,
        [switch]$External        = $FALSE,
        [ValidateSet('OK', 'Error', 'Degraded', 'Unknown', 'Pred Fail', 'Starting', 'Stopping', 'Service', 'Stressed', 'NonRecover', 'No Contact', 'Lost Comm')]
        [array]$Warning          = @(),
        [ValidateSet('OK', 'Error', 'Degraded', 'Unknown', 'Pred Fail', 'Starting', 'Stopping', 'Service', 'Stressed', 'NonRecover', 'No Contact', 'Lost Comm')]
        [array]$Critical         = @(),
        [switch]$AvoidEmptyCheck = $FALSE,
        [switch]$NoPerfData      = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity               = 0
    );

    # Create a basic CheckPackage, where all following CheckPackages and checks are appended
    $CheckPackage    = New-IcingaCheckPackage -Name 'Virtual Switches' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader -IgnoreEmptyPackage:$AvoidEmptyCheck;
    # Get all the necessary information from the provider regarding virtual switches
    $VirtualSwitches = Get-IcingaHypervVirtualSwitches `
        -IncludeSwitches $Include `
        -ExcludeSwitches $Exclude `
        -InternalSwitches:$Internal `
        -ExternalSwitches:$External;

    $LatestSwitch = '';
    # We loop through all available virtual switches
    foreach ($switch in $VirtualSwitches.Keys) {
        $VirtualSwitch = $VirtualSwitches[$switch];
        $CheckPackageName = $VirtualSwitch.ElementName;
        if ($LatestSwitch -eq $VirtualSwitch.ElementName) {
            $CheckPackageName = ([string]::Format('{0}1', $VirtualSwitch.ElementName));
        }

        $LatestSwitch = $VirtualSwitch.ElementName;
        # Create a CheckPackage for each individual virtual switch
        $SwitchCheckPackage = New-IcingaCheckPackage -Name $CheckPackageName -OperatorAnd -Verbose $Verbosity;

        $SwitchStatusCheck = New-IcingaCheck `
            -Name ([string]::Format('{0} Status', $CheckPackageName)) `
            -Value $VirtualSwitch.Status `
            -NoPerfData;

        if ($Warning -Contains $VirtualSwitch.Status) {
            $SwitchStatusCheck.SetWarning() | Out-Null;
        }

        if ($Critical -Contains $VirtualSwitch.Status) {
            $SwitchStatusCheck.SetCritical() | Out-Null;
        }

        $SwitchCheckPackage.AddCheck($SwitchStatusCheck);

        $SwitchCheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} HealthState', $CheckPackageName)) `
                    -Value $VirtualSwitch.HealthState `
                    -Translation $HypervProviderEnums.VMHealthState `
                    -MetricIndex $CheckPackageName `
                    -MetricName 'health'
            ).CritIfNotMatch(
                $HypervProviderEnums.VMHealthStateName.OK
            )
        );

        # After each loop we add the single virtual switch CheckPackage to our basic CheckPackage
        $CheckPackage.AddCheck($SwitchCheckPackage);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
