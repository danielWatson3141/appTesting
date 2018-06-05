cd  "C:\Users\dj2watso\eclipse-workspace\appTesting\apks\"
$files = Get-ChildItem
$files = $files | where {$_.extension -eq ".apk"}
Write-Host $files
Write-Host "installing"
Foreach ($apk in $files){
   # adb uninstall $apk---didn't work
	adb install $apk -r
}

