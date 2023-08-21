do{
    $dir = Read-Host "Folder absolute path"
    $items = Get-ChildItem $dir | Sort-Object -Property @{Expression={$_.Length};Descending=$true} | Select-Object Name, Length, LengthKB, LengthMB, FullName, Extension, @{Name='Type';Expression={if($_.PSIsContainer){'Folder'}else{$_.Extension}}}

    $table = @()
    foreach ($item in $items) {
        if ($item.Type -eq "Folder") {
            $subItems = Get-ChildItem $item.FullName -Recurse | Where-Object { $_.Attributes -ne "Directory" }
            $size = ($subItems | Measure-Object -Property Length -Sum).Sum
            $sizeKB = [math]::Round($size / 1024, 2)
            $sizeMB = [math]::Round($size / 1048576, 2)
            $sizeGB = [math]::Round($size / 1073741824, 2)
            $table += [PSCustomObject]@{
                Name = $item.FullName
                Type = "Folder"
                Size = "$sizeKB KB ($sizeMB MB) ($sizeGB GB)"
                SizeNum = $size
            }
        } else {
            $size = $item.Length
            $sizeKB = [math]::Round($size / 1024, 2)
            $sizeMB = [math]::Round($size / 1048576, 2)
            $sizeGB = [math]::Round($size / 1073741824, 2)
            $table += [PSCustomObject]@{
                Name = $item.Name
                Type = $item.Extension
                Size = "$sizeKB KB ($sizeMB MB) ($sizeGB GB)"
                SizeNum = $size
            }
        }
    }

    $table | Sort-Object -Property SizeNum -Descending | Format-Table -AutoSize -Property Name, Type, Size 

    $respuesta = Read-Host "¿Do you want to see another path? (Y/N)"
}while($respuesta.ToLower() -eq 'y')