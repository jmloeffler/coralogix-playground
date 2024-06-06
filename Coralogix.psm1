enum LogSeverity {
    Debug = 1
    Verbose = 2
    Info = 3
    Warn = 4
    Error = 5
    Critical = 6
}

Function Write-CoralogixLog {
    param(
        [string] $ApplicationName = [System.Diagnostics.Process]::GetCurrentProcess().ProcessName, 
        [string] $SubsystemName = [System.Diagnostics.Process]::GetCurrentProcess().Product, 
        [string] $ComputerName = $env:COMPUTERNAME, 
        [LogSeverity] $Severity = [LogSeverity]::Info, 
        [Parameter(Mandatory = $true)]
        [string] $Text, 
        [string] $CxDomain = $env:CX_DOMAIN,
        [string] $CxApiKey = $env:CX_API_KEY)

    $body = @{
        "applicationName" = $ApplicationName
        "subsystemName"   = $SubsystemName
        "computerName"    = $ComputerName
        "severity"        = $Severity
        "text"            = $Text
    }

    $bodyDocument = $body | ConvertTo-Json -AsArray

    Write-Verbose $bodyDocument

    try {
        Invoke-RestMethod -Uri "https://ingress.$CxDomain/logs/v1/singles" `
            -Headers @{ "Authorization" = "Bearer $CxApiKey" } `
            -ContentType "application/json" `
            -Method Post `
            -Body $bodyDocument | Out-Null
    }
    catch {
        Write-Warning "Unable to send log to Coralogix"
    }
}