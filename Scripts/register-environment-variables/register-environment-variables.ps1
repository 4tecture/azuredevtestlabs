Param(
    [Parameter(Mandatory = $true)][String[]]$environmentVariables,
    [string]$environmentVariableTarget # Machine, Process, User -> only for windows
)

$ErrorActionPreference = "Stop"

trap {
    # NOTE: This trap will handle all errors. There should be no need to use a catch below in this
    #       script, unless you want to ignore a specific error.
    $message = $Error[0].Exception.Message
    if ($message) {
        Write-Host -Object "`nERROR: $message" -ForegroundColor Red
    }

    Write-Host "`nThe artifact failed to apply.`n"

    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still
    # returns exit code zero from the PowerShell script when using -File. The workaround is to
    # NOT use -File when calling this script and leverage the try-catch-finally block and return
    # a non-zero exit code from the catch block.
    exit -1
}

if ($environmentVariables) {
    Write-Host "$($environmentVariables.Count) environment variables found for registration"

    foreach ($envVariable in $environmentVariables) {
        if ($envVariable -and $envVariable.Contains('=')) {
            $key = $envVariable.Split('=')[0]
            $value = $envVariable.Split('=')[1]
            if ($environmentVariableTarget) {
                # This value should be used on Windows systems only.
                [System.Environment]::SetEnvironmentVariable($key, $value, $environmentVariableTarget)
                Write-Host "Register environment variable '$($key)' with value '$($value)' on target '$($environmentVariableTarget)'"
            }
            else {
                [System.Environment]::SetEnvironmentVariable($key, $value)
                Write-Host "Register environment variable '$($key)' with value '$($value)'"
            }
        }
        else {
            Write-Warning "Cannot register '$($envVariable)' as environment variable: wrong format"
        }
    }
}
