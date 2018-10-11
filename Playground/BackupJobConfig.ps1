Add-PSSnapin VeeamPssnapin
$VeeamCred = Get-Credential
Connect-VBRServer -Server "veeam-01.lab.local" -Credential $VeeamCred

##
$ConfigFile = "C:\Users\Administrator\Documents\PowerShell\VeeamJobConfig\Playground\BackupJobOptions.json"
$JsonConfig = Get-Content -Raw -Path $ConfigFile | ConvertFrom-Json

$RefBackupStorageOptions = $JsonConfig.BackupStorageOptions
#$RefBackupTargetOptions  = $JsonConfig.BackupTargetOptions
$RefJobOptions = $JsonConfig.JobOptions
$RefNotificationOptions = $JsonConfig.NotificationOptions

##
[Array]$VeeamJobs = Get-VBRJob -Name "Backup Job 1"
foreach ($VeeamJob in $VeeamJobs) {
    # Get the actual Job Options 
    $JobOptions = $VeeamJob.GetOptions()

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