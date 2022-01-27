@{
    ModuleVersion     = '1.1.0'
    GUID              = '65edfa4d-09fc-4640-baee-037705b9d573'
    Author            = 'Yonas Habteab, Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2020 Icinga GmbH | GPL v2.0'
    Description       = 'A collection of Hyper-V plugins, which serve to monitor Hyper-V systems'
    PowerShellVersion = '4.0'
    RequiredModules   = @(
        @{ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.8.0' },
        @{ModuleName = 'icinga-powershell-plugins'; ModuleVersion = '1.5.0' }
    )
    NestedModules     = @(
        '.\plugins\Invoke-IcingaCheckHyperVHealth.psm1',
        '.\plugins\Invoke-IcingaCheckHyperVOverCommitment.psm1',
        '.\plugins\Invoke-IcingaCheckHyperVSnapshot.psm1',
        '.\plugins\Invoke-IcingaCheckHyperVVirtualSwitches.psm1',
        '.\plugins\Invoke-IcingaCheckHyperVVMHealth.psm1',
        '.\provider\enums\Icinga_HypervProviderEnums.psm1',
        '.\provider\hyperv\Get-IcingaHypervHostInfo.psm1',
        '.\provider\hyperv\Test-IcingaHyperVInstalled.psm1',
        '.\provider\vcomputer\Get-IcingaHypervVirtualSwitches.psm1',
        '.\provider\vcomputer\Get-IcingaVirtualComputerInfo.psm1'
    )
    FunctionsToExport = @('*')
    CmdletsToExport   = @('*')
    VariablesToExport = '*'
    AliasesToExport   = @()
    PrivateData       = @{
        PSData   = @{
            Tags         = @('icinga', 'icinga2', 'icingawindows', 'hyper-v', 'hyperv', 'hypervplugins', 'windowsplugins', 'icingaforwindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-hyperv/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-hyperv'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-hyperv/releases'
        };
        Version  = 'v1.1.0'
        Name     = 'Windows Hyper-V';
        Type     = 'plugins';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-hyperv'
}

