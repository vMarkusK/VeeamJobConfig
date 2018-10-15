function Set-VBRJobOptionsFromRef {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$BackupJob,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)]
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