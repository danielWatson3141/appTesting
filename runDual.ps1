$target = $args[0] #target device (or devices)
$trace = $args[1]  #trace files to run
$andr = $args[2]    #Android apps to run
$rn = $args[3]      #rn apps to run
$runs = $args[4]   #times to run total
$bufferRuns = $args[5] #times to run before profiling

Write-Host $target
Write-Host $trace
Write-Host $andr
Write-Host $rn
Write-Host $runs


For ($i=0; $i -lt $trace.Count ; $i++){
    $name = $trace[$i] -replace "\.trace",""

    Write-Host $name
    
    $andOutFile = -join ("outputs/", $name, "Andr")

    $rnOutFile = -join ("outputs/", $name , "RN")

    Write-Host $andOutFile
    Write-Host $rnOutFile

    .\runtests.ps1 $target $trace[$i] $runs $bufferRuns $andr[$i] $andOutFile
    .\runtests.ps1 $target $trace[$i] $runs $bufferRuns $rn[$i] $rnOutFile
}