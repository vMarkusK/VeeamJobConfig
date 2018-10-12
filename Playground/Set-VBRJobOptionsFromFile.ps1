function Set-VBRJobOptionsFromFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullorEmpty()]
            [Veeam.Backup.Core.CBackupJob]$BackupJob,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false)]
        [ValidateNotNullorEmpty()]
            [String]$ReferenceFile,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$BackupStorageOptions,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$JobOptions,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
            [Switch]$NotificationOptions
        
    )

    begin {
        if (Test-Path $ReferenceFile) {
            $JsonConfig = Get-Content -Raw -Path $ReferenceFile | ConvertFrom-Json
            if ($JsonConfig) {
                if ($BackupStorageOptions) {
                    $RefBackupStorageOptions = $JsonConfig.BackupStorageOptions    
                }
                #$RefBackupTargetOptions  = $JsonConfig.BackupTargetOptions
                if ($JobOptions) {
                    $RefJobOptions = $JsonConfig.JobOptions   
                }
                if ($NotificationOptions) {
                    $RefNotificationOptions = $JsonConfig.NotificationOptions       
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
        # Update Job Options
        try {
            "Update All Options for '$($BackupJob.Name)' ..."
            $Trash = Set-VBRJobOptions $VeeamJob $JobOptionsToUpdate  

            }
            catch {
                Throw "Update All Options Failed!"
            }
            
        
        
    }
    
}
