$target = $args[0] #target device (or devices)
$trace = $args[1]  #trace file to run
$runs = $args[2]   #times to run
$app = $args[3]    #app to run trace on
$outputFile = $args[4] #output file name to use (without extension)

#start with screen on - IMPORTANT
adb shell am startservice com.quicinc.trepn/.TrepnService

Start-Sleep -s 1 #pause

#load prefs
adb shell am broadcast -a com.quicinc.trepn.load_preferences -e com.quicinc.trepn.load_preferences_file “/sdcard/trepn/saved_preferences/expPrefs.pref”

Start-Sleep -s 1

adb shell am broadcast -a com.quicinc.trepn.start_profiling -e com.quicinc.trepn.database_file "trepnTemp" #start profiling

Write-Host "profile started"

adb shell input keyevent KEYCODE_POWER #turn off screen

Start-Sleep -s 1

For ($i=0; $i -lt $runs ; $i++){
starfish devices control $target shell input keyevent KEYCODE_WAKEUP #-turn on phone if not already on, no effect otherwise
Start-Sleep -s .25 #pause
starfish devices control $target shell input keyevent 82 #-------------unlock phone if at lock screen, no effect otherwise
Start-Sleep -s .25 #pause
starfish devices control $target launch_pkg $app #---------------------launch target app on target device(s)
Start-Sleep -s 1.5 #pause
adb shell input keyevent "KEYCODE_ENTER" #------------------------------press enter
Start-Sleep -s 3 #pause
starfish trace replay $trace $target #---------------------------------run prerecorded test
Start-Sleep -s 1 #pause
starfish devices control $target shell am force-stop $app #------------halt target app so it can be re-launched
Start-Sleep -s .25 #pause
starfish devices control $target shell input keyevent KEYCODE_POWER #--turn off screen to indicate end of run
Start-Sleep -s 1 #pause
Write-Host "run completed"
}

#stop profiling
adb shell am broadcast -a com.quicinc.trepn.stop_profiling

#convert the output to csv
adb shell am broadcast -a com.quicinc.trepn.export_to_csv -e com.quicinc.trepn.export_db_input_file "trepnTemp.db" -e com.quicinc.trepn.export_csv_output_file $outputFile
Write-Host "Output successful"