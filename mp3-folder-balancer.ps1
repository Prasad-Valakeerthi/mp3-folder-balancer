# -------- CONFIG --------
$limit = 255

# -------- USB DETECTION --------
function Get-USBDrive {
    $usbDrives = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 2}
    foreach ($drive in $usbDrives) {
        return ($drive.DeviceID + "\")
    }
    return $null
}

$usbRoot = Get-USBDrive

if (!$usbRoot) {
    Write-Host "USB not found."
    exit
}

$usbPath = Join-Path $usbRoot "Music"

if (!(Test-Path $usbPath)) {
    Write-Host "Music folder not found."
    exit
}

Write-Host "Using USB: $usbPath"

# -------- MAIN LOOP --------
$continue = $true
$totalMoved = 0

while ($continue) {
    $continue = $false

    $folders = Get-ChildItem $usbPath -Directory | Sort-Object {[int]$_.Name}

    for ($i = 0; $i -lt $folders.Count; $i++) {

        $folder = $folders[$i]
        $currentPath = $folder.FullName
        $currentNumber = [int]$folder.Name

        $files = Get-ChildItem $currentPath -File |
            Where-Object { $_.Extension -ieq ".mp3" } |
            Sort-Object Name

        if ($files.Count -gt 255) {

            $overflow = $files[$limit..($files.Count - 1)]

            foreach ($file in $overflow) {

                $nextNumber = $currentNumber + 1
                $nextFolderName = "{0:D2}" -f $nextNumber
                $nextPath = Join-Path $usbPath $nextFolderName

                if (!(Test-Path $nextPath)) {
                    New-Item -ItemType Directory -Path $nextPath | Out-Null
                    Write-Host "Created folder: $nextFolderName"
                }

                Write-Host ("Moving: {0} → {1}" -f $file.Name, $nextFolderName)
                Move-Item $file.FullName $nextPath

                $totalMoved++
                $continue = $true
            }
        }
    }
}

Write-Host "-----------------------------------"
Write-Host "Done."
Write-Host "Total files moved: $totalMoved"
