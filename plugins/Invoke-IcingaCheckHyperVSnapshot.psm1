<#
.SYNOPSIS
    Monitors age, disk space, count and file size of VM snapshots.
.DESCRIPTION
    Invoke-IcingaCheckHyperVSnapshot monitors age, disk space, count, each snapshots file size and the total size of the snapshots for each vms.
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
.PARAMETER CountSnapshotWarning
    Warning threshold for each individual vms how many snapshots they may have.
.PARAMETER CountSnapshotCritical
    Critical threshold for each individual vms how many snapshots they may have
.PARAMETER CreationTimeWarning
    Warning threshold for each individual vms snapshots, how old they must be in seconds.
.PARAMETER CreationTimeCritical
    Critical threshold for each individual vms snapshots, how old they must be in seconds.
.PARAMETER TotalSnapshotSizeWarning
    Warning threshold for each individual vms total snapshots size. It is also possible to
    enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER TotalSnapshotSizeCritical
    Critical threshold for each individual vms total snapshots size. It is also possible to
    enter e.g. 10% as threshold value, if you want a percentage comparison. Defaults to (B)
.PARAMETER SnapshotSizeWarning
    Warning threshold for each individual vms snapshot size in Byte.
.PARAMETER SnapshotSizeCritical
    Critical threshold for each individual vms snapshot size in Byte.
.PARAMETER SnapshotSizePredictionWarning
    Warning threshold for predicting the size of snapshots taken for each Vm before the partition becomes full.
.PARAMETER SnapshotSizePredictionCritical
    Critical threshold for predicting the size of snapshots taken for each Vm before the partition becomes full.
.PARAMETER EmptySnapshotCritical
    Sets the CheckPackage CRITICAL if the Hyper-V VM has no snapshots.
.PARAMETER AvoidEmptyCheck
    Overrides the default behaviour of the plugin in case no virtual machine is present on the system.
    Instead of returning `Unknown` the plugin will return `Ok` instead if this argument is set.
.PARAMETER NoPerfData
    Disables the performance data output of this plugin.
.PARAMETER Verbosity
    Changes the behavior of the plugin output which check states are printed:
    0 (default): Only service checks/packages with state not OK will be printed
    1: Only services with not OK will be printed including OK checks of affected check packages including Package config
    2: Everything will be printed regardless of the check state
    3: Identical to Verbose 2, but prints in addition the check package configuration e.g (All must be [OK])
.EXAMPLE
    PS> icinga { Invoke-IcingaCheckHyperVSnapshot -ActiveVms -IncludeVms '*vm*' -Verbosity 2 }
    [OK] Check package "VM Snapshots" (Match All)
    \_ [OK] Check package "icinga-vm" (Match All)
        \_ [OK] Check package "Bright" (Match All)
            \_ [OK] Snapshot Creation Time [18.02.2020 10:21:19]: 21859435s
            \_ [OK] Snapshot Size: 51090B
        \_ [OK] Check package "icinga-vm-snapshot-1" (Match All)
            \_ [OK] Snapshot Creation Time [15.10.2020 15:43:41]: 1107693s
            \_ [OK] Snapshot Size: 51697B
        \_ [OK] icinga-vm I: Count: 6
        \_ [OK] icinga-vm I: Snapshots count prediction: 25473978.46
        \_ [OK] icinga-vm I: TotalSnapshot Size: 309038B
        \_ [OK] icinga-vm: Latest Snapshot Creation Delta: 1130216s
        \_ [OK] Check package "icinga-vm-snapshot-2" (Match All)
            \_ [OK] Snapshot Creation Time [15.10.2020 15:41:26]: 1107828s
            \_ [OK] Snapshot Size: 51569B
        \_ [OK] Check package "icinga-vm-snapshot-3" (Match All)
            \_ [OK] Snapshot Creation Time [21.02.2020 10:44:33]: 21598841s
            \_ [OK] Snapshot Size: 51412B
        \_ [OK] Check package "icinga-vm-snapshot-4" (Match All)
            \_ [OK] Snapshot Creation Time [18.02.2020 10:11:02]: 21860052s
            \_ [OK] Snapshot Size: 51002B
        \_ [OK] Check package "icinga-vm-snapshot-5" (Match All)
            \_ [OK] Snapshot Creation Time [18.02.2020 09:22:52]: 21862942s
            \_ [OK] Snapshot Size: 52268B
    \_ [OK] Check package "icinga-vm" (Match All)
        \_ [OK] Check package "icinga-vm-snapshot-1" (Match All)
            \_ [OK] Snapshot Creation Time [18.02.2020 10:11:21]: 21860034s
            \_ [OK] Snapshot Size: 48674B
        \_ [OK] icinga-vm I: Count: 2
        \_ [OK] icinga-vm I: Snapshots count prediction: 27065675.15
        \_ [OK] icinga-vm I: TotalSnapshot Size: 96954B
        \_ [OK] icinga-vm: Latest Snapshot Creation Delta: 9007s
        \_ [OK] Check package "icinga-vm-snapshot-2" (Match All)
            \_ [OK] Snapshot Creation Time [18.02.2020 09:22:47]: 21862948s
            \_ [OK] Snapshot Size: 48280B
    | 'icingavm_i_count'=6;; 'icingavm_i_snapshots_size_prediction'=25473978.46;; 'icingavm_i_totalsnapshot_size'=309038B;; 'icingavm_latest_snapshots_creation_delta'=1130216s;; 'icingavm_i_count'=2;; 'icingavm_i_snapshots_size_prediction'=27065675.15;; 'icingavm_i_totalsnapshot_size'=96954B;; 'icingavm_latest_snapshots_creation_delta'=9007s;;
    0
