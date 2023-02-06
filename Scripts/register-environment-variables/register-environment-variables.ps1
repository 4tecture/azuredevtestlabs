Param(
    [Parameter(Mandatory = $true)][String[]]$environmentVariables,
    [string]$environmentVariableTarget # Machine, Process, User -> only for windows
)

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
