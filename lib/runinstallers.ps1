param($wpi, $rhc, $chor, $git, $ni)
try {
    if (Test-Path -Path $wpi) {
        Start-Process -FilePath ((Mount-DiskImage -ImagePath $wpi -PassThru | Get-Volume).DriveLetter + ":\WPILibInstaller.exe") -Wait
        Dismount-DiskImage -ImagePath $wpi
        Remove-Item -Path $wpi
    } else {
        Write-Host "WPILib Disk: $wpi not found, skipping..."
    }
    if (Test-Path -Path $rhc) {
        Start-Process $rhc -Wait
        Remove-Item -Path $rhc
    } else {
        Write-Host "REV Hardware Client installer: $rhc not found, skipping..."
    }
    if (Test-Path -Path $chor) {
        Start-Process $chor -Wait
        Remove-Item -Path $chor
    } else {
        Write-Host "Choreo installer: $chor not found, skipping..."
    }
    if (Test-Path -Path $git) {
        Start-Process $git -Wait
        Remove-Item -Path $git
    } else {
        Write-Host "Git for Windows installer: $git not found, skipping..."
    }
    if (Test-Path -Path $ni) {
        Start-Process -FilePath ((Mount-DiskImage -ImagePath $ni -PassThru | Get-Volume).DriveLetter + ":\Install.exe") -Wait
        Dismount-DiskImage -ImagePath $ni
        Remove-Item -Path $ni
    } else {
        Write-Host "NI installer: $ni not found, skipping..."
    }
} catch {
    Write-Error $_;
}
Pause
