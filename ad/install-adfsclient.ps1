## NOTE: This is not a script at the moment - it's a series of commands to execute manually.

$clientRedirectUri = $clientRedirectUri

$clientId = New-Guid | % Guid

Add-AdfsClient -ClientId $clientId `
    -Name 'keycloak-client' `
    -RedirectUri $clientRedirectUri `
    -ClientType Confidential `
    -GenerateClientSecret

# Grab ClientId and ClientSecret from output. Will be needed in Keycloak.

$content = @(
    '-----BEGIN CERTIFICATE-----'
    [System.Convert]::ToBase64String($cert.RawData, 'InsertLineBreaks')
    '-----END CERTIFICATE-----'
)

Set-Content -Path ${env:USERPROFILE}/adfs.crt -Value $content -Encoding ASCII 

# Copy certificate file contents to be set as a secret in Kubernetes.
# more info: https://access.redhat.com/solutions/6164982
