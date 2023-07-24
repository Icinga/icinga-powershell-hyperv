<#
.SYNOPSIS
    Tests if the vmms service is installed which indicates if the Hyper-V
    role is installed on the system without requiring administrative privileges
.DESCRIPTION
    Tests if the vmms service is installed which indicates if the Hyper-V
    role is installed on the system without requiring administrative privileges
.OUTPUTS
    System.Boolean
.LINK
    https://github.com/Icinga/icinga-powershell-hyperv
#>

function Test-IcingaHyperVInstalled()
{
    if (Get-Service -Name 'vmms' -ErrorAction SilentlyContinue) {
        return $TRUE;
    }

    return $FALSE;
}
