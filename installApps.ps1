cd  "C:\Users\dj2watso\eclipse-workspace\appTesting\apks\"
$files = Get-ChildItem
$files = $files | where {$_.extension -eq ".apk"}
Write-Host $files
Foreach ($apk in $files){
	adb install $apk
}

