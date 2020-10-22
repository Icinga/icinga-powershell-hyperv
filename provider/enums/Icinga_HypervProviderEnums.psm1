<########################################################################################################
################################# /lib/provider/vcomputer ################################################
################################################################################################endregion#>

[hashtable]$VMEnabledState = @{
    0  = 'Unknown';
    1  = 'Other';
    2  = 'Enabled';
    3  = 'Disabled';
    4  = 'Shutting Down';
    5  = 'Not Applicable';
    6  = 'Enabled but Offline';
    7  = 'In Test';
    8  = 'Deferred';
    9  = 'Quiesce';
    10 = 'Starting';
}

[hashtable]$VMEnabledStateName = @{
    'Unknown'             = 0;
    'Other'               = 1;
    'Enabled'             = 2;
    'Disabled'            = 3;
    'Shutting Down'       = 4;
    'Not Applicable'      = 5;
    'Enabled but Offline' = 6;
    'In Test'             = 7;
    'Deferred'            = 8;
    'Quiesce'             = 9;
    'Starting'            = 10;
}

<########################################################################################################
################################# /lib/provider/vmhealth ################################################
################################################################################################endregion#>

[hashtable]$VMHeartbeat = @{
    2  = 'OK';
    6  = 'Error';
    12 = 'No Contact';
    13 = 'Lost Communication';
};

[hashtable]$VMHeartbeatName = @{
    'OK'                 = 2;
    'Error'              = 6;
    'No Contact'         = 12;
    'Lost Communication' = 13;
};

[hashtable]$VMHealthState = @{
    5  = 'OK';
    20 = 'Major Failure';
    25 = 'Critical failure';
};

[hashtable]$VMHealthStateName = @{
    'OK'               = 5;
    'Major Failure'    = 20;
    'Critical failure' = 25;
};

[hashtable]$HypervProviderEnums = @{
    # /lib/provider/vcomputer
    VMEnabledState          = $VMEnabledState;
    VMEnabledStateName      = $VMEnabledStateName;
    # /lib/provider/vmhealth
    VMHeartbeat             = $VMHeartbeat;
    VMHeartbeatName         = $VMHeartbeatName;
    VMHealthState           = $VMHealthState;
    VMHealthStateName       = $VMHealthStateName;
};

Export-ModuleMember -Variable @('HypervProviderEnums');
