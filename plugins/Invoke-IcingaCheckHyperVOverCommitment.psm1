<#
.SYNOPSIS
    Calculates CPU, RAM and Storage overcommitment of a Hyper-V Server
.DESCRIPTION
    `Invoke-IcingaCheckHyperVOverCommitment` determines the load of a Hyper-V server,
    which is consumed by all running virtual machines. With the `IncludeVms` and `ExcludeVms` parameters you can exclude or
    include any VMs you want, depending on your needs. Here is an important thing to note, all PerfCounter values are only the
    overcommitment values, i.e. from these values the 100% has already been subtracted, e.g. if the CPU overcommitment is 50% in
    the plugin output, then with the subtracted value the overcommit would be 150% percent. In this case we would have 50% overcommit
    over the maximum value that the Hyper-V server can normally provide.
.ROLE
    ### WMI Permissions

    * Root\Virtualization\v2
    * Root\Cimv2

    ### Performance Counter

    * Processor(*)\% processor time

    ### Required User Groups

    * Performance Log Users
    * Hyper-V Administrator
.PARAMETER IncludeVms
    Include only virtual machines with a specific name. Supports wildcard usage (*)
.PARAMETER ExcludeVms
    Exclude virtual machines with a specific name. Supports wildcard usage (*)
.PARAMETER ActiveVms
    Include only virtual machines that are currently running
.PARAMETER CPUCoreOCWarn
    Warning threshold for Hyper-V CPU Cores overcommitment.
.PARAMETER CPUCoreOCCrit
    Critical threshold for Hyper-V CPU Cores overcommitment.
.PARAMETER CPUOCPercentWarn
    Warning threshold for Hyper-V average CPU overcommitment.
.PARAMETER CPUOCPercentCrit
    Critical threshold for Hyper-V average CPU overcommitment.
.PARAMETER RAMOCByteWarn
    Used to specify a WARNING threshold for the Hyper-V RAM overcommitment in Byte.
.PARAMETER RAMOCByteCrit
    Used to specify a CRITICAL threshold for the Hyper-V RAM overcommitment in Byte.
.PARAMETER RAMOCPercentWarn
    Used to specify a WARNING threshold for the Hyper-V average RAM overcommitment.
.PARAMETER RAMOCPercentCrit
    Used to specify a CRITICAL threshold for the Hyper-V average RAM overcommitment.
.PARAMETER StorageOCByteWarn
    Used to specify a WARNING threshold for the Hyper-V Storage overcommitment in Byte.
.PARAMETER StorageOCByteCrit
    Used to specify a CRITICAL threshold for the Hyper-V Storage overcommitment in Byte.
.PARAMETER StorageOCPercentWarn
    Used to specify a WARNING threshold for the Hyper-V average Storage overcommitment.
.PARAMETER StorageOCPercentCrit
    Used to specify a CRITICAL threshold for the Hyper-V average Storage overcommitment.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin. Default to FALSE.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
