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

[hashtable]$HypervProviderEnums = @{
    # /lib/provider/vcomputer
    VMEnabledState            = $VMEnabledState;
    VMEnabledStateName        = $VMEnabledStateName;
};

Export-ModuleMember -Variable @('HypervProviderEnums');
