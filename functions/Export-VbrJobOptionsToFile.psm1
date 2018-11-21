function Export-VbrJobOptionsToFile {
    <#
    .SYNOPSIS
    Exports the Veeam Backup Jobs Options to a JSON File

    .DESCRIPTION
    Exports the Veeam Backup Jobs Options to a JSON File.

    .PARAMETER BackupJob
    Veeam Backup Job

    .PARAMETER Path
    Path of the JSON file to export

    .EXAMPLE
    Export-VbrJobOptionsToFile -BackupJob $(Get-VBRJob -Name "Template Job 1") -Path "C:\temp\ExampleJobOptions.json"

    .EXAMPLE
    Get-VBRJob -Name "Template Job 1" | Export-VbrJobOptionsToFile -Path "C:\temp\ExampleJobOptions.json"

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Veeam Backup Job")]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$BackupJob,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="Path of the JSON file to export")]
        [ValidateNotNullorEmpty()]
            [System.IO.FileInfo]$Path
    )

    process {
        $BackupJobOptions = $BackupJob.GetOptions()
        $JsonObject = $BackupJobOptions | ConvertTo-Json
        $Object = $JsonObject | ConvertFrom-Json
        $Object.PSObject.Properties.Remove('Options')
        $Object | ConvertTo-Json | Out-File $Path
    }

}