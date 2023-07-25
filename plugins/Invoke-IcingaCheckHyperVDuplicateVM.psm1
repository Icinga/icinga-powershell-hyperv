<#
.SYNOPSIS
    Checks the Hyper-V cluster for virtual machines with the same name
.DESCRIPTION
    Invoke-IcingaCheckHyperVDuplicateVM will ensure your cluster is not running virtual machines with the
    same name and ouptut every single VM as critical in case there is more than one configured
.ROLE
    ### Required User Groups

    * Hyper-V Administrator
.PARAMETER IncludeVMs
    Allows to filter for virtual machines which are included in the check. All others are dropped
.PARAMETER ExcludeVMs
    Allows to filter for virtual machines to never check for them and always being dropped
.PARAMETER NoPerfData
    Disables the performance data output of this plugin
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> Invoke-IcingaCheckHyperVDuplicateVM -Verbosity 2
    [CRITICAL] Duplicate VM List: 1 Critical [CRITICAL] VM "vmicinga" (2) (All must be [OK])
    \_ [CRITICAL] VM "vmicinga": 2
    | 'vmicinga::ifw_hypervduplicatevm::duplicate'=2;;
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>

function Invoke-IcingaCheckHyperVDuplicateVM()
{
    param (
        [array]$IncludeVMs = @(),
        [array]$ExcludeVMs = @(),
        [switch]$NoPerfData = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity          = 0
    );

    $MainPackage  = New-IcingaCheckPackage -Name 'Duplicate VM List' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader -IgnoreEmptyPackage;
    $DuplicateVMs = Get-IcingaProviderDataValuesHyperV;

    foreach ($vm in (Get-IcingaProviderElement $DuplicateVMs.Metrics.ClusterData.VMList.Duplicates)) {
        if ((Test-IcingaArrayFilter -InputObject $vm.Name -Include $IncludeVMs -Exclude $ExcludeVMs) -eq $FALSE) {
            continue;
        }

        $Check = New-IcingaCheck `
            -Name ([string]::Format('VM "{0}"', $vm.Name)) `
            -Value $vm.Value `
            -MetricIndex $vm.Name `
            -MetricName 'duplicate';

        $Check.SetCritical() | Out-Null;

        $MainPackage.AddCheck($Check);
    }

    return (New-IcingaCheckResult -Check $MainPackage -NoPerfData $NoPerfData -Compile);
}
