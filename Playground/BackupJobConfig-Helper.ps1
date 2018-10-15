Add-PSSnapin VeeamPssnapin
$VeeamCred = Get-Credential
Connect-VBRServer -Server "veeam-01.lab.local" -Credential $VeeamCred