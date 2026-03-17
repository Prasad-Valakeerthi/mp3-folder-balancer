# -------- CONFIG --------
$limit = 255

# -------- USB DETECTION --------
$UsbDrives = Get-CimInstance Win32_LogicalDisk |
    Where-Object { $_.DriveType -eq 2 }

$MusicRoot = $null

foreach ($Drive in $UsbDrives) {
    if (Test-Path "$($Drive.DeviceID)\Music") {
        $MusicRoot = "$($Drive.DeviceID)\"
        break
    }
}

if (-not $MusicRoot) {
    Write-Host "No USB drive with 'Music' folder found."
    exit
}

$MusicPath = Join-Path $MusicRoot "Music"
$PlaylistFolder = Join-Path $MusicRoot "Playlists"
$MasterPlaylistFile = Join-Path $PlaylistFolder "Latest Playlist.m3u"

Write-Host "Using USB: $MusicPath"

# -------- SMART SORT --------
$allFiles = Get-ChildItem $MusicPath -Recurse -File |
    Where-Object { $_.Extension -ieq ".mp3" } |
    Sort-Object Name

$totalFiles = $allFiles.Count
$totalMoved = 0

for ($i = 0; $i -lt $totalFiles; $i++) {

    $file = $allFiles[$i]

    $folderIndex = [math]::Floor($i / $limit) + 1
    $folderName = "{0:D2}" -f $folderIndex
    $targetFolder = Join-Path $MusicPath $folderName

    if (!(Test-Path $targetFolder)) {
        New-Item -ItemType Directory -Path $targetFolder | Out-Null
        Write-Host "Created folder: $folderName"
    }

    if ($file.DirectoryName -ne $targetFolder) {
        Write-Host ("Moving: {0} -> {1}" -f $file.Name, $folderName)
        Move-Item $file.FullName $targetFolder -Force
        $totalMoved++
    }
}

Write-Host "-----------------------------------"
Write-Host "Sorting Done. Total moved: $totalMoved"

# -------- FOLDER COUNT --------
Write-Host "-----------------------------------"
Write-Host "Folder-wise count:"

$folders = Get-ChildItem $MusicPath -Directory | Sort-Object {[int]$_.Name}

foreach ($folder in $folders) {
    $count = (Get-ChildItem $folder.FullName -File |
        Where-Object { $_.Extension -ieq ".mp3" }).Count

    if ($count -eq 255) {
        Write-Host ("{0} = {1}/255 (FULL)" -f $folder.Name, $count)
    } else {
        Write-Host ("{0} = {1}/255" -f $folder.Name, $count)
    }
}

# -------- PLAYLIST --------

if (!(Test-Path $PlaylistFolder)) {
    New-Item -Path $PlaylistFolder -ItemType Directory | Out-Null
}

# Remove old playlist
if (Test-Path $MasterPlaylistFile) {
    Remove-Item $MasterPlaylistFile -Force
    Write-Host "Old playlist removed."
}

Write-Host "Building Latest Playlist..."

$MusicFiles = Get-ChildItem -Path $MusicPath -Recurse -File `
    -Include *.mp3,*.m4a,*.flac,*.wav

$Shell = New-Object -ComObject Shell.Application

$SongData = foreach ($File in $MusicFiles) {

    $Year = $null

    if ($File.Name -match '\b(19|20)\d{2}\b') {
        $Year = [int]$Matches[0]
    }

    if (-not $Year) {
        try {
            $ShellFolder = $Shell.NameSpace($File.DirectoryName)
            $ShellFile = $ShellFolder.ParseName($File.Name)

            if ($ShellFile) {
                $Year28 = $ShellFolder.GetDetailsOf($ShellFile, 28)
                if ($Year28 -match '\d{4}') {
                    $Year = [int]([regex]::Match($Year28, '\d{4}').Value)
                }
            }
        } catch {}
    }

    if (-not $Year) { $Year = 1000 }

    [PSCustomObject]@{
        FullName = $File.FullName
        FileName = $File.Name
        Year     = $Year
    }
}

$SortedSongs = $SongData |
    Sort-Object @{Expression='Year'; Descending=$true},
                @{Expression='FileName'; Descending=$false}

"#EXTM3U" | Out-File $MasterPlaylistFile -Encoding UTF8
"# Latest Playlist - Sorted by Year then A-Z" |
    Out-File $MasterPlaylistFile -Append -Encoding UTF8

foreach ($Song in $SortedSongs) {
    $Song.FullName | Out-File $MasterPlaylistFile -Append -Encoding UTF8
}

Write-Host "-----------------------------------"
Write-Host "Playlist Created: $MasterPlaylistFile"
