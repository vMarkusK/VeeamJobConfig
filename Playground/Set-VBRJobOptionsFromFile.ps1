function Set-VBRJobOptionsFromFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$BackupJob,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)]
        [ValidateNotNullorEmpty()]
            [String]$ReferenceFile
    )

    begin {
        if (Test-Path $ReferenceFile) {
            $JsonConfig = Get-Content -Raw -Path $ReferenceFile | ConvertFrom-Json
            if ($JsonConfig) {
                $RefBackupStorageOptions = $JsonConfig.BackupStorageOptions
                #$RefBackupTargetOptions  = $JsonConfig.BackupTargetOptions
                $RefJobOptions = $JsonConfig.JobOptions
                $RefNotificationOptions = $JsonConfig.NotificationOptions   
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
        $JobOptions = $BackupJob.GetOptions()
    
        # Set the reference Job Options
        ## BackupStorageOptions
        try {
            $RefBackupStorageOptions.PSObject.Properties | ForEach-Object {
            $JobOptions.BackupStorageOptions.$($_.Name) = $($_.Value)    
            }
        
        }
        catch {
            Throw "Section 'BackupStorageOptions' Failed!"
        }
        
        ## JobOptions
        try {
            $RefJobOptions.PSObject.Properties | ForEach-Object {
            $JobOptions.JobOptions.$($_.Name) = $($_.Value)    
            }
        
        }
        catch {
            Throw "Section 'JobOptions' Failed!"
        }
        
        ## NotificationOptions
        try {
            $RefNotificationOptions.PSObject.Properties | ForEach-Object {
            $JobOptions.NotificationOptions.$($_.Name) = $($_.Value)    
        
            }
        }
        catch {
            Throw "Section 'NotificationOptions' Failed!"
        }
        
        # Update Job Options
        Set-VBRJobOptions $VeeamJob $JobOptions
        
    }
    
}
