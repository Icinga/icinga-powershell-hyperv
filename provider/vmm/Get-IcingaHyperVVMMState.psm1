function Get-IcingaHyperVVMMState()
{
    param (
        [string]$Hostname,
        [array]$IncludeHost = @(),
        [array]$ExcludeHost = @()
    );

    [hashtable]$VMMRetValue = @{ };

    if ([string]::IsNullOrEmpty($Hostname)) {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'VMM Host not specified' -InputString 'You have to specify a hostname to check the VMM state for.' -Force;

        return $VMMRetValue;
    }

    if ((Test-IcingaFunction -Name 'Get-SCVMHost') -eq $FALSE) {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'VMM not installed' -InputString 'The Cmdlet "Get-SCVMHost" was not found on this host, which could mean the Virtual Machine Manager (VMM) is not installed.' -Force;

        return $VMMRetValue;
    }

    try {
        $VMMStatus = Get-SCVMHost -VMMServer $Hostname -ErrorAction Stop | Select-Object 'ComputerName', 'OverallState';
    } catch {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'VMM fetch error' -InputString $_.Exception.Message -Force;

        return $VMMRetValue;
    }

    foreach ($entry in $VMMStatus) {

        [bool]$AddEntry = $FALSE;

        if ($IncludeHost.Count -ne 0) {
            foreach ($filter in $IncludeHost) {
                if ($entry.ComputerName.ToLower() -Like $filter.ToLower()) {
                    $AddEntry = $TRUE;
                    break;
                }
            }
        }

        if ($ExcludeHost.Count -ne 0) {
            foreach ($filter in $ExcludeHost) {
                if ($entry.ComputerName.ToLower() -Like $filter.ToLower()) {
                    $AddEntry = $FALSE;
                    break;
                }
            }
        }

        if ($IncludeHost.Count -eq 0 -And $ExcludeHost.Count -eq 0) {
            $AddEntry = $TRUE;
        }

        if ($AddEntry -eq $FALSE) {
            continue;
        }

        $VMMRetValue.Add($entry.ComputerName, [string]$entry.OverallState);
    }

    return $VMMRetValue;
}
