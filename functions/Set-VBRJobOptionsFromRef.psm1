function Set-VBRJobOptionsFromRef {
    <#
    .SYNOPSIS
    Set Veeam Backup Job options from a refrence Backup Job

    .DESCRIPTION
    Set Veeam Backup Job options from a refrence Backup Job

    .PARAMETER BackupJob
    Veeam Backup Job to modify

    .PARAMETER ReferenceBackupJob
    Veeam reference Backup Job

    .EXAMPLE
    $VeeamJob = Get-VBRJob -Name "Template Job "
    $VeeamRefJob = Get-VBRJob -Name "Backup Job 1"
    Set-VBRJobOptionsFromRef -BackupJob $VeeamJob -ReferenceBackupJob $VeeamRefJob

    .EXAMPLE
    $VeeamRefJob = Get-VBRJob -Name "Backup Job 1"
    Get-VBRJob -Name "Backup Job*" | Set-VBRJobOptionsFromRef -ReferenceBackupJob $VeeamRefJob

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Veeam Backup Job to modify")]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$BackupJob,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="Veeam reference Backup Job ")]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$ReferenceBackupJob
    )

    process {
        try {
            $JobRefOptions = $ReferenceBackupJob.GetOptions()
        }
        catch {
            throw "Get Options Failed for '$($ReferenceBackupJob.Name)'"
        }


        try {
            Set-VBRJobOptions -Job $BackupJob -Options $JobRefOptions
        }
        catch {
            throw "Set Options Failed for '$($BackupJob.Name)'"

        }

    }

}