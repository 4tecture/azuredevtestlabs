Param(
    [int]$Width = 1920,
    [int]$Height = 1080,
    [string]$UserAccount = ''
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

$baseKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Video\'
$baseKeySubPath = '\0000'

Get-ChildItem -Path $baseKey | ForEach-Object {
    # Set ACL access rule
    if (-not $UserAccount) {
        $UserAccount = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    }

    Write-Host "Set ACL access rule for user $($UserAccount)"
    $ke = Get-Acl "$($baseKey)$($_.PSChildname)$($baseKeySubPath)"
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule ($UserAccount, "FullControl", "Allow")
    $ke.SetAccessRule($rule)
    $ke | Set-Acl -Path "$($baseKey)$($_.PSChildname)$($baseKeySubPath)"

    # set registry keys for default resolution
    $KeyPath = $_.PSPath + $baseKeySubPath
    Write-Host "Set default screen resolution for '$($KeyPath)' to $($Width)x$($Height)"
    try {
        Get-ItemProperty -Path $KeyPath -Name "DefaultSettings.XResolution"

        Set-ItemProperty -Path $KeyPath -Name "DefaultSettings.XResolution" -Value $Width
        Set-ItemProperty -Path $KeyPath -Name "DefaultSettings.YResolution" -Value $Height
    }  
    catch [System.Management.Automation.ItemNotFoundException] {  
        New-ItemProperty -Path $KeyPath -Name "DefaultSettings.XResolution" -Value $Width -Force
        New-ItemProperty -Path $KeyPath -Name "DefaultSettings.YResolution" -Value $Height -Force
    }  
    catch {
        New-ItemProperty -Path $KeyPath -Name "DefaultSettings.XResolution" -Value $Width -PropertyType DWORD -Force
        New-ItemProperty -Path $KeyPath -Name "DefaultSettings.YResolution" -Value $Height -PropertyType DWORD -Force
    } 
}
