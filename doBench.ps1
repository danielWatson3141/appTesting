$target = $args[0] #target device (or devices)

starfish devices control $target shell input keyevent KEYCODE_WAKEUP #-turn on phone if not already on, no effect otherwise

starfish devices control $target shell input keyevent 82 #-------------unlock phone if at lock screen, no effect otherwise

adb shell am startservice com.quicinc.trepn/.TrepnService #------------start trepn service if not already running

Start-Sleep -s 1 #pause

#----------------------------------------------------------------------load trepn preferences
adb shell am broadcast -a com.quicinc.trepn.load_preferences -e com.quicinc.trepn.load_preferences_file "/trepn/saved_preferences/expPrefs.pref"

adb shell am broadcast -a com.quicinc.trepn.start_profiling -e com.quicinc.trepn.database_file "trepnTemp" #start profiling

Write-Host "profile started"

Start-Sleep -s 60 #----------------------------------------------------Allow Trepn to collect 60s of data


#stop profiling
adb shell am broadcast -a com.quicinc.trepn.stop_profiling

#convert the output to csv
adb shell am broadcast -a com.quicinc.trepn.export_to_csv -e com.quicinc.trepn.export_db_input_file "trepnTemp.db" -e com.quicinc.trepn.export_csv_output_file "benchMark"
Write-Host "Benchmark Complete"

