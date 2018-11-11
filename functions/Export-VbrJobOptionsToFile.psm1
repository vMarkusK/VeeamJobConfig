function Export-VbrJobOptionsToFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$BackupJob,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullorEmpty()]
            [System.IO.FileInfo]$Path
    )

    begin {
    }

    process {
        $BackupJobOptions = $BackupJob.GetOptions()
        $JsonObject = $BackupJobOptions | ConvertTo-Json
        $Object = $JsonObject | ConvertFrom-Json
        $Object.PSObject.Properties.Remove('Options')
        $Object | ConvertTo-Json | Out-File $Path
    }

    end {
    }
}