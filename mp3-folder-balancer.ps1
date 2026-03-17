param(
    [string]$root="."
)

$limit=255

$folders=Get-ChildItem $root -Directory | Sort-Object {[int]$_.Name}

if(($folders | Where-Object {$_.Name -notmatch '^\d+$'}).Count -gt 0){
    Write-Host "Invalid folder structure. Aborting."
    exit
}

$changed=$true

while($changed){
    $changed=$false
    $folders=Get-ChildItem $root -Directory | Sort-Object {[int]$_.Name}

    for($i=0;$i -lt $folders.Count;$i++){

        $f=$folders[$i].FullName

        $files=Get-ChildItem $f -File |
        Where-Object {$_.Extension -match '^\.(mp3)$'} |
        Sort-Object Name

        if($files.Count -gt $limit){

            $overflow=$files[$limit..($files.Count-1)]

            foreach($file in $overflow){

                $next=[int]$folders[$i].Name+1
                $nextPath=Join-Path $root $next

                if(!(Test-Path $nextPath)){
                    New-Item -ItemType Directory -Path $nextPath | Out-Null
                }

                Move-Item $file.FullName $nextPath
                $changed=$true
            }
        }
    }
}
