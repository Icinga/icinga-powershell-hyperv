@{
    ModuleVersion     = '1.0.0'
    GUID              = '65edfa4d-09fc-4640-baee-037705b9d573'
    Author            = 'yhabteab'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2020 Icinga GmbH | GPL v2.0'
    Description       = 'A collection of Hyper-V plugins, which serve to monitor Hyper-V systems'
    PowerShellVersion = '4.0'
    RequiredModules   = @(@{ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.2.0' })
    NestedModules     = @(
        '.\plugins\Invoke-IcingaCheckHyperVHealth.psm1'
    )
    FunctionsToExport = @('*')
    CmdletsToExport   = @('*')
    VariablesToExport = '*'
    AliasesToExport   = @()
    PrivateData       = @{

        PSData  = @{
            Tags         = @('icinga', 'icinga2', 'icingawindows', 'hyper-v', 'hyperv', 'hypervplugins', 'windowsplugins', 'icingaforwindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-hyperv/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-hyperv'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-hyperv/releases'

        };
        Version = 'v1.0.0'
    } 
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-hyperv'
}
