<#
.SYNOPSIS
    This function fetches all data for virtual switches, allowing to check for the state of virtual switches.
.DESCRIPTION
    This function fetches all data for virtual switches, allowing to check for the state of virtual switches.
.OUTPUTS
    System.Hashtable
.ROLE
    ### WMI Permissions

    * Root\Virtualization\v2
    * Root\Cimv2
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>
function Get-IcingaHypervVirtualSwitches()
{
    param(
        [array]$IncludeSwitches   = @(),
        [array]$ExcludeSwitches   = @(),
        [switch]$InternalSwitches = $FALSE,
        [switch]$ExternalSwitches = $FALSE
    );

    # Get all necessary information about virtual switches
    $VirtualSwithes           = Get-IcingaWindowsInformation -ClassName Msvm_VirtualEthernetSwitch -Namespace 'Root\Virtualization\v2';
    $InternalVirtualSwitches  = Get-IcingaWindowsInformation -ClassName Msvm_InternalEthernetPort -Namespace 'Root\Virtualization\v2';
    $ExternalVirtualSwitches  = Get-IcingaWindowsInformation -ClassName Msvm_ExternalEthernetPort -Namespace 'Root\Virtualization\v2';
    $VirtualSwitchesData      = @{ };

    # We iterate through all available internal and external virtual switches
    foreach ($switch in $VirtualSwithes) {
        $details = @{ };
        # Check, if there are still switches, which have to be filtered in
        if ($IncludeSwitches.Count -ne 0) {
            if (($IncludeSwitches -contains $switch.ElementName) -eq $FALSE) {
                continue;
            }
        }

        # Check, if there are still switches, which have to be filtered out
        if ($ExcludeSwitches.Count -ne 0) {
            if (($ExcludeSwitches -contains $switch.ElementName) -eq $TRUE) {
                continue;
            }
        }

        # We iterate through all available internal virtual switches
        foreach ($internal in $InternalVirtualSwitches) {
            # We continue if the internal switch name is not present in the outer loop
            if ($switch.ElementName -ne $internal.ElementName) {
                continue;
            }

            # Add some additional information about the virtual switches
            $details += @{
                'SupportedMaximumTransmissionUnit' = $internal.SupportedMaximumTransmissionUnit;
                'AutoSense'                        = $internal.AutoSense;
                'ActiveMaximumTransmissionUnit'    = $internal.ActiveMaximumTransmissionUnit;
                'FullDuplex'                       = $internal.FullDuplex;
                'LinkTechnology'                   = $internal.LinkTechnology;
                'NetworkAddresses'                 = $internal.NetworkAddresses;
                'OtherLinkTechnology'              = $internal.OtherLinkTechnology;
                'OtherNetworkPortType'             = $internal.OtherNetworkPortType;
                'PermanentAddress'                 = $internal.PermanentAddress;
                'PortNumber'                       = $internal.PortNumber;
                'MaxDataSize'                      = $internal.MaxDataSize;
                'MaxSpeed'                         = $internal.MaxSpeed;
                'OtherPortType'                    = $internal.OtherPortType;
                'PortType'                         = $internal.PortType;
                'RequestedSpeed'                   = $internal.RequestedSpeed;
                'Speed'                            = $internal.Speed;
                'UsageRestriction'                 = $internal.UsageRestriction;
            };

            # We iterate through all available external virtual switches
            foreach ($external in $ExternalVirtualSwitches) {
                # We continue if the external PermanentAddress does not match the internal Switch PermanentAddress
                if ($external.PermanentAddress -ne $internal.PermanentAddress) {
                    continue;
                }
                
                # We add some external switch specific information
                $details += @{
                    'Interface'            = $external.Name;
                    'InterfaceDescription' = $external.Description;
                    'InterfaceID'          = $external.DeviceID;
                    'IsBound'              = $external.IsBound;
                };

                if ($details.ContainsKey('SwitchType') -eq $FALSE) {
                    $details.Add('SwitchType', 'External');
                }
    
                # If the loop has not yet been skipped or interrupted, it can now be cancelled,
                # because we have all the information we need
                break;
            }

            # If the loop has not yet been skipped or interrupted, it can now be cancelled,
            # because we have all the information we need
            break;
        }

        # Check if the hashtable key already exists
        if ($details.ContainsKey('SwitchType') -eq $FALSE) {
            $details.Add('SwitchType', 'Internal');
        }

        # we filter out all external virtual switches, if the user only wants the internal one
        if ($InternalSwitches -and ($details.SwitchType -ne 'Internal')) {
            continue;
        }

        # we filter out all external virtual switches, if the user only wants the internal one
        if ($ExternalSwitches -and ($details.SwitchType -ne 'External')) {
            continue;
        }

        $details += @{
            'AvailableRequestedStates'    = $switch.AvailableRequestedStates;
            'Caption'                     = $switch.Caption;
            'CommunicationStatus'         = $switch.CommunicationStatus;
            'CreationClassName'           = $switch.CreationClassName;
            'Dedicated'                   = $switch.Dedicated;
            'Description'                 = $switch.Description;
            'DetailedStatus'              = $switch.DetailedStatus;
            'ElementName'                 = $switch.ElementName;
            'EnabledDefault'              = $switch.EnabledDefault;
            'EnabledState'                = $switch.EnabledState;
            'HealthState'                 = $switch.HealthState;
            'IdentifyingDescriptions'     = $switch.IdentifyingDescriptions;
            'InstallDate'                 = $switch.InstallDate;
            'InstanceID'                  = $switch.InstanceID;
            'MaxIOVOffloads'              = $switch.MaxIOVOffloads;
            'MaxVMQOffloads'              = $switch.MaxVMQOffloads;
            'Name'                        = $switch.Name;
            'NameFormat'                  = $switch.NameFormat;
            'OperatingStatus'             = $switch.OperatingStatus;
            'OperationalStatus'           = $switch.OperationalStatus;
            'OtherDedicatedDescriptions'  = $switch.OtherDedicatedDescriptions;
            'OtherEnabledState'           = $switch.OtherEnabledState;
            'OtherIdentifyingInfo'        = $switch.OtherIdentifyingInfo;
            'PowerManagementCapabilities' = $switch.PowerManagementCapabilities;
            'PrimaryOwnerContact'         = $switch.PrimaryOwnerContact;
            'PrimaryOwnerName'            = $switch.PrimaryOwnerName;
            'PrimaryStatus'               = $switch.PrimaryStatus;
            'RequestedState'              = $switch.RequestedState;
            'ResetCapability'             = $switch.ResetCapability;
            'Roles'                       = $switch.Roles;
            'Status'                      = $switch.Status;
            'StatusDescriptions'          = $switch.StatusDescriptions;
            'TimeOfLastStateChange'       = $switch.TimeOfLastStateChange;
            'TransitioningToState'        = $switch.TransitioningToState;
            'PSComputerName'              = $switch.PSComputerName;
        };

        $VirtualSwitchesData.Add($switch.Name, $details);
    }

    return $VirtualSwitchesData;
}
