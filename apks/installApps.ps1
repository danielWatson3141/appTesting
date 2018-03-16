$files = Get-ChildItem "C:\Users\dj2watso\eclipse-workspace\appTesting\apks"
Write-Host $files
$files = $files | where {$_.extension -eq ".apk"}

Foreach ($apk in $files){
	adb install $apk
	Write-Host $apk
}

