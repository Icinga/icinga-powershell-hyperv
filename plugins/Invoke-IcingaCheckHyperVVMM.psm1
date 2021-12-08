<#
.SYNOPSIS
	Plugin for checking the Virtual Machine Manager (VMM) host to
    fetch all hosts assigned to view their status from VMM view
.DESCRIPTION
    Checks hosts assigned to the Virtual Machine Manager, allowing to
    properly fetch the current status of these hosts from the VMM view
    and respond to possible error states
.PARAMETER Hostname
    The VMM host to check against
.PARAMETER IncludeHost
    List of hosts to be included within the check output for checking
.PARAMETER ExcludeHost
    List of hosts to be excluded from the check output for checking
.PARAMETER VMMState
    A list of states which will return `Ok` if being present. States not inside
    the list will return `Critical`
.PARAMETER AvoidEmptyCheck
    Overrides the default behaviour of the plugin in case no VMM host is returned by the plugin.
    Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> Invoke-IcingaCheckHyperVVMM -Hostname 'example-hyperv' -VMMState 'Ok', 'Updating' -Verbosity 3;

    [OK] Check package "VMM Overview" (Match All)
        \_ [OK] example-hyperv-node1 status is Ok
        \_ [OK] example-hyperv-node2 status is Updating
#>
function Invoke-IcingaCheckHyperVVMM()
{
    param (
        [string]$Hostname        = '',
        [array]$IncludeHost      = @(),
        [array]$ExcludeHost      = @(),
        [ValidateSet('Unknown', 'NotResponding', 'Reassociating', 'Removing', 'Updating', 'Pending', 'MaintenanceMode', 'NeedsAttention', 'Ok', 'Limited')]
        [array]$VMMState         = @(),
        [switch]$AvoidEmptyCheck = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity               = 0
    );

    $VMMList      = Get-IcingaHyperVVMMState -Hostname $Hostname -IncludeHost $IncludeHost -ExcludeHost $ExcludeHost;
    $CheckPackage = New-IcingaCheckPackage -Name 'VMM Overview' -Verbose $Verbosity -OperatorAnd -AddSummaryHeader -IgnoreEmptyPackage:$AvoidEmptyCheck;

    foreach ($VMMHost in $VMMList.Keys) {
        $CurrentVMMState = $VMMList[$VMMHost];
        $IcingaCheck     = New-IcingaCheck -Name $VMMHost -NoPerfData;

        if ($VMMState.Count -ne 0) {
            if ($VMMState -NotContains $CurrentVMMState) {
                $IcingaCheck.SetCritical([string]::Format('status is {0}', $CurrentVMMState), $TRUE) | Out-Null;
            }
        }

        # Will only be set if not in critical state, as we lock the object before
        $IcingaCheck.SetOK([string]::Format('status is {0}', $CurrentVMMState), $TRUE) | Out-Null;

        $CheckPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $TRUE -Compile);
}
