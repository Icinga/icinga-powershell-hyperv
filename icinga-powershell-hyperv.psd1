@{
    ModuleVersion     = '1.4.0'
    GUID              = '65edfa4d-09fc-4640-baee-037705b9d573'
    Author            = 'Yonas Habteab, Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2023 Icinga GmbH | GPL v2.0'
    Description       = 'A collection of Hyper-V plugins, which serve to monitor Hyper-V systems'
    PowerShellVersion = '4.0'
    RequiredModules   = @(
        @{ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.12.0' },
        @{ModuleName = 'icinga-powershell-plugins'; ModuleVersion = '1.10.0' }
    )
    NestedModules     = @(
        '.\compiled\icinga-powershell-hyperv.ifw_compilation.psm1'
    )
    FunctionsToExport     = @(
        'Import-IcingaPowerShellComponentHyperV',
        'Invoke-IcingaCheckHyperVDuplicateVM',
        'Invoke-IcingaCheckHyperVHealth',
        'Invoke-IcingaCheckHyperVOverCommitment',
        'Invoke-IcingaCheckHyperVSnapshot',
        'Invoke-IcingaCheckHyperVVirtualSwitches',
        'Invoke-IcingaCheckHyperVVMHealth',
        'Invoke-IcingaCheckHyperVVMM'
    )
    CmdletsToExport     = @(
    )
    VariablesToExport     = @(
        'HypervProviderEnums'
    )
    PrivateData       = @{
        PSData   = @{
            Tags         = @('icinga', 'icinga2', 'icingawindows', 'hyper-v', 'hyperv', 'hypervplugins', 'windowsplugins', 'icingaforwindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-hyperv/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-hyperv'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-hyperv/releases'
        };
        Version  = 'v1.4.0'
        Name     = 'Windows Hyper-V';
        Type     = 'plugins';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-hyperv'
}

