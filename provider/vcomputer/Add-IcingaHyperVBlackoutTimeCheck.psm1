function Add-IcingaHyperVBlackoutTimeCheck()
{
    param (
        $HyperVProviderData               = $null,
        $CheckPackage                     = $null,
        $VMName                           = '',
        [string]$BlackoutTimesEventDelta  = $null
    );

    if ($null -eq $HyperVProviderData -Or $null -eq $CheckPackage -Or [string]::IsNullOrEmpty($VMName)) {
        return;
    }

    [decimal]$TimeDelta   = 0;
    [bool]$IsWarning      = $FALSE;
    [string]$CheckName    = ([string]::Format('{0} Blackout Time', $VMName));
    $CheckValue           = 'No migration';
    [hashtable]$CheckArgs = @{
        'Name'        = $CheckName;
        'MetricIndex' = $VMName;
        'MetricName'  = $blackouttime;
    };

    if ([string]::IsNullOrEmpty($BlackoutTimesEventDelta) -eq $FALSE) {
        $TimeDelta = ConvertTo-Seconds -Value $BlackoutTimesEventDelta;
    }

    if ((Test-PSCustomObjectMember -PSObject $HyperVProviderData.Metrics.BlackoutTimes.Warning -Name $VMName)) {
        # Only set the check to warning if a time threshold was given and we the entry is younger than our range
        if ($TimeDelta -eq 0 -Or [DateTime]::Now.AddSeconds($TimeDelta) -le $HyperVProviderData.Metrics.BlackoutTimes.Warning.$VMName.Timestamp) {
            $IsWarning  = $TRUE;
        }

        $CheckValue = $HyperVProviderData.Metrics.BlackoutTimes.Warning.$VMName.BlackoutTime;
        $CheckArgs.Add('Unit', 's');
    } elseif ((Test-PSCustomObjectMember -PSObject $HyperVProviderData.Metrics.BlackoutTimes.Information -Name $VMName)) {
        $CheckValue = $HyperVProviderData.Metrics.BlackoutTimes.Information.$VMName.BlackoutTime;
        $CheckArgs.Add('Unit', 's');
    } else {
        $CheckArgs.Add('NoPerfData', $TRUE);
    }

    $CheckArgs.Add('Value', $CheckValue);

    $CheckObject = New-IcingaCheck @CheckArgs;

    if ($IsWarning) {
        $CheckObject.SetWarning() | Out-Null;
    }

    $CheckPackage.AddCheck($CheckObject);
}
