function Set-VBRJobOptionsFromFile {
    <#
    .SYNOPSIS
    Set Veeam Backup Job options from reference file

    .DESCRIPTION
    Set Veeam Backup Job options from reference file. The File can be created with the function 'Export-VbrJobOptionsToFile'

    .PARAMETER BackupJob
    Veeam Backup Job to Modify

    .PARAMETER ReferenceFile
    The Backup Job options reference file

    .PARAMETER BackupStorageOptions
    Modify BackupStorageOptions

    .PARAMETER JobOptions
    Modify JobOptions

    .PARAMETER NotificationOptions
    Modify NotificationOptions

    .PARAMETER ViSourceOptions
    Modify ViSourceOptions

    .PARAMETER SqlLogBackupOptions
    Modify SqlLogBackupOptions

    .EXAMPLE
    Get-VBRJob -Name "Backup Job*" | Set-VBRJobOptionsFromFile -ReferenceFile "C:\temp\ExampleJobOptions.json" -BackupStorageOptions

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Veeam Backup Job to Modify")]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$BackupJob,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="The Backup Job options reference file")]
        [ValidateNotNullorEmpty()]
            [String]$ReferenceFile,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$BackupStorageOptions,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$JobOptions,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$NotificationOptions,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$ViSourceOptions,
        #[Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        #    [Switch]$SanIntegrationOptions,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$SqlLogBackupOptions

    )

    begin {
        if (Test-Path $ReferenceFile) {
            $JsonConfig = Get-Content -Raw -Path $ReferenceFile | ConvertFrom-Json
            if ($JsonConfig) {
                if ($BackupStorageOptions) {
                    $RefBackupStorageOptions = $JsonConfig.BackupStorageOptions
                }
                if ($JobOptions) {
                    $RefJobOptions = $JsonConfig.JobOptions
                }
                if ($NotificationOptions) {
                    $RefNotificationOptions = $JsonConfig.NotificationOptions
                }
                if ($ViSourceOptions) {
                    $RefViSourceOptions = $JsonConfig.ViSourceOptions
                }
                <#
                if ($SanIntegrationOptions) {
                    $RefSanIntegrationOptions = $JsonConfig.SanIntegrationOptions
                }
                #>
                if ($SqlLogBackupOptions) {
                    $RefSqlLogBackupOptions = $JsonConfig.SqlLogBackupOptions
                }

            }
            else {
                Throw "No Valid Reference File Config"
            }

        }
        else {
            Throw "Reference File not Found"
        }

    }

    process {
        # Get the actual Job Options
        try {
            "Get All Options from '$($BackupJob.Name)' ..."
            $JobOptionsToUpdate = $BackupJob.GetOptions()
        }
        catch {
            Throw "Get All Backup Job Options Failed"
        }

        # Set the reference Job Options
        ## BackupStorageOptions
        if ($BackupStorageOptions) {
            try {
                "Set Backup-Storage Options ..."
                $RefBackupStorageOptions.PSObject.Properties | ForEach-Object {
                $JobOptionsToUpdate.BackupStorageOptions.$($_.Name) = $($_.Value)
                }

            }
            catch {
                Throw "Section 'BackupStorageOptions' Failed!"
            }
        }

        ## JobOptions
        if ($JobOptions) {
            try {
                "Set Job Options ..."
                $RefJobOptions.PSObject.Properties | ForEach-Object {
                $JobOptionsToUpdate.JobOptions.$($_.Name) = $($_.Value)
                }

            }
            catch {
                Throw "Section 'JobOptions' Failed!"
            }
        }

        ## NotificationOptions
        if ($NotificationOptions) {
            try {
                "Set Notification Options ..."
                $RefNotificationOptions.PSObject.Properties | ForEach-Object {
                $JobOptionsToUpdate.NotificationOptions.$($_.Name) = $($_.Value)

                }
            }
            catch {
                Throw "Section 'NotificationOptions' Failed!"
            }

        }

        ## ViSourceOptions
        if ($ViSourceOptions) {
            try {
                "Set ViSourceOptions Options ..."
                $RefViSourceOptions.PSObject.Properties | ForEach-Object {
                $JobOptionsToUpdate.ViSourceOptions.$($_.Name) = $($_.Value)

                }
            }
            catch {
                Throw "Section 'ViSourceOptions' Failed!"
            }

        }
        ## SanIntegrationOptions
        <#
        if ($SanIntegrationOptions) {
            try {
                "Set SanIntegrationOptions Options ..."
                $RefSanIntegrationOptions.PSObject.Properties | ForEach-Object {
                $JobOptionsToUpdate.SanIntegrationOptions.$($_.Name) = $($_.Value)

                }
            }
            catch {
                Throw "Section 'SanIntegrationOptions' Failed!"
            }

        }
        #>
        ## SqlLogBackupOptions
        if ($SqlLogBackupOptions) {
            try {
                "Set SqlLogBackupOptions Options ..."
                $RefSqlLogBackupOptions.PSObject.Properties | ForEach-Object {
                $JobOptionsToUpdate.SqlLogBackupOptions.$($_.Name) = $($_.Value)

                }
            }
            catch {
                Throw "Section 'SqlLogBackupOptions' Failed!"
            }

        }
        # Update Job Options
        try {
            "Update All Options for '$($BackupJob.Name)' ..."
            $Trash = Set-VBRJobOptions $BackupJob $JobOptionsToUpdate

            }
            catch {
                Throw "Update All Options Failed!"
            }

    }

}
