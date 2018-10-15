VeeamJobConfig PowerShell Module
=============

# About

## Project Owner:

Markus Kraus [@vMarkus_K](https://twitter.com/vMarkus_K)

MY CLOUD-(R)EVOLUTION [mycloudrevolution.com](http://mycloudrevolution.com/)

## Project WebSite:

[mycloudrevolution.com](http://mycloudrevolution.com/)

## Project Documentation:

[Read the Docs](http://readthedocs.io/)

## Project Description:

The 'VeeamJobConfig' PowerShell Module ...

# Project Details

## Set-VBRJobOptionsFromRef

 ```PowerShell
$VeeamJob = Get-VBRJob -Name "Backup Job 2"
$VeeamRefJob = Get-VBRJob -Name "Backup Job 1"
Set-VBRJobOptionsFromRef -BackupJob $VeeamJob -ReferenceBackupJob $VeeamRefJob
```
![Set-VBRJobOptionsFromRef](/media/Set-VBRJobOptionsFromRef.png)