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

    ### Required User Groups

    * Hyper-V Administrator
.PARAMETER NodeCountWarning
    Allows to throw warning in case the Hyper-V cluster node count is not matching this threshold
.PARAMETER NodeCountCritical
    Allows to throw critical in case the Hyper-V cluster node count is not matching this threshold
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> Invoke-IcingaCheckHyperVHealth -Verbosity 2
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
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>

function Invoke-IcingaCheckHyperVHealth()
{
    param (
        $NodeCountWarning   = $null,
        $NodeCountCritical  = $null,
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity          = 0
    );

    $CheckPackage         = New-IcingaCheckPackage -Name 'Hyper-V Health Package' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader;
    $ServicesCheckPackage = New-IcingaCheckPackage -Name 'Services Package' -OperatorAnd -Verbose $Verbosity;
    $GetHypervHostDetail  = Get-IcingaHypervHostInfo;
    $HyperVDataProvider   = Get-IcingaProviderDataValuesHyperV;
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

    $Check = (
        New-IcingaCheck `
            -Name 'Cluster Node Count' `
            -Value $HyperVDataProvider.Metrics.ClusterData.NodeCount `
            -MetricIndex (Get-IcingaHostname -LowerCase 1) `
            -MetricName 'hypervnodecount'
    ).WarnOutOfRange($NodeCountWarning).CritOutOfRange($NodeCountCritical);

    $CheckPackage.AddCheck($Check);

    foreach ($Service in $GetServices.Keys) {
        $HypervService = $GetServices[$Service];

        $Check = New-IcingaCheck `
            -Name ([string]::Format('{0} Status', $Service)) `
            -Value $HypervService.configuration.Status.raw `
            -Translation $ProviderEnums.ServiceStatusName `
            -MetricIndex $Service `
            -MetricName 'state';

        # Ensure exit code 1077 is ignored, as this means the service was never started: https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes--1000-1299-
        if (([string]::IsNullOrEmpty($HypervService.configuration.ExitCode) -eq $FALSE) -And ($HypervService.configuration.ExitCode -ne 0 -And $HypervService.configuration.ExitCode -ne 1077) -And ($HypervService.configuration.Status.raw -ne $ProviderEnums.ServiceStatus.Running)) {
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
