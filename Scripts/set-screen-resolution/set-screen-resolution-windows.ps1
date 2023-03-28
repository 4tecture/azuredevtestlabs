Param(
    [int]$Width = 1920,
    [int]$Height = 1080
)

Get-ChildItem -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Video\' | ForEach-Object {
    $KeyPath = $_.PSPath + '\0000\DefaultSettings'

    Write-Host "Set default screen resolution for '$($KeyPath)' to '$($Width)' x '$($Height)'"
    try {
        Get-ItemProperty -Path $KeyPath -Name 'XResolution' -ErrorAction Stop

        Set-ItemProperty -Path $KeyPath -Name 'XResolution' -Value $Width -Type DWORD
        Set-ItemProperty -Path $KeyPath -Name 'YResolution' -Value $Height -Type DWORD
    }  
    catch [System.Management.Automation.ItemNotFoundException] {  
        New-Item -Path $KeyPath -Force  
        New-ItemProperty -Path $KeyPath -Name 'XResolution' -Value $Width -Force
        New-ItemProperty -Path $KeyPath -Name 'YResolution' -Value $Height -Force
    }  
    catch {
        New-ItemProperty -Path $KeyPath -Name 'XResolution' -Value $Width -Type DWORD -Force
        New-ItemProperty -Path $KeyPath -Name 'YResolution' -Value $Height -Type DWORD -Force
    } 
}
