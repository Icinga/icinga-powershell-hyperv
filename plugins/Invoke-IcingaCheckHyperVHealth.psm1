<#
.SYNOPSIS
    Checks the general availability, state and health of the Hyper-V server.
.DESCRIPTION
    Invoke-IcingaCheckHyperVHealth determines the availability, state and health of the Hyper-V server.
    It also checks if required Hyper-V services are running including the VMM agent.
.ROLE
    ### WMI Permissions

    * Root\Virtualization\v2
    * Root\Cimv2
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
.EXAMPLE
    PS> Invoke-IcingaCheckHyperVHealth -Verbosity 2
    [CRITICAL] Check package "Hyper-V Health Package" (Match All) - [CRITICAL] vmms Communication Status
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
    |
    2
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>

function Invoke-IcingaCheckHyperVHealth()
{
    param (
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2)]
        $Verbosity          = 0
    );

    $CheckPackage         = New-IcingaCheckPackage -Name 'Hyper-V Health Package' -OperatorAnd -Verbose $Verbosity;
    $ServicesCheckPackage = New-IcingaCheckPackage -Name 'Services Package' -OperatorAnd -Verbose $Verbosity;
    $GetHypervHostDetail  = Get-IcingaHypervHostInfo;
    $GetServices          = Get-IcingaServices -Service @(
        'vmcompute',
        'vmicguestinterface',
        'vmicheartbeat',
        'vmickvpexchange',
        'vmicrdv',
        'vmicshutdown',
        'vmictimesync',
        'vmicvmsession',
        'vmicvss',
        'vmms'
    );

    foreach ($Service in $GetServices.Keys) {
        $HypervService = $GetServices[$Service];

        $Check = New-IcingaCheck `
            -Name ([string]::Format('{0} Status', $Service)) `
            -Value $HypervService.configuration.Status.raw `
            -Translation $ProviderEnums.ServiceStatusName;

        if (([string]::IsNullOrEmpty($HypervService.configuration.ExitCode) -eq $FALSE) -And ($HypervService.configuration.ExitCode -ne 0) -And ($HypervService.configuration.Status.raw -ne $ProviderEnums.ServiceStatus.Running)) {
            $Check.CritIfNotMatch($ProviderEnums.ServiceStatus.Running) | Out-Null;
        } elseif (($Service -eq 'vmcompute' -Or $Service -eq 'vmms') -And ($HypervService.configuration.Status.raw -ne $ProviderEnums.ServiceStatus.Running)) {
            $Check.CritIfNotMatch($ProviderEnums.ServiceStatus.Running) | Out-Null;
        }

        $ServicesCheckPackage.AddCheck($Check);
    }

    if ($GetServices['vmms'].configuration.Status.raw -eq $ProviderEnums.ServiceStatus.Running) {
        if ($null -ne $GetHypervHostDetail) {
            $HypervHostCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('{0} Status', $GetHypervHostDetail.Name)) -OperatorAnd -Verbose $Verbosity;
            $HypervHostCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} Health State', $GetHypervHostDetail.Name)) `
                        -Value $GetHypervHostDetail.Health.Status `
                        -NoPerfData
                ).CritIfNotMatch(
                    'OK'
                )
            );
        } else {
            $HypervHostCheckPackage = New-IcingaCheckPackage -Name 'Hyper-V Status' -OperatorAnd -Verbose $Verbosity;
            $HypervHostCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name 'Health State: Undefined' `
                        -NoPerfData
                ).SetWarning()
            );
        }

        $CheckPackage.AddCheck($HypervHostCheckPackage);
    }

    $CheckPackage.AddCheck($ServicesCheckPackage);

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