.EXAMPLE
    PS> Invoke-IcingaCheckHyperVOverCommitment -Verbosity 2
    [OK] Check package "Hyper-V Overcommitment" (Match All)
    \_ [OK] Check package "CPUOverCommit" (Match All)
        \_ [OK] hyper-v-01 Used Cores: 46c
        \_ [OK] hyper-v-01 Used Percent: 91.67%
    \_ [OK] Check package "RAMOverCommit" (Match All)
        \_ [OK] hyper-v-01 Used Bytes: 45056B
        \_ [OK] hyper-v-01 Used Percent: 0%
    \_ [OK] Check package "StorageOverCommit" (Match All)
        \_ [OK] Check package "Partition C: Overcommitment" (Match All)
            \_ [OK] C: Used Bytes: 140486311936B
            \_ [OK] C: Used Percent: 0%
    \_ [OK] Check package "Partition I: Overcommitment" (Match All)
            \_ [OK] I: Used Bytes: 9979156899840B
            \_ [OK] I: Used Percent: 353.8%
    | 'hyperv01_used_cores'=46c;;;0;24 'hyperv01_used_percent'=91.67%;;;0;100 'hyperv01_used_bytes'=45056B;;;0;60100288512 'hyperv01_used_percent'=0%;;;0;100 'i_used_bytes'=9979156899840B;;;0;2199021158400 'i_used_percent'=353.8%;;;0;100 'c_used_percent'=0%;;;0;100 'c_used_bytes'=140486311936B;;;0;478964350976
    0
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>
function Invoke-IcingaCheckHyperVOverCommitment()
{
    param (
        [array]$IncludeVms    = @(),
        [array]$ExcludeVms    = @(),
        [switch]$ActiveVms    = $FALSE,
        $CPUCoreOCWarn        = $null,
        $CPUCoreOCCrit        = $null,
        $CPUOCPercentWarn     = $null,
        $CPUOCPercentCrit     = $null,
        $RAMOCByteWarn        = $null,
        $RAMOCByteCrit        = $null,
        $RAMOCPercentWarn     = $null,
        $RAMOCPercentCrit     = $null,
        $StorageOCByteWarn    = $null,
        $StorageOCByteCrit    = $null,
        $StorageOCPercentWarn = $null,
        $StorageOCPercentCrit = $null,
        [switch]$NoPerfData   = $FALSE,
        [ValidateSet(0, 1, 2)]
        $Verbosity            = 0
    );

    # Create a main CheckPackage
    $CheckPackage                  = New-IcingaCheckPackage -Name 'Hyper-V Overcommitment' -OperatorAnd -Verbose $Verbosity;
    # Get all information about the Hyper-V OverCommitment
    $HypervServer                  = Get-IcingaVirtualComputerInfo -IncludeVms $IncludeVms -ExcludeVms $ExcludeVms -ActiveVms:$ActiveVms;
    # Convert thresholds to Byte
    $RAMOCByteWarn     = (Convert-IcingaPluginThresholds -Threshold $RAMOCByteWarn).Value;
    $RAMOCByteCrit     = (Convert-IcingaPluginThresholds -Threshold $RAMOCByteCrit).Value;
    $StorageOCByteWarn = (Convert-IcingaPluginThresholds -Threshold $StorageOCByteWarn).Value;
    $StorageOCByteCrit = (Convert-IcingaPluginThresholds -Threshold $StorageOCByteCrit).Value;

    # Create a CheckPackage for storage Overcommitment
    $OvercommitCheckPackage = New-IcingaCheckPackage -Name 'StorageOverCommit' -OperatorAnd -Verbose $Verbosity;
    # When we are at StorageOvercommitment, we have to go through all available partitions and build CheckPackages
    foreach ($storage in $HypervServer.Resources.StorageOverCommit.Keys) {
        $StorageOverCommit = $HypervServer.Resources.StorageOverCommit[$storage];
        # Create a CheckPackage for each individual overcommitted partition
        $PartitionPackage  = New-IcingaCheckPackage -Name ([string]::Format('Partition {0} Overcommitment', $storage)) -OperatorAnd -Verbose $Verbosity;

        $PartitionPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} Used Bytes', $storage)) `
                    -Value $StorageOverCommit.Bytes `
                    -Unit 'B' `
                    -Minimum 0 `
                    -Maximum $StorageOverCommit.Capacity
            ).WarnOutOfRange(
                $StorageOCByteWarn
            ).CritOutOfRange(
                $StorageOCByteCrit
            )
        );

        $PartitionPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0} Used Percent', $storage)) `
                    -Value $StorageOverCommit.Percent `
                    -Unit '%' `
                    -Minimum 0 `
                    -Maximum 100
            ).WarnOutOfRange(
                $StorageOCPercentWarn
            ).CritOutOfRange(
                $StorageOCPercentCrit
            )
        );

        # We add the overcommitted Partition CheckPackage to the Common StorageOverCommit CheckPackage
        $OvercommitCheckPackage.AddCheck($PartitionPackage);
    }

    # we have to add the Storage CheckPackage to the main CheckPackage
    $CheckPackage.AddCheck($OvercommitCheckPackage);

    # Create a CheckPackage for RAM Overcommitment
    $OvercommitCheckPackage = New-IcingaCheckPackage -Name 'RAMOverCommit' -OperatorAnd -Verbose $Verbosity;
    # Add Bytes RAMOvercommit IcingaCheck
    $OvercommitCheckPackage.AddCheck(
        (
            New-IcingaCheck `
                -Name ([string]::Format('{0} Used Bytes', $env:COMPUTERNAME)) `
                -Value $HypervServer.Resources.RAMOverCommit.Bytes `
                -Unit 'B' `
                -Minimum 0 `
                -Maximum $HypervServer.Resources.RAMOverCommit.Capacity
        ).WarnOutOfRange(
            $RAMOCByteWarn
        ).CritOutOfRange(
            $RAMOCByteCrit
        )
    );

    # RAM and CPU Overcommitment CheckPackage in Percent
    $OvercommitCheckPackage.AddCheck(
        (
            New-IcingaCheck `
                -Name ([string]::Format('{0} Used Percent', $env:COMPUTERNAME)) `
                -Value $HypervServer.Resources.RAMOverCommit.Percent `
                -Unit '%' `
                -Minimum 0 `
                -Maximum 100
        ).WarnOutOfRange(
            $RAMOCPercentWarn
        ).CritOutOfRange(
            $RAMOCPercentCrit
        )
    );

    # End of RAM Overcommitment
    $CheckPackage.AddCheck($OvercommitCheckPackage);

    # Create a CheckPackage for CPU Overcommitment
    $OvercommitCheckPackage = New-IcingaCheckPackage -Name 'CPUOverCommit' -OperatorAnd -Verbose $Verbosity;
    # Add CPU Cores overcommitment CheckPackage
    $OvercommitCheckPackage.AddCheck(
        (
            New-IcingaCheck `
                -Name ([string]::Format('{0} Used Cores', $env:COMPUTERNAME)) `
                -Value $HypervServer.Resources.CPUOverCommit.Cores `
                -Unit 'c' `
                -Minimum 0 `
                -Maximum $HypervServer.Resources.CPUOverCommit.Available
        ).WarnOutOfRange(
            $CPUCoreOCWarn
        ).CritOutOfRange(
            $CPUCoreOCCrit
        )
    );

    # RAM and CPU Overcommitment CheckPackage in Percent
    $OvercommitCheckPackage.AddCheck(
        (
            New-IcingaCheck `
                -Name ([string]::Format('{0} Used Percent', $env:COMPUTERNAME)) `
                -Value $HypervServer.Resources.CPUOverCommit.Percent `
                -Unit '%' `
                -Minimum 0 `
                -Maximum 100
        ).WarnOutOfRange(
            $CPUOCPercentWarn
        ).CritOutOfRange(
            $CPUOCPercentCrit
        )
    );

    # End of CPUOverCommit
    $CheckPackage.AddCheck($OvercommitCheckPackage);

    if ($HypervServer.Summary.ContainsKey('Located')) {
        $CheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name 'VM images seem to be located on a Cluster Shared Volume but Cluster-Plugins are not installed' -NoPerfData
            ).SetWarning()
        );
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
