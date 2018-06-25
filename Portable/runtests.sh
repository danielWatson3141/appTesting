#!/bin/bash

target = $args[0] #target device (or devices)
trace = $args[1]  #trace file to run
runs = $args[2]   #times to run
bufferRuns = $args[3] #times to run before profiling
app = $args[4]    #app to run trace on
outputFile = $args[5] #output file name to use (without extension)
prefsFile = $args[6] #prefs to use
trepnPath = $args[7] #Trepn directory on Android device 
defaultPath = "sdcard/trepn"

#Use default path if none provided.

if !$trepnPath
	then
	trepnPath = -join($defaultPath,"/",$outputFile,".csv") 
	else 
	trepnPath = -join($trepnPath,"/",$outputFile,".csv")

Write-Host "output file:"
Write-Host  $outputFile

#start with screen on - IMPORTANT
starfish devices control $target shell am startservice com.quicinc.trepn/.TrepnService

Start-Sleep -s 1 #pause

#load prefs
starfish devices control $target shell am broadcast -a com.quicinc.trepn.load_preferences -e com.quicinc.trepn.load_preferences_file -join($trepnPath ,"/saved_preferences/", $prefsFile)
Start-Sleep -s 1

starfish devices control $target shell input keyevent KEYCODE_POWER #turn off screen

Start-Sleep -s 1

for i in {1...$runs}
do
	if $i -eq $bufferRuns
	then
		starfish devices control $target shell am broadcast -a com.quicinc.trepn.start_profiling -e com.quicinc.trepn.database_file "trepnTemp" #start profiling
		Write-Host "profile started"
	fi

	Write-Host "waking up"
	starfish devices control $target shell input keyevent KEYCODE_WAKEUP #-turn on phone if not already on, no effect otherwise
	Start-Sleep -s .25 #pause
	starfish devices control $target shell input keyevent 82 #-------------unlock phone if at lock screen, no effect otherwise
	Start-Sleep -s 10 #pause

	starfish devices control $target launch_pkg $app #---------------------launch target app on target device(s)
	Start-Sleep -s 10 #pause
	Write-Host "playing:"
	Write-Host $trace
	ErrorActionPreference = "silentlyContinue"
	starfish trace replay $trace $target #---------------------------------run prerecorded test
	Start-Sleep -s 5 #pause
	starfish devices control $target shell am force-stop $app #------------halt target app so it can be re-launched
	Start-Sleep -s 5 #pause
	starfish devices control $target shell input keyevent KEYCODE_POWER #--turn off screen to indicate end of run
	Start-Sleep -s 5 #pause
	Write-Host "run completed"
done

#stop profiling
starfish devices control $target shell am broadcast -a com.quicinc.trepn.stop_profiling

#convert the output to csv
starfish devices control $target shell am broadcast -a com.quicinc.trepn.export_to_csv -e com.quicinc.trepn.export_db_input_file "trepnTemp.db" -e com.quicinc.trepn.export_csv_output_file $outputFile
Write-Host "Output successful"

#pull output to master machine
starfish devices control $target pull $trepnPath