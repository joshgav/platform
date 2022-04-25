# NOTE: This is not a script. Rather this is a list of commands to execute to
# set up Active Directory and a user and group.

## Step 1. Install AD and a forest+domain.

Install-WindowsFeature -IncludeManagementTools -Confirm:$false `
    AD-Domain-Services,RSAT-AD-Tools,RSAT-DNS-Server

$safe_mode_password = "$Variable:safe_mode_password"

Install-ADDSForest -DomainName aws.joshgav.com `
    -DomainNetbiosName JOSHGAV `
    -DomainMode WinThreshold `
    -ForestMode WinThreshold `
    -SafeModeAdministratorPassword $(ConvertTo-SecureString ${safe_mode_password} -AsPlainText -Force) `
    -InstallDNS `
    -Confirm:$false

## Step 2. After restart add the following entities to AD

New-ADUser -Name keycloak `
    -Path 'CN=Users,DC=aws,DC=joshgav,DC=com' `
    -DisplayName keycloak `
    -UserPrincipalName 'keycloak@aws.joshgav.com' `
    -AccountPassword $(ConvertTo-SecureString ${safe_mode_password} -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $true

New-ADOrganizationalUnit -Name 'Spring Test App' `
    -Path 'DC=aws,DC=joshgav,DC=com' `
    -DisplayName 'Spring Test App'

New-ADOrganizationalUnit -Name 'Users' `
    -Path 'OU=Spring Test App,DC=aws,DC=joshgav,DC=com' `
    -DisplayName 'Users'

New-ADOrganizationalUnit -Name 'Groups' `
    -Path 'OU=Spring Test App,DC=aws,DC=joshgav,DC=com' `
    -DisplayName 'Groups'

New-ADGroup -Name 'spring' `
    -Path 'OU=Groups,OU=Spring Test App,DC=aws,DC=joshgav,DC=com' `
    -GroupScope Global `
    -DisplayName 'spring'

New-ADUser -Name 'joshgav' `
    -Path 'OU=Users,OU=Spring Test App,DC=aws,DC=joshgav,DC=com' `
    -AccountPassword $(ConvertTo-SecureString ${safe_mode_password} -AsPlainText -Force) `
    -DisplayName 'joshgav' `
    -UserPrincipalName 'joshgav@aws.joshgav.com' `
    -Enabled $true

Add-ADGroupMember -Identity 'CN=spring,OU=Groups,OU=Spring Test App,DC=aws,DC=joshgav,DC=com' `
    -Members 'CN=joshgav,OU=Users,OU=Spring Test App,DC=aws,DC=joshgav,DC=com'

$username = "calebgav"
New-ADUser -Name ${username} `
   -Path 'OU=Users,OU=Spring Test App,DC=aws,DC=joshgav,DC=com' `
   -AccountPassword $(ConvertTo-SecureString ${safe_mode_password} -AsPlainText -Force) `
   -DisplayName ${username} `
   -UserPrincipalName "${username}@aws.joshgav.com" `
   -Enabled $true

Add-ADGroupMember -Identity 'CN=spring,OU=Groups,OU=Spring Test App,DC=aws,DC=joshgav,DC=com' `
    -Members "CN=${username},OU=Users,OU=Spring Test App,DC=aws,DC=joshgav,DC=com"

## Step 3.

# - open port in EC2 Security Group for LDAP (389)
#
# - add A record for msad.aws.joshgav.com to DNS
#     - https://dcc.godaddy.com/manage/joshgav.com/dns
