Param(
    [Parameter(Mandatory = $true)][string] $certificateName,
    [Parameter(Mandatory = $true)][string] $base64cert,
    [string] $certificatePassword = '',
    [string] $certStoreLocation = 'LocalMachine\My'
)

##################################################################################################
#
# Powershell Configurations
#

# Note: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.  
#       This is necessary to ensure we capture errors inside the try-catch-finally block.
$ErrorActionPreference = "Stop"

##################################################################################################
#
# Handle all errors in this script.
#

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

###################################################################################################
#
# Main execution block.
#

Write-Host "Installing certificate '$($certificateName)' on location '$($certStoreLocation)'"

$tempFilePath = [System.IO.Path]::GetTempFileName()
Write-Host "Temp file path '$tempFilePath'" 

[System.IO.File]::WriteAllBytes($tempFilePath, [System.Convert]::FromBase64String($base64cert))
Write-Host "Certificate saved"

if ($certificatePassword) {
    Write-Host "Certificate Password is set, import certificate as PFX (X.509)"

    $securePassword = ConvertTo-SecureString -String $certificatePassword -AsPlainText -Force
    $certificatePassword = "deleted"

    Get-ChildItem -Path "$($tempFilePath)" | Import-PfxCertificate -CertStoreLocation "Cert:\$($certStoreLocation)" -Exportable -Password "$($securePassword)"
    Write-Host "PFX Certificate $($certificateName) added to the $($certStoreLocation) store succesfully."
}
else {
    Get-ChildItem -Path "$($tempFilePath)" | Import-Certificate -CertStoreLocation "Cert:\$($certStoreLocation)"
    Write-Host "Certificate $($certificateName) added to the $($certStoreLocation) store succesfully."
}

Remove-Item -Path "$($tempFilePath)" -Force
Write-Host "Deleted the temp file $($tempFilePath)"

Write-Host "`nThe artifact was applied successfully.`n"