.Link
    https://github.com/Icinga/icinga-powershell-hyperv
    https://github.com/Icinga/icinga-powershell-framework
#>
function Invoke-IcingaCheckHyperVSnapshot()
{
    param (
        [array]$IncludeVms              = @(),
        [array]$ExcludeVms              = @(),
        [switch]$ActiveVms              = $FALSE,
        $CountSnapshotWarning           = $null,
        $CountSnapshotCritical          = $null,
        $CreationTimeWarning            = $null,
        $CreationTimeCritical           = $null,
        $TotalSnapshotSizeWarning       = $null,
        $TotalSnapshotSizeCritical      = $null,
        $SnapshotSizeWarning            = $null,
        $SnapshotSizeCritical           = $null,
        $SnapshotSizePredictionWarning  = $null,
        $SnapshotSizePredictionCritical = $null,
        [switch]$EmptySnapshotCritical  = $FALSE,
        [switch]$AvoidEmptyCheck        = $FALSE,
        [switch]$NoPerfData             = $FALSE,
        [ValidateSet(0, 1, 2, 3)]
        $Verbosity                      = 0
    );

    # Create a main CheckPackage, under which all following CheckPackages are added
    $CheckPackage     = New-IcingaCheckPackage -Name 'VM Snapshots' -OperatorAnd -Verbose $Verbosity -AddSummaryHeader -IgnoreEmptyPackage:$AvoidEmptyCheck;
    # We get all information about the virtual machine from our provider
    $VirtualComputers = Get-IcingaVirtualComputerInfo -IncludeVms $IncludeVms -ExcludeVms $ExcludeVms -ActiveVms:$ActiveVms;

    # we go through all available vms
    foreach ($vm in $VirtualComputers.VMs.Keys) {
        $virtualMachine    = $VirtualComputers.VMs[$vm];
        $SnapshotMainCheck = New-IcingaCheckPackage -Name $virtualMachine.ElementName -OperatorAnd -Verbose $Verbosity;

        if ($virtualMachine.Snapshots.Latest.Error -eq 'PermissionDenied') {
            $IcingaCheck   = New-IcingaCheck -Name ([string]::Format('Snapshots: Permission denied to location "{0}"', $virtualMachine.Snapshots.Latest.Path)) -NoPerfData;
            $IcingaCheck.SetUnknown() | Out-Null;
            $SnapshotCheck = New-IcingaCheckPackage -Name $virtualMachine.ElementName -OperatorAnd -Verbose $Verbosity;
            $SnapshotCheck.AddCheck($IcingaCheck);
            $CheckPackage.AddCheck($SnapshotCheck);

            continue;
        }

        # We continue if the vm should not have snapshots
        if ($virtualMachine.Snapshots.Info.Count -eq 0) {
            $NoSnapshotCheckPackage = New-IcingaCheckPackage -Name $virtualMachine.ElementName -OperatorAnd -Verbose $Verbosity;
            $SnapshotCheck          = New-IcingaCheckPackage -Name $virtualMachine.ElementName -OperatorAnd -Verbose $Verbosity;
            $IcingaCheck            = New-IcingaCheck -Name 'No snapshots created' -NoPerfData;

            if ($EmptySnapshotCritical) {
                $IcingaCheck.SetCritical() | Out-Null;
            }

            $SnapshotCheck.AddCheck($IcingaCheck);
            $NoSnapshotCheckPackage.AddCheck($SnapshotCheck);
            $CheckPackage.AddCheck($NoSnapshotCheckPackage);

            continue;
        }

        # we iterate through all available snapshots that belong to the current Vm
        foreach ($snapshot in $virtualMachine.Snapshots.List) {
            [string]$SnapshotName = $snapshot.ElementName;
            $SnapshotName         = $SnapshotName.Split(' ')[0];
            $SnapshotCheckPackage = New-IcingaCheckPackage -Name ([string]::Format('{0} {1}', $SnapshotName, $snapshot.CreationTime)) -OperatorAnd -Verbose $Verbosity;
            $SnapshotCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name 'Snapshot Size' `
                        -Value $snapshot.Size `
                        -NoPerfData `
                        -Unit 'B'
                ).WarnOutOfRange(
                    $SnapshotSizeWarning
                ).CritOutOfRange(
                    $SnapshotSizeCritical
                )
            );

            $SnapshotCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name 'Snapshot Description' `
                        -Value $snapshot.Description `
                        -NoPerfData
                )
            );

            $SnapshotCheckPackage.AddCheck(
                (
                    New-IcingaCheck `
                        -Name 'Snapshot Name' `
                        -Value $snapshot.ElementName `
                        -NoPerfData
                )
            );

            $SnapshotMainCheck.AddCheck($SnapshotCheckPackage);
        }

        foreach ($part in $virtualMachine.Snapshots.Info.Keys) {
            $Partition      = $virtualMachine.Snapshots.Info[$part];
            $SnapshotsCount = $virtualMachine.Snapshots.List.Length;
            $SnapshotMainCheck.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} {1} Count', $virtualMachine.ElementName, $part)) `
                        -Value $SnapshotsCount `
                        -Unit 'c'
                ).WarnOutOfRange(
                    $CountSnapshotWarning
                ).CritOutOfRange(
                    $CountSnapshotCritical
                )
            );

            $SnapshotMainCheck.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} {1} Total Snapshot Size', $virtualMachine.ElementName, $part)) `
                        -Value $Partition.TotalUsed `
                        -BaseValue $virtualMachine.CurrentUsage `
                        -Unit 'B'
                ).WarnOutOfRange(
                    $TotalSnapshotSizeWarning
                ).CritOutOfRange(
                    $TotalSnapshotSizeCritical
                )
            );

            $AverageSnapshotSize     = [System.Math]::Truncate([System.Math]::Round($Partition.TotalUsed / $SnapshotsCount));
            $CalculateTotalSnapshots = [System.Math]::Truncate([System.Math]::Round($Partition.FreeSpace / ([math]::Max($AverageSnapshotSize, 1)), 2));

            $SnapshotMainCheck.AddCheck(
                (
                    New-IcingaCheck `
                        -Name ([string]::Format('{0} {1} Snapshot count prediction', $virtualMachine.ElementName, $part)) `
                        -Value $CalculateTotalSnapshots `
                        -Unit 'c'
                ).WarnOutOfRange(
                    $SnapshotSizePredictionWarning
                ).CritOutOfRange(
                    $SnapshotSizePredictionCritical
                )
            );
        }

        # Add a CheckPackage for the latest creation virtual computer snpashot
        $SnapshotMainCheck.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Latest Snapshot Creation Delta', $virtualMachine.ElementName)) `
                    -Value (Compare-IcingaUnixTimeWithDateTime -DateTime $virtualMachine.Snapshots.Latest.CreationTime) `
                    -Unit 's'
            ).WarnOutOfRange(
                $CreationTimeWarning
            ).CritOutOfRange(
                $CreationTimeCritical
            )
        );

        # CheckPackage for the latest snapshot Description
        $SnapshotMainCheck.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Latest Snapshot Description', $virtualMachine.ElementName)) `
                    -Value $virtualMachine.Snapshots.Latest.Description `
                    -NoPerfData
            )
        );

        # CheckPackage for the latest snapshot ElementName
        $SnapshotMainCheck.AddCheck(
            (
                New-IcingaCheck `
                    -Name ([string]::Format('{0}: Latest Snapshot Name', $virtualMachine.ElementName)) `
                    -Value $virtualMachine.Snapshots.Latest.ElementName `
                    -NoPerfData
            )
        );

        $CheckPackage.AddCheck($SnapshotMainCheck);
    }

    if ($VirtualComputers.Summary.ContainsKey('SnapshotLocated')) {
        $CheckPackage.AddCheck(
            (
                New-IcingaCheck `
                    -Name 'Snapshot images seem to be located on a Cluster Shared Volume but Cluster-Plugins are not installed' -NoPerfData
            ).SetWarning()
        );
    }

    return (New-IcingaCheckResult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
