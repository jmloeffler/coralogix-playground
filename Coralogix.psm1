Function Write-CoralogixLog {
    param(
        [string] $applicationName, 
        [string] $subsystemName, 
        [string] $computerName, 
        [int] $severity, 
        [Parameter(Mandatory = $true)]
        [string] $text, 
        [string] $cxDomain,
        [string] $cxApiKey)

    if ($severity -eq 0) { 
        $severity = 3 
    }

    if ($cxDomain -eq $null) {
        $cxDomain = $env:CX_DOMAIN
    }

    if ($cxApiKey -eq $null) {
        $cxApiKey = $env:CX_API_KEY
    }

    $body = @{
        "applicationName" = $applicationName
        "subsystemName"   = $subsystemName
        "computerName"    = $computerName
        "severity"        = $severity
        "text"            = $text
    }

    $bodyDocument = $body | ConvertTo-Json -AsArray

    try {
        Invoke-RestMethod -Uri "https://ingress.$cxDomain/logs/v1/singles" `
            -Headers @{ "Authorization" = "Bearer $cxApiKey" } `
            -ContentType "application/json" `
            -Method Post `
            -Body $bodyDocument | Out-Null
    }
    catch {
        Write-Warning "Unable to send log to Coralogix"
    }
}