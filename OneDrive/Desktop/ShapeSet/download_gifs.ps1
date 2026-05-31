$content = Get-Content -Raw gifs.html
$matches = [regex]::Matches($content, 'https?://[^\s''"]+\.gif')
$urls = $matches | ForEach-Object { $_.Value } | Select-Object -Unique

New-Item -ItemType Directory -Force -Path "assets" | Out-Null

foreach ($url in $urls) {
    $filename = $url.Split('/')[-1]
    $filepath = Join-Path "assets" $filename
    if (-not (Test-Path $filepath)) {
        Write-Host "Downloading $filename..."
        try {
            Invoke-WebRequest -Uri $url -OutFile $filepath -UseBasicParsing
        } catch {
            Write-Host "Failed to download $url : $_"
        }
    } else {
        Write-Host "Already exists: $filename"
    }
}
Write-Host "Download complete!"
