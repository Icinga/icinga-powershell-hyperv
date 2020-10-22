<#
.SYNOPSIS
    This function is the basic provider for fetching virtual computer information from Hyper-V systems and collects virtual machine, snapshot and virtual switch data.
    Plugins requiring at least two of the mentioned data together, should use this data provider.
.DESCRIPTION
    This function is the basic provider for fetching virtual computer information from Hyper-V systems and collects virtual machine, snapshot and virtual switch data.
    Plugins requiring at least two of the mentioned data together, should use this data provider.
.OUTPUTS
    System.Hashtable
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
.Link
    https://github.com/Icinga/icinga-powershell-hyperv
#>

function Get-IcingaVirtualComputerInfo() {
    param (
        [array]$IncludeVms = @(),
        [array]$ExcludeVms = @(),
        [Switch]$ActiveVms = $FALSE
    );

    # Get all information about the hyperv virtual Computers
    $VirtualComputers   = Get-IcingaWindowsInformation -ClassName Msvm_SummaryInformation -Namespace 'Root\Virtualization\v2';
    # Gather all information regarding virtual computers memory allocation
    $VComputerMemorys   = Get-IcingaWindowsInformation -ClassName Msvm_MemorySettingData -Namespace 'Root\Virtualization\v2';
    # Get infos about virtual computers hard disk drive / VHDs
    $VcomputerVHDs      = Get-IcingaWindowsInformation -ClassName Msvm_LogicalDisk -Namespace 'Root\Virtualization\v2';
    $VComputerHardDisks = Get-IcingaPhysicalDiskInfo;
    # Get the Partition where all virtual Computers are Stored
    $VmPartitionsPath   = Get-IcingaWindowsInformation -ClassName Msvm_StorageAllocationSettingData -Namespace 'Root\Virtualization\v2'
    # Gather all infos rgarding Virtual Computer CPU used
    $CountCPUCores      = Get-IcingaCPUCount;
    $VComputerRamLimit  = (Get-IcingaMemoryPerformanceCounter).'Memory Total Bytes';
    $PluginInstalled    = $FALSE;
    $CurrentVmsUsage    = 0;
    $VComputerData      = @{
        'VMs'       = @{ };
        'Summary'   = @{
            'RunningVms' = 0;
            'StoppedVms' = 0;
            'TotalVms'   = 0;
        };
        'Resources' = @{
            'RAMOverCommit'     = @{
                'Bytes'    = 0;
                'Percent'  = 0;
                'Capacity' = $VComputerRamLimit;
            };
            'CPUOverCommit'     = @{
                'Percent'   = 0;
                'Cores'     = 0;
                'Available' = $CountCPUCores;
            };
            'StorageOverCommit' = @{ };
        };
    };

    # In case of a Permissions Problem or if for some reason no DATA is retrieved from the WMI classes, we throw an exception
    if ($null -eq $VirtualComputers -or $null -eq $VComputerMemorys -or $null -eq $VcomputerVHDs) {
        Exit-IcingaThrowException -Force -ExceptionType 'Permission' -ExceptionThrown 'The user you are running this command with does not have permissions to access Hyper-V data on this host. Please add the user to the "Hyper-V Administrator" user group and restart the Icinga/PowerShell service afterwards' -CustomMessage 'Hyper-V access denied';
    }

    if (Test-IcingaFunction 'Get-IcingaClusterSharedVolumeData') {
        $PluginInstalled = $TRUE;
    }

    foreach ($vcomputer in $VirtualComputers) {
        # The basic information details about the virtual computers
        $details = @{
            'InstanceID'                      = $vcomputer.InstanceID;
            'AllocatedGPU'                    = $vcomputer.AllocatedGPU;
            'Shielded'                        = $vcomputer.Shielded;
            'AsynchronousTasks'               = $vcomputer.AsynchronousTasks;
            'CreationTime'                    = $vcomputer.CreationTime;
            'ElementName'                     = $vcomputer.ElementName;
            'EnabledState'                    = $vcomputer.EnabledState;
            'OtherEnabledState'               = $vcomputer.OtherEnabledState;
            'GuestOperatingSystem'            = $vcomputer.GuestOperatingSystem;
            'HealthState'                     = $vcomputer.HealthState;
            'Heartbeat'                       = $vcomputer.Heartbeat;
            'MemoryUsage'                     = $vcomputer.MemoryUsage;
            'MemoryAvailable'                 = $vcomputer.MemoryAvailable;
            'AvailableMemoryBuffer'           = $vcomputer.AvailableMemoryBuffer;
            'SwapFilesInUse'                  = $vcomputer.SwapFilesInUse;
            'Name'                            = $vcomputer.Name;
            'NumberOfProcessors'              = $vcomputer.NumberOfProcessors;
            'OperationalStatus'               = $vcomputer.OperationalStatus;
            'ProcessorLoad'                   = $vcomputer.ProcessorLoad;
            'ProcessorLoadHistory'            = $vcomputer.ProcessorLoadHistory;
            'Snapshots'                       = @{
                'Latest' = $null;
                'List'   = @();
                'Info'   = @{ };
            };
            'StatusDescriptions'              = $vcomputer.StatusDescriptions;
            'ThumbnailImage'                  = $vcomputer.ThumbnailImage;
            'ThumbnailImageHeight'            = $vcomputer.ThumbnailImageHeight;
            'ThumbnailImageWidth'             = $vcomputer.ThumbnailImageWidth;
            'UpTime'                          = $vcomputer.UpTime;
            'ReplicationState'                = $vcomputer.ReplicationState;
            'ReplicationStateEx'              = $vcomputer.ReplicationStateEx;
            'ReplicationHealth'               = $vcomputer.ReplicationHealth;
            'ReplicationHealthEx'             = $vcomputer.ReplicationHealthEx;
            'ReplicationMode'                 = $vcomputer.ReplicationMode;
            'TestReplicaSystem'               = @{ };
            'ApplicationHealth'               = $vcomputer.ApplicationHealth;
            'IntegrationServicesVersionState' = $vcomputer.IntegrationServicesVersionState;
            'MemorySpansPhysicalNumaNodes'    = $vcomputer.MemorySpansPhysicalNumaNodes;
            'ReplicationProviderId'           = $vcomputer.ReplicationProviderId;
            'EnhancedSessionModeState'        = $vcomputer.EnhancedSessionModeState;
            'VirtualSwitches'                 = $vcomputer.VirtualSwitchNames;
            'VirtualSystemSubType'            = $vcomputer.VirtualSystemSubType;
            'HostComputerSystemName'          = $vcomputer.HostComputerSystemName;
        };

        # Verify that the virtual computer TestReplicaSystem attribute is not null
        # otherwise we cannot access the following information, which we require
        if ($null -ne $vcomputer.TestReplicaSystem) {
            foreach ($testreplica in $vcomputer.TestReplicaSystem) {
                $details.TestReplicaSystem = @{
                    'Count'                                    = $testreplica.__PROPERTY_COUNT;
                    'AvailableRequestedStates'                 = $testreplica.AvailableRequestedStates;
                    'Caption'                                  = $testreplica.Caption;
                    'CommunicationStatus'                      = $testreplica.CommunicationStatus;
                    'Description'                              = $testreplica.Description;
                    'DetailedStatus'                           = $testreplica.DetailedStatus;
                    'ElementName'                              = $testreplica.ElementName;
                    'EnabledDefault'                           = $testreplica.EnabledDefault;
                    'EnabledState'                             = $testreplica.EnabledState;
                    'EnhancedSessionModeState'                 = $testreplica.EnhancedSessionModeState;
                    'FailedOverReplicationType'                = $testreplica.FailedOverReplicationType;
                    'HealthState'                              = $testreplica.HealthState;
                    'InstallDate'                              = $testreplica.InstallDate;
                    'LastApplicationConsistentReplicationTime' = $testreplica.LastApplicationConsistentReplicationTime;
                    'LastReplicationTime'                      = $testreplica.LastReplicationTime;
                    'LastReplicationType'                      = $testreplica.LastReplicationType;
                    'LastSuccessfulBackupTime'                 = $testreplica.LastSuccessfulBackupTime;
                    'Name'                                     = $testreplica.Name;
                    'NumberOfNumaNodes'                        = $testreplica.NumberOfNumaNodes;
                    'OnTimeInMilliseconds'                     = $testreplica.OnTimeInMilliseconds;
                    'PrimaryOwnerContact'                      = $testreplica.PrimaryOwnerContact;
                    'PrimaryOwnerName'                         = $testreplica.PrimaryOwnerName;
                    'PrimaryStatus'                            = $testreplica.PrimaryStatus;
                    'ProcessID'                                = $testreplica.ProcessID;
                    'ReplicationHealth'                        = $testreplica.ReplicationHealth;
                    'ReplicationMode'                          = $testreplica.ReplicationMode;
                    'ReplicationState'                         = $testreplica.ReplicationState;
                    'RequestedState'                           = $testreplica.RequestedState;
                    'ResetCapability'                          = $testreplica.ResetCapability;
                    'Roles'                                    = $testreplica.Roles;
                    'Status'                                   = $testreplica.Status;
                    'TimeOfLastConfigurationChange'            = $testreplica.TimeOfLastConfigurationChange;
                    'TimeOfLastStateChange'                    = $testreplica.TimeOfLastStateChange;
                    'TransitioningToState'                     = $testreplica.TransitioningToState;
                };
            }
        }

        $LatestSnapshot = @{ };
        # We iterate through all available virtual computer snapshots
        foreach ($snapshot in $vcomputer.Snapshots) {
            [string]$SnapshotPart = $snapshot.ConfigurationDataRoot;
            $SnapshotPart         = $SnapshotPart.Split('\')[0];
            $SnapshotContent      = @{
                'AssociatedResourcePool'               = $snapshot.AssociatedResourcePool;
                'AutomaticRecoveryAction'              = $snapshot.AutomaticRecoveryAction;
                'AutomaticShutdownAction'              = $snapshot.AutomaticShutdownAction;
                'AutomaticStartupAction'               = $snapshot.AutomaticStartupAction;
                'AutomaticStartupActionDelay'          = $snapshot.AutomaticStartupActionDelay;
                'AutomaticStartupActionSequenceNumber' = $snapshot.AutomaticStartupActionSequenceNumber;
                'BandwidthReservationMode'             = $snapshot.BandwidthReservationMode;
                'Caption'                              = $snapshot.Caption;
                'ExtensionOrder'                       = $snapshot.ExtensionOrder;
                'ConfigurationDataRoot'                = $snapshot.ConfigurationDataRoot;
                'ConfigurationFile'                    = $snapshot.ConfigurationFile;
                'ConfigurationID'                      = $snapshot.ConfigurationID;
                'InstanceID'                           = $snapshot.InstanceID;
                'CreationTime'                         = $snapshot.CreationTime;
                'IOVPreferred'                         = $snapshot.IOVPreferred;
                'LogDataRoot'                          = $snapshot.LogDataRoot;
                'MaxNumMACAddress'                     = $snapshot.MaxNumMACAddress;
                'Description'                          = $snapshot.Description;
                'ElementName'                          = $snapshot.ElementName;
                'Notes'                                = $snapshot.Notes;
                'PacketDirectEnabled'                  = $snapshot.PacketDirectEnabled;
                'RecoveryFile'                         = $snapshot.RecoveryFile;
                'SnapshotDataRoot'                     = $snapshot.SnapshotDataRoot;
                'SwapFileDataRoot'                     = $snapshot.SwapFileDataRoot;
                'TeamingEnabled'                       = $snapshot.TeamingEnabled;
                'VirtualSystemIdentifier'              = $snapshot.VirtualSystemIdentifier;
                'VirtualSystemType'                    = $snapshot.VirtualSystemType;
                'VLANConnection'                       = $snapshot.VLANConnection;
                'HighMmioGapSize'                      = $snapshot.HighMmioGapSize;
                'LowMmioGapSize'                       = $snapshot.LowMmioGapSize;
                'VirtualNumaEnabled'                   = $snapshot.VirtualNumaEnabled;
                'IsSaved'                              = $snapshot.IsSaved;
                'Partition'                            = $SnapshotPart;
                'Path'                                 = ([string]::Format('{0}{1}{2}', $snapshot.ConfigurationDataRoot, '\', $snapshot.ConfigurationFile));
            };

            $SnapshotSize = Get-ChildItem -Path $SnapshotContent.Path | Select-Object Length;
            $SnapshotContent.Add('Size', $SnapshotSize.Length);

            if ($details.Snapshots.Info.ContainsKey($SnapshotPart) -eq $FALSE) {
                $details.Snapshots.Info.Add($SnapshotPart, @{
                        'TotalUsed' = $SnapshotSize.Length;
                    }
                );
            } else {
                $details.Snapshots.Info[$SnapshotPart].TotalUsed += $SnapshotSize.Length;
            }

            if ([datetime]$snapshot.CreationTime -gt $LatestSnapshot.CreationTime) {
                # Here comes always only the latest snapshot
                $details.Snapshots.Latest = $SnapshotContent;
            }

            $LatestSnapshot = $snapshot;
            # Here we only add snapshots that are no longer current
            $details.Snapshots.List += $SnapshotContent;
        }

        # Sort our Snapshots based on the creation Time
        $details.Snapshots.List = $details.Snapshots.List | Sort-Object -Property @{Expression = { [datetime]$_.CreationTime }; Descending = $TRUE };

        # We are going to loop through all available vm partitions
        foreach ($vmPartition in $VmPartitionsPath) {
            # We filter out the drive letter where the VMs are stored
            [string]$vmPath     = $vmPartition.HostResource;
            $vmPath             = ([string]::Format('{0}{1}', ($vmPath.Replace('{', '').Split(':')[0]), ':'));
            # Wi filter out the InstanceID for comparing with the vm Id
            [string]$InstanceID = $vmPartition.InstanceID;
            $InstanceID         = $InstanceID.Split(':')[1].Split('\')[0];

            # Skip the loop if the InstanceID doesn't match
            if ($InstanceID -ne $vcomputer.Name) {
                continue;
            }

            # Add some details of the vm partition
            $details += @{
                'Caption'               = $vmPartition.Caption;
                'VMInstanceID'          = $vmPartition.InstanceID;
                'AutomaticAllocation'   = $vmPartition.AutomaticAllocation;
                'AutomaticDeallocation' = $vmPartition.AutomaticDeallocation;
                'HostResource'          = $vmPartition.HostResource;
                'Partition'             = $vmPath;
                'CurrentUsage'          = (Get-ChildItem -Path ([string]$vmPartition.HostResource) | Select-Object Length).Length;
            };

            # If the partition doesn't exist in StorageOverCommit hashtable then add ones
            if ($VComputerData.Resources.StorageOverCommit.ContainsKey($vmPath) -eq $FALSE) {
                $VComputerData.Resources.StorageOverCommit += @{
                    $vmPath = @{
                        'Bytes'    = 0;
                        'Percent'  = 0;
                        'Capacity' = 0;
                    }
                };
            }

            break;
        }

        # Calculate Hyper-V-Server overcommitment RAM, overcommitment CPU and overcommitment memory
        if ($vcomputer.EnabledState -ne $HypervProviderEnums.VMEnabledStateName.Disabled) {
            # Calculation for RAM Overcommitment
            foreach ($memory in $VComputerMemorys) {
                [string]$InstanceId = $memory.InstanceID;
                $InstanceId         = $InstanceId.Split(':')[1].Split('\')[0];

                if ($vcomputer.Name -ne $InstanceId) {
                    continue;
                }

                $details.Add('DynamicMemoryAllocated', $memory.DynamicMemoryEnabled);

                if ($memory.DynamicMemoryEnabled) {
                    $VComputerData.Resources.RAMOverCommit.Bytes += $memory.Limit;
                    $details.Add('MemoryCapacity', $memory.Limit);
                } else {
                    $VComputerData.Resources.RAMOverCommit.Bytes += $memory.VirtualQuantity;
                    $details.Add('MemoryCapacity', $memory.VirtualQuantity);
                }
            }

            # Calculation for CPU Overcommitment
            $VComputerData.Resources.CPUOverCommit.Cores += $vcomputer.NumberOfProcessors;

            # Calculation for vms Storage Overcommitment
            foreach ($vhd in $VcomputerVHDs) {
                if ($vhd.SystemName -ne $vcomputer.Name) {
                    continue;
                }

                if ($details.ContainsKey('DiskCapacity') -eq $FALSE) {
                    $details.Add('DiskCapacity', ($vhd.BlockSize * $vhd.NumberOfBlocks));
                }

                [string]$DeviceID = $vhd.DeviceId;
                $DeviceID         = $DeviceID.Split(':')[1].Split('\')[0];
                if ($details.ContainsKey('DeviceID') -eq $FALSE) {
                    $details.Add('DeviceID', $DeviceID);
                }

                # Gather informations about the virtual computers hard disk drive
                $VComputerData.Resources.StorageOverCommit[$details.Partition].Bytes += ($details.DiskCapacity);
            }

            $CurrentVmsUsage += $details.CurrentUsage;
            # we count up here to get the total number of vms that are still running
            $VComputerData.Summary.RunningVms++;
        } else {
            # we count up here to get the number of total vms that have not yet started
            $VComputerData.Summary.StoppedVms++;
        }

        if ($ActiveVms -And $vcomputer.EnabledState -eq $HypervProviderEnums.VMEnabledStateName.Disabled) {
            continue;
        }

        [bool]$RegexMatch = $TRUE;
        # We have to skip the loop if the regex doesn't match
        if ($IncludeVms.Count -ne 0) {
            foreach ($item in $IncludeVms) {
                if ([string]$vcomputer.ElementName -like [string]$item) {
                    $RegexMatch = $FALSE;
                    break;
                }
            }

            if ($RegexMatch) {
                continue;
            }
        }

        # We have to skip the loop if the regex matches with the element name
        if ($ExcludeVms.Count -ne 0) {
            [bool]$RegexMatch = $FALSE;
            foreach ($item in $ExcludeVms) {
                if ([string]$vcomputer.ElementName -like [string]$item) {
                    $RegexMatch = $TRUE;
                    break;
                }
            }

            if ($RegexMatch) {
                continue;
            }
        }

        foreach ($VchardDisk in $VComputerHardDisks.Keys) {
            $OvercommitCalculated = $FALSE;
            $PhysicalDisk         = $VComputerHardDisks[$VchardDisk];
            if ($PhysicalDisk.DriveReference.ContainsKey($details.Partition) -eq $FALSE) {
                continue;
            }

            [string]$PartitionId = $PhysicalDisk.DriveReference[$details.Partition];

            # Gather informations about the virtual computers hard disk drive
            $PartitionSize = $PhysicalDisk.PartitionLayout[$PartitionId].Size;

            if ($CurrentVmsUsage -gt $PartitionSize) {
                if ($PluginInstalled -eq $FALSE) {
                    if ($VComputerData.Summary.ContainsKey('Located') -eq $FALSE) {
                        $VComputerData.Summary.Add('Located', 'ClusterStorage');
                    }
                } else {
                    $ClusterSharedVolume = Get-IcingaClusterSharedVolumeData;
                    foreach ($volume in $ClusterSharedVolume.Keys) {
                        $SharedVolume     = $ClusterSharedVolume[$volume];
                        [string]$VolumeId = $SharedVolume.SharedVolumeInfo.FriendlyVolumeName;
                        $VolumeId         = $VolumeId.Split('\')[0];

                        if ($VolumeId -ne $details.Partition) {
                            continue;
                        }

                        # Calculation of the average Storage overcommitment
                        $ConvertToPercent = ([System.Math]::Round(
                                (
                                    ($VComputerData.Resources.StorageOverCommit[$details.Partition].Bytes / $SharedVolume.SharedVolumeInfo.Partition.Size) * 100
                                ) - 100, 2
                            )
                        );

                        if ($ConvertToPercent -le 0) {
                            $ConvertToPercent = 0;
                        }

                        $VComputerData.Resources.StorageOverCommit[$details.Partition].Percent  = $ConvertToPercent;
                        $VComputerData.Resources.StorageOverCommit[$details.Partition].Capacity = $SharedVolume.SharedVolumeInfo.Partition.Size;

                        $OvercommitCalculated = $TRUE;
                        break;
                    }
                }
            }

            if ($OvercommitCalculated -eq $FALSE) {
                # Calculation of the average Storage overcommitment
                $ConvertToPercent = ([System.Math]::Round((($VComputerData.Resources.StorageOverCommit[$details.Partition].Bytes / $PartitionSize) * 100) - 100, 2));

                if ($ConvertToPercent -le 0) {
                    $ConvertToPercent = 0;
                }

                $VComputerData.Resources.StorageOverCommit[$details.Partition].Percent  = $ConvertToPercent;
                $VComputerData.Resources.StorageOverCommit[$details.Partition].Capacity = $PartitionSize;
            }

            break;
        }

        $VComputerData.VMs.Add($vcomputer.ElementName, $details);
    }

    if ($VComputerData.VMs.Count -eq 0) {
        return;
    }

    # Calculate the average of Hyper-v CPU Cores used by the vms
    if ($null -eq $CountCPUCores) {
        $VComputerData.Resources.CPUOverCommit.Percent = 100;
    } else {
        $VComputerData.Resources.CPUOverCommit.Percent = ([System.Math]::Round((($VComputerData.Resources.CPUOverCommit.Cores / $CountCPUCores) * 100) - 100, 2));
    }

    # Here we calculate how many Vms the Hyper-V server has in total
    $VComputerData.Summary.TotalVms = ($VComputerData.Summary.RunningVms + $VComputerData.Summary.StoppedVms);
    # Calculate the average Hyper-V RAM Overcommitment
    $RAMUsedPercent = ([System.Math]::Round((($VComputerData.Resources.RAMOverCommit.Bytes / $VComputerRamLimit) * 100) - 100, 2));
    if ($RAMUsedPercent -le 0) {
        $RAMUsedPercent = 0;
    }

    $VComputerData.Resources.RAMOverCommit.Percent  = $RAMUsedPercent;
    $VComputerData.Resources.RAMOverCommit.Capacity = $VComputerRamLimit;

    return $VComputerData;
}
