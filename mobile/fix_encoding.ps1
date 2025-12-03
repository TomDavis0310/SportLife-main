# Script để sửa encoding của tất cả các file Dart
$files = Get-ChildItem -Path ".\lib" -Filter "*.dart" -Recurse

foreach ($file in $files) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        if ($content -match '�') {
            Write-Host "Fixing: $($file.FullName)" -ForegroundColor Yellow
            # Re-save as UTF-8 without BOM
            [System.IO.File]::WriteAllText($file.FullName, $content, (New-Object System.Text.UTF8Encoding($false)))
        }
    } catch {
        Write-Host "Error processing: $($file.FullName)" -ForegroundColor Red
    }
}

Write-Host "`nDone! Please manually fix remaining encoding issues." -ForegroundColor Green
