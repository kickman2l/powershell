param(
    # Revision to compare
    [String] $IdRevisionTo,
    # Revision to compare with
    [String] $IdRevisionWith,
    # Path to repo directory
    [String] $dirPath = "D:\work\rails",
    # Additional URL part
    [String] $URL = "http://additional-part.com/",
    # Url for post request to server
    [string] $postURL = "http://pstest/",
    # Post counter to divide array
    [Int] $postSize = 100
)

# Get list of changed files
# Git warning if changed files more than 1478
# Git variable diff.renameLimit by default 1478
$modifiedFiles = git -C $dirPath diff "$IdRevisionTo" "$IdRevisionWith" --no-commit-id --name-only

# Creating new result array
$subArrCount = [System.Math]::Ceiling($modifiedFiles.Length/$postSize)
$arrayToSend = New-Object "object[][]"  $subArrCount,$postSize

# Data processing
# Retriving object with predefined parts to send
$subArrCounter = 0
$subArrIndex = 0
foreach ($item in $modifiedFiles)
{
    $val = "$URL$item"
    if (($modifiedFiles.IndexOf($item) -ne 0) -and ($modifiedFiles.IndexOf($item)%$postSize -eq 0))
    {
        $subArrCounter++
        $subArrIndex = 0
    }
    $arrayToSend[$subArrCounter][$subArrIndex] = $val
    $subArrIndex++
}

# Sending data throw post request
for($i=0; $i -lt $arrayToSend.Count; $i++)
{
    $dataToJson = @()
    foreach ($item in $arrayToSend[$i])
    {
        if ($item -ne $null)
        {
            $dataToJson += $item.ToString()
        }
    }
    $postParams = @{"urls" = $dataToJson} | ConvertTo-Json
    $responce = Invoke-WebRequest -Uri $postURL -Method POST -ContentType "application/json" -Body $postParams
    if ($responce.StatusCode -ne 200)
    {
        Write-Host "Something goes wrong with request code: "$responce.StatusCode
    }
}