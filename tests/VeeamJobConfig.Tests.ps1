$moduleRoot = Resolve-Path "$PSScriptRoot\.."
$moduleName = "VeeamJobConfig"
$moduleManifest = "$moduleRoot\$moduleName.psd1"

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