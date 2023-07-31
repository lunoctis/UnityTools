# because of 'tar.exe', requires Win 10 or above os
# example: Unpack-UnityPackage.ps1 C:\test.unitypackage

if ($args.Count -eq 0)
{
    Write-Error -Message "Please input *.unitypackage file path"
    Exit
}

$inputFile = $args[0]
if ($inputFile.EndsWith(".unitypackage") -eq $false)
{
    Write-Error -Message "Please input *.unitypackage file path"
    Exit
}

if ((Test-Path $inputFile -PathType Leaf) -eq $false)
{
    Write-Error -Message "Please input *.unitypackage file path"
    Exit
}

$tempFolder = $inputFile.Replace(".unitypackage", "_" + (Get-Date -Format "yyyyMMddHHmmss"))
$assetFolder = $inputFile.Replace(".unitypackage", "_Assets")
if ((Test-Path $assetFolder) -eq $true)
{
    Remove-Item -Path $assetFolder -Recurse -Force | Out-Null
}
New-Item -Path $tempFolder -ItemType Directory | Out-Null
New-Item -Path $assetFolder -ItemType Directory | Out-Null
tar -xzvf $inputFile -C $tempFolder

Get-ChildItem $tempFolder | ForEach-Object {
    $_itemFolder = $_.FullName
    $_itemMetaFile = "$_itemFolder\asset.meta"
    $_itemPathFile = "$_itemFolder\pathname"
    $_itemAssetFile = "$_itemFolder\asset"

    $_itemPath = $tempFolder + "\" + (Get-Content $_itemPathFile).Replace("/", "\")
    if ((Test-Path $_itemAssetFile) -eq $true)
    {
        # asset file
        $_dstPath = $_itemPath.Replace($tempFolder, $assetFolder)
        $_dstMetaPath = "$_dstPath.meta"
        $_parent = Split-Path -Path $_dstPath -Parent

        if ((Test-Path $_parent) -eq $false)
        {
            New-Item -Path $_parent -ItemType Directory | Out-Null
        }
        Copy-Item -Path $_itemAssetFile -Destination $_dstPath
        if （Test-Path $_itemMetaFile)
        {
            Copy-Item -Path $_itemMetaFile -Destination $_dstMetaPath
        }
    }
    else
    {
        # folder
        $_dstPath = $_itemPath.Replace($tempFolder, $assetFolder)
        $_dstMetaPath = "$_dstPath.meta"

        if ((Test-Path $_dstPath) -eq $false)
        {
            New-Item -Path $_dstPath -ItemType Directory | Out-Null
        }
        Copy-Item -Path $_itemMetaFile -Destination $_dstMetaPath
    }
}

Remove-Item -Path $tempFolder -Recurse -Force | Out-Null
