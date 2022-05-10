## NOTE: This is not a script at the moment - it's a series of commands to execute manually.

## TODO: read env vars from .env
$password = $password
$domainName = $domainName
$netbiosDomainName = $netbiosDomainName
$clientRedirectUri = $clientRedirectUri

$adfsUserName = 'adfs'
$subjectName = "${adfsUserName}.${domainName}"

Install-WindowsFeature ADFS-Federation –IncludeManagementTools

$cert = New-SelfSignedCertificate `
    -Subject "CN=${subjectName}" `
    -DnsName "${subjectName}" `
    -CertStoreLocation "cert:\LocalMachine\My"

New-ADUser -Name $adfsUserName `
    -Path 'CN=Users,DC=aws,DC=joshgav,DC=com' `
    -DisplayName $adfsUserName `
    -UserPrincipalName "${adfsUserName}@${domainName}" `
    -AccountPassword $(ConvertTo-SecureString ${password} -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $true

$cred = Get-Credential ${netbiosDomainName}\${adfsUserName}
Install-AdfsFarm `
    -CertificateThumbprint "${cert.Thumbprint}" `
    -FederationServiceName "$subjectName" `
    -ServiceAccountCredential $cred
