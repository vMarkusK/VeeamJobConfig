$moduleRoot = Resolve-Path "$PSScriptRoot\.."
$moduleName = "VeeamJobConfig"
$moduleManifest = "$moduleRoot\$moduleName.psd1"

$EncryptedCred = "$env:LOCALAPPDATA\vscode-powershell\EncryptedVeeamCred.clixml"
if (Test-Path -LiteralPath $EncryptedCred -ErrorAction SilentlyContinue) {
    $Credentials = Import-CliXml $EncryptedCred
}
else {
    $Credentials = Get-Credential
    $Credentials | Export-CliXml "$env:LOCALAPPDATA\vscode-powershell\EncryptedVeeamCred.clixml"
}

$VeeamFqdn = "$env:LOCALAPPDATA\vscode-powershell\VeeamFqdn.txt"
if (Test-Path -LiteralPath $VeeamFqdn) {
    [String]$FQDN = Get-Content "$env:LOCALAPPDATA\vscode-powershell\VeeamFqdn.txt"
}
else {
    [String]$FQDN = Read-Host -Prompt 'FQDN'
    $FQDN | Out-File -FilePath "$env:LOCALAPPDATA\vscode-powershell\VeeamFqdn.txt"
}


Describe "General Code validation: $moduleName" {

    $scripts = Get-ChildItem $moduleRoot -Include *.psm1, *.ps1, *.psm1 -Recurse
    $testCase = $scripts | Foreach-Object {@{file = $_}}
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist
        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    $modules = Get-ChildItem $moduleRoot -Include *.psd1 -Recurse
    $testCase = $modules | Foreach-Object {@{file = $_}}
    It "Module <file> can import cleanly" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist
        $error.clear()
        {Import-Module  $file.fullname } | Should Not Throw
        $error.Count | Should Be 0
    }
}

Context 'Manifest Testing' {
    It 'Valid Module Manifest' {
        {
            $Script:Manifest = Test-ModuleManifest -Path $ModuleManifest -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }
    It 'Valid Manifest Name' {
        $Script:Manifest.Name | Should be $ModuleName
    }
    It 'Generic Version Check' {
        $Script:Manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }
    It 'Valid Manifest Description' {
        $Script:Manifest.Description | Should Not BeNullOrEmpty
    }
    It 'No Format File' {
        $Script:Manifest.ExportedFormatFiles | Should BeNullOrEmpty
    }

}

Context 'Exported Functions' {
    $ExportedFunctions = (Get-ChildItem -Path "$moduleRoot\functions" -Filter *.psm1 | Select-Object -ExpandProperty Name ) -replace '\.psm1$'
    $testCase = $ExportedFunctions | Foreach-Object {@{FunctionName = $_}}
    It "Function <FunctionName> should be in manifest" -TestCases $testCase {
        param($FunctionName)
        $ManifestFunctions = $Manifest.ExportedFunctions.Keys
        $FunctionName -in $ManifestFunctions | Should Be $true
    }

    It 'Proper Number of Functions Exported compared to Manifest' {
        $ExportedCount = Get-Command -Module $ModuleName -CommandType Function | Measure-Object | Select-Object -ExpandProperty Count
        $ManifestCount = $Manifest.ExportedFunctions.Count

        $ExportedCount | Should be $ManifestCount
    }

    It 'Proper Number of Functions Exported compared to Files' {
        $ExportedCount = Get-Command -Module $ModuleName -CommandType Function | Measure-Object | Select-Object -ExpandProperty Count
        $FileCount = Get-ChildItem -Path "$moduleRoot\functions" -Filter *.psm1 | Measure-Object | Select-Object -ExpandProperty Count

        $ExportedCount | Should be $FileCount
    }

}

Context 'Test Functions' {
    Add-PSSnapin VeeamPssnapin
    Disconnect-VBRServer -ErrorAction SilentlyContinue
    Connect-VBRServer -Server $FQDN -Credential $Credentials

    It 'Export-VbrJobOptionsToFile'{
        {Remove-Module -Name VeeamJobConfig -Force:$true -ErrorAction SilentlyContinue; Import-Module  $moduleManifest } | Should Not Throw
        {Get-VBRJob -Name "Backup Job 1" | Export-VbrJobOptionsToFile -Path  "$moduleRoot/TEMPBackupJobOptions.json" } | Should Not Throw
    }

    It 'Set-VBRJobOptionsFromRef'{
        {Remove-Module -Name VeeamJobConfig -Force:$true -ErrorAction SilentlyContinue; Import-Module  $moduleManifest } | Should Not Throw
        {$VeeamJob = Get-VBRJob -Name "Backup Job 2"; $VeeamRefJob = Get-VBRJob -Name "Backup Job 1"; Set-VBRJobOptionsFromRef -BackupJob $VeeamJob -ReferenceBackupJob $VeeamRefJob} | Should Not Throw
    }

    It 'Set-VBRJobOptionsFromFile'{
        {Remove-Module -Name VeeamJobConfig -Force:$true -ErrorAction SilentlyContinue; Import-Module  $moduleManifest } | Should Not Throw
        {Get-VBRJob -Name "Backup Job 2" | Set-VBRJobOptionsFromFile -ReferenceFile "$moduleRoot/TEMPBackupJobOptions.json" -BackupStorageOptions -JobOptions -NotificationOptions -ViSourceOptions -SqlLogBackupOptions} | Should Not Throw
    }


}