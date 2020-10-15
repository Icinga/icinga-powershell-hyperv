<#
.SYNOPSIS
    Fetch available information on the host regarding Hyper-V information
.DESCRIPTION
    Fetch available information on the host regarding Hyper-V information.
    Returns a hashtable all required data for monitoring the health of Hyper-V
.ROLE
    WMI Permissions
    * Root\Virtualization\v2
    * Root\Cimv2
.OUTPUTS
    System.Hashtable
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>

function Get-IcingaHypervHostInfo()
{
    [hashtable]$HypervDetails = @{ };

    if ((Test-IcingaHyperVInstalled) -eq $FALSE) {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'Hyper-V not installed' -InputString 'The Hyper-V feature is not installed on this system.' -Force;
    }

    $HypervHosts = Get-IcingaWindowsInformation -ClassName Msvm_VirtualSystemManagementService -Namespace 'root\Virtualization\v2';

    if ($null -eq $HypervHosts) {
        return $null;
    }

    $HypervDetails.Add('Caption', $HypervHosts.Caption);
    $HypervDetails.Add('Name', $HypervHosts.Name);
    $HypervDetails.Add('Description', $HypervHosts.Description);
    $HypervDetails.Add('ElementName', $HypervHosts.ElementName);
    $HypervDetails.Add('InstanceId', $HypervHosts.InstanceId);
    $HypervDetails.Add('CommunicationStatus', $HypervHosts.CommunicationStatus);
    $HypervDetails.Add('DetailedStatus', $HypervHosts.DetailedStatus);
    $HypervDetails.Add('Health', @{
            'State'       = $HypervHosts.HealthState;
            'Status'      = $HypervHosts.Status;
            'Description' = $HypervHosts.StatusDescriptions;
        }
    );
    $HypervDetails.Add('InstallDate', $HypervHosts.InstallDate);
    $HypervDetails.Add('OperatingStatus', $HypervHosts.OperatingStatus);
    $HypervDetails.Add('OperationalStatus', $HypervHosts.OperationalStatus);
    $HypervDetails.Add('PrimaryStatus', $HypervHosts.PrimaryStatus);
    $HypervDetails.Add('AvailableRequestedStates', $HypervHosts.AvailableRequestedStates);
    $HypervDetails.Add('EnabledDefault', $HypervHosts.EnabledDefault);
    $HypervDetails.Add('EnabledState', $HypervHosts.EnabledState);
    $HypervDetails.Add('OtherEnabledState', $HypervHosts.OtherEnabledState);
    $HypervDetails.Add('RequestedState', $HypervHosts.RequestedState);
    $HypervDetails.Add('TimeOfLastStateChange', $HypervHosts.TimeOfLastStateChange);
    $HypervDetails.Add('TransitioningToState', $HypervHosts.TransitioningToState);
    $HypervDetails.Add('CreationClassName', $HypervHosts.CreationClassName);
    $HypervDetails.Add('PrimaryOwnerContact', $HypervHosts.PrimaryOwnerContact);
    $HypervDetails.Add('PrimaryOwnerName', $HypervHosts.PrimaryOwnerName);
    $HypervDetails.Add('Started', $HypervHosts.Started);
    $HypervDetails.Add('StartMode', $HypervHosts.StartMode);
    $HypervDetails.Add('SystemCreationClassName', $HypervHosts.SystemCreationClassName);
    $HypervDetails.Add('SystemName', $HypervHosts.SystemName);
    $HypervDetails.Add('PSComputerName', $HypervHosts.PSComputerName);

    return $HypervDetails;
}
