# TODO: Add comment
# 
# Author: dj2watso
###############################################################################


plotForFile = function(csvFile, n=10, metric = "CPU Load (Normalized) [%]", traceFile=null, aggregator=getaggregator(TRUE)){
	rawData = extractCSV(csvFile)
	instances = splitInstances(rawData, n)
	plotInstances(instances[-1], metric)
}

plotSingleInstance=function(inst, metric="CPU Load (Normalized) [%]", color, min, max){
	timeInd = which(colnames(inst)==metric)-1
	plot(inst[,timeInd],inst[,metric], #data
			type="l", col=color,	#colored line
			xlab = "time (ms)",	#label x axis
			ylab = metric, #label y axis
			ylim = c(min, max),	#ensure y axis is scaled properly
			main = paste(metric, " VS ", "Time")
	)
}

KSTest = function(inst1, inst2, metric="CPU Load (Normalized) [%]"){
	#bind instances if multiple
	if(typeof(inst1)=="list"){
		inst1 = do.call(rbind, inst1, 1)
	}
	
	if(typeof(inst2)=="list"){
		inst2 = do.call(rbind, inst2, 1)
	}
	
	
	#get metric
	met1 = inst1[,metric]
	met2 = inst2[,metric]
	
	met1 = sort(met1)
	met2 = sort(met2)
	
	return(ks.test(inst1,inst2))
}

compareSorts = function(inst1, inst2, metric="CPU Load (Normalized) [%]", colors=c("red","blue")){
	#compare separate instances (or lists of instances) by sorting and graphing points
	
	
	
	#bind instances if multiple
	if(typeof(inst1)=="list"){
		inst1 = do.call(rbind, inst1, 1)
	}
	
	if(typeof(inst2)=="list"){
		inst2 = do.call(rbind, inst2, 1)
	}
	
	
	
	met1 = inst1[,metric]
	met2 = inst2[,metric]
	
	met1 = sort(met1)
	met2 = sort(met2)
	
	#remove random rows to make lengths equal

	if(length(met1)>length(met2)){
		toRem = sample(length(met1), length(met1)-length(met2), replace = FALSE)
		met1 = met1[-toRem]
	}else if(length(met1)<length(met2)){
		toRem = sample(length(met2), length(met2)-length(met1), replace = FALSE)
		met2 = met2[-toRem]
	}
	
	ymin = min(c(met1, met2))
	ymax = max(c(met1, met2))
	
	indMax = max(length(met1), length(met2))
	
	print(c(length(met1), length(met2)))
	if(debug)
		browser()
	plot(met1, col="red", xlim = c(1, indMax), ylim = c(ymin, ymax), ylab=metric,  main = paste(metric, " VS ", "Sorted Observations"))
	points(met2, col="blue",  xlim = c(1, indMax), ylim = c(ymin, ymax))
	
}

compareMeans = function(inst1, inst2, metric="CPU Load (Normalized) [%]", colors=c("red","blue"), min, max, rollmean=FALSE){
	
	mean1 = getMean(inst1)
	mean2 = getMean(inst2)
	
	name1=deparse(substitute(inst1))
	name2=deparse(substitute(inst2))
	
	#get timestamps
	time1 = mean1[,(which(colnames(mean1)==metric)-1)]
	time2 = mean2[,(which(colnames(mean2)==metric)-1)]
	
	#normalize times so the graphs line up
	
	t1start = time1[1]
	t2start = time2[1]
	#browser()
	#determine offset
	
	diff = t2start-t1start
	
	#shift by offset
	time2 = time2-diff
	
	#plot
	#png(paste("plots/",name1,"VS",name2,".png",sep=""),5000,1000)
	#plot.new()
	plot(time1, mean1[,metric] ,type="l", col= colors[1], lwd=1, ylim=c(0,100))
	lines(time2, mean2[,metric], col=colors[2], lwd=1)
	
	#plot legend
	legend(0,max,c(name1,name2),c("red","blue"))
	#dev.off()
}

plotInstances=function(lst, metric = "CPU Load (Normalized) [%]", aggregator=getAggregator(TRUE), colors=NULL, Ylim=NULL, wait=FALSE){
	#lst: list of instances
	#metric: metric to be plotted (label)
	#aggregator: function that takes such a list and aggregates info DEFAULT: none
	#list of colors to plot with REQ: length(colors) >= length(aggregator(lst)).
	#If an aggregator is present, the last instance is assumed to be the aggregated sample, and therefore will be bolded
	
	#metricName = colnames(lst[[1]])[metric]
	
	agg = !is.null(aggregator)
	n=length(lst)
	if(agg){
		#print("bip")
		lst = aggregator(lst)
		n=length(lst)
	}
	#print("pib")
	if(is.null(colors))
		colors = rainbow(n)
	
	#find max and min of all datapoints
	max = -Inf
	min = Inf
	
	for(i in 1:length(lst)){
		instance = lst[[i]]
		#print(dimnames(instance))
		Cmax = max(instance[,metric])
		Cmin = min(instance[,metric])
		#print(c(max, min))
		if(is.na(Cmin) || is.na(Cmax)){
			print(c("current",Cmax, Cmin))
		}else{
		
			max = max(max, Cmax)
			min = min(min, Cmin)
		}
	}
	
	
	#create plot with first instance
	#print(lst[[1]])
	#graphics.off()
	#print(c(min, max))
	
	plotSingleInstance(lst[[1]],metric, colors[1], min, max)
	if(wait)
		readline(prompt="Press [enter] to continue")
	#print("first")
	timeInd = which(colnames(lst[[1]])==metric)-1
	#plot the rest of the instances minus final
	for(i in 2: n-1){
		lines(lst[[i]][,timeInd], lst[[i]][,metric], col=colors[i])
		if(wait)
			readline(prompt="Press [enter] to continue")
	}
	
	#plot final instance in black and bold if an aggregator is present or normally otherwise
	if(agg)
		lines(lst[[n]][,timeInd], lst[[n]][,metric], col="black", lwd=3)
	else
		lines(lst[[n]][,timeInd], lst[[n]][,metric], col=colors[n])
}

makeDygraph = function(lstUnsmooth, smooth=FALSE, metric = "CPU Load (Normalized) [%]", colors=NULL, Ylim=NULL){
	
	
	aggregator=getAggregator(smooth)
	lst = aggregator(lstUnsmooth)	
	d = length(lst)
	n = nrow(lst[[1]])
	timeInd = which(colnames(lst[[1]])==metric)-1
	
	
	maxes = vector('numeric', n)
	mins = vector('numeric', n)
	
	#compute vectors of maxes and mins
	#There's an apply way to do this but
	#fuckin R isn't working with me today
	
	for(i in 1:n){
		
		
		sumDif = 0
		
		Cmax = -Inf
		Cmin = Inf
		for(inst in lst[-d]){
			val = inst[i,metric]
			if(!is.na(val)){
				Cmax=max(Cmax,val)
				Cmin=min(Cmin,val)
			}	
		}
		maxes[i] = Cmax
		mins[i] = Cmin
	}
	
	var = sampleVariance(lstUnsmooth,smooth,metric)
	if(is.null(Ylim))
		Ylim = c(min(mins),max(maxes))
	print(Ylim)
	#return(ext)
	
	plot(lst[[1]][,timeInd],maxes, ylab=metric, xlab='Time (ms)', type="l", ylim=Ylim, col="red", main = paste(metric, " VS ", "Time"))
	#browser()
	#lines(lst[[1]][,timeInd],var, col="green")
	#browser()
	lines(lst[[1]][,timeInd],mins, col="blue")
	lines(lst[[1]][,timeInd],lst[[d]][,metric], lwd=3)
}



plotTrace = function(spTrace, leadTime, plotHeight=0){
	if(is.null(spTrace))
		return()
	spTrace = (spTrace)*1000+leadTime*1000
	#print(spTrace)
	drawLine = function(x){
		lines(x, c(plotHeight, plotHeight), lwd=10)
	}
	apply(spTrace, 1, drawLine)
}

#Phone 1 = moto
#Phone 2 = Google
#Phone 3 = Samsung


generateAndSavePlots = function(){
	for(pn in 1:3){
		means = lapply(allData[[pn]][1:9],getMean,FALSE)
	
		for(metric in c("Memory Usage [KB]","CPU Load (Normalized) [%]")){
			#property
			print(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),".png",sep=""))
			png(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),".png",sep=""),10000,1000)	
			#metric = "Memory Usage [KB]"
			#plot(means[[1]])
			#get timestamps
			ANtime = means[[1]][,(which(colnames(means[[1]])==metric)-1)]
			RNtime = means[[4]][,(which(colnames(means[[4]])==metric)-1)]
			IOtime = means[[7]][,(which(colnames(means[[7]])==metric)-1)]
			
			ANapp = means[[1]][,metric]
			RNapp = means[[4]][,metric]
			IOapp = means[[7]][,metric]
			
			if(debug){
				print(metric)
				print(colnames(means[[1]]))
				browser()
			}
			#get maximums
			max = max(c(
					max(ANapp),
					max(RNapp),
					max(IOapp)
					)
			)
			
			#get mins
			min = min(c(
					min(ANapp),
					min(RNapp),
					min(IOapp)
					)
			)
			
			if(debug)
				browser()
			plot(ANtime, ANapp ,type="l", col="Green", lwd=2, ylim=c(min, max), xlab = "Time (ms)",ylab=metric, )
			lines(RNtime, RNapp, col="Blue", lwd=2, ylim=c(min, max))
			lines(IOtime, IOapp, col="Red", lwd=2, ylim=c(min, max))
			#plot legend
			legend(0,max,c("Android","ReactNative","Ionic"),c("green","blue","red"))
			dev.off()
			
			ANapp = allData[[pn]][[1]]
			RNapp = allData[[pn]][[4]]
			IOapp = allData[[pn]][[7]]
			
			sigCompare(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),"_ANvsRN_SigComp.png",sep=""),ANapp, RNapp, metric, c("green","blue"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),"_ANvsIO_SigComp.png",sep=""),ANapp, IOapp, metric, c("green","Red"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),"_RNvsIO_SigComp.png",sep=""),RNapp, IOapp, metric, c("blue","red"), FALSE, TRUE)
			
			
			
			#-------------------------------
			
			#maps
			print(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),".png",sep=""))
			png(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),".png",sep=""),10000,1000)	
			#metric = "Memory Usage [KB]"
			#plot(means[[1]])
			#get timestamps
			ANtime = means[[2]][,(which(colnames(means[[2]])==metric)-1)]
			RNtime = means[[5]][,(which(colnames(means[[5]])==metric)-1)]
			IOtime = means[[8]][,(which(colnames(means[[8]])==metric)-1)]
			
			ANapp = means[[2]][,metric]
			RNapp = means[[5]][,metric]
			IOapp = means[[8]][,metric]
			#get maximums
			max = max(c(
							max(ANapp),
							max(RNapp),
							max(IOapp))
			)
			
			#get mins
			min = min(c(
							min(ANapp),
							min(RNapp),
							min(IOapp))	
			)
			
			if(debug)
				browser()
			plot(ANtime, ANapp ,type="l", col="Green", lwd=2, ylim=c(min, max), xlab = "Time (ms)",ylab=metric, )
			lines(RNtime, RNapp, col="Blue", lwd=2, ylim=c(min, max))
			lines(IOtime, IOapp, col="Red", lwd=2, ylim=c(min, max))
			#plot legend
			legend(0,max,c("Android","ReactNative","Ionic"),c("green","blue","red"))
			dev.off()
			
			ANapp = allData[[pn]][[2]]
			RNapp = allData[[pn]][[5]]
			IOapp = allData[[pn]][[8]]
			
			sigCompare(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),"_ANvsRN_SigComp.png",sep=""),ANapp, RNapp, metric, c("green","blue"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),"_ANvsIO_SigComp.png",sep=""),ANapp, IOapp, metric, c("green","Red"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),"_RNvsIO_SigComp.png",sep=""),RNapp, IOapp, metric, c("blue","red"), FALSE, TRUE)
			
					
			#-------------------------------
			#matrix
			print(paste("plots/",phoneNames[pn],"_Matr_",substr(metric,1,3),".png",sep=""))
			png(paste("plots/",phoneNames[pn],"_Matr_",substr(metric,1,3),".png",sep=""),10000,1000)	
			#metric = "Memory Usage [KB]"
			#plot(means[[1]])
			#get timestamps
			ANtime = means[[3]][,(which(colnames(means[[3]])==metric)-1)]
			RNtime = means[[6]][,(which(colnames(means[[6]])==metric)-1)]
			IOtime = means[[9]][,(which(colnames(means[[9]])==metric)-1)]
			ANapp = means[[3]][,metric]
			RNapp = means[[6]][,metric]
			IOapp = means[[9]][,metric]
			#get maximums
			max = max(c(
							max(ANapp),
							max(RNapp), 
							max(IOapp))
			)
			
			#get mins
			min = min(c(
							min(ANapp),
							min(RNapp),
							min(IOapp))	
			)
			
			if(debug)
				browser()
			plot(ANtime, ANapp ,type="l", col="Green", lwd=2, ylim=c(min, max), xlab = "Time (ms)",ylab=metric, )
			lines(RNtime, RNapp, col="Blue", lwd=2, ylim=c(min, max))
			lines(IOtime, IOapp, col="Red", lwd=2, ylim=c(min, max))
			
			#plot legend
			legend(0,max,c("Android","ReactNative","Ionic"),c("green","blue","red"))
			dev.off()
			
			ANapp = allData[[pn]][[3]]
			RNapp = allData[[pn]][[6]]
			IOapp = allData[[pn]][[9]]
			
			sigCompare(paste("plots/",phoneNames[pn],"_Matrix_",substr(metric,1,3),"_ANvsRN_SigComp.png",sep=""),ANapp, RNapp, metric, c("green","blue"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Matrix_",substr(metric,1,3),"_ANvsIO_SigComp.png",sep=""),ANapp, IOapp, metric, c("green","Red"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Matrix_",substr(metric,1,3),"_RNvsIO_SigComp.png",sep=""),RNapp, IOapp, metric, c("blue","red"), FALSE, TRUE)
			
		}
		
		#same as above but with moving average applied
		means = lapply(allData[[pn]][1:9],getMean,TRUE)
		for(metric in c("Memory Usage [KB]","CPU Load (Normalized) [%]")){
			#property
			print(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),".png",sep=""))
			png(paste("plots/",phoneNames[pn],"_Property_MA_",substr(metric,1,3),".png",sep=""),10000,1000)	
			#metric = "Memory Usage [KB]"
			#plot(means[[1]])
			#get timestamps
			ANtime = means[[1]][,(which(colnames(means[[1]])==metric)-1)]
			RNtime = means[[4]][,(which(colnames(means[[4]])==metric)-1)]
			IOtime = means[[7]][,(which(colnames(means[[7]])==metric)-1)]
			if(debug){
				print(metric)
				print(colnames(means[[1]]))
				browser()
			}
			#get maximums
			max = max(c(
							max(means[[1]][,metric]),
							max(means[[4]][,metric]),
							max(means[[7]][,metric]))
			)
			
			#get mins
			min = min(c(
							min(means[[1]][,metric]),
							min(means[[4]][,metric]),
							min(means[[7]][,metric]))	
			)
			
			if(debug)
				browser()
			plot(ANtime, means[[1]][,metric] ,type="l", col="Green", lwd=2, ylim=c(min, max), xlab = "Time (ms)",ylab=metric, )
			lines(RNtime, means[[4]][,metric], col="Blue", lwd=2, ylim=c(min, max))
			lines(IOtime, means[[7]][,metric], col="Red", lwd=2, ylim=c(min, max))
			
			#plot legend
			legend(0,max,c("Android","ReactNative","Ionic"),c("green","blue","red"))
			dev.off()
			
			ANapp = allData[[pn]][[1]]
			RNapp = allData[[pn]][[4]]
			IOapp = allData[[pn]][[7]]
			
			sigCompare(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),"_ANvsRN_SigComp_Smooth.png",sep=""),ANapp, RNapp, metric, c("green","blue"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),"_ANvsIO_SigComp_Smooth.png",sep=""),ANapp, IOapp, metric, c("green","Red"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Property_",substr(metric,1,3),"_RNvsIO_SigComp_Smooth.png",sep=""),RNapp, IOapp, metric, c("blue","red"), FALSE, TRUE)
			
			
			#-------------------------------
			
			#maps
			print(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),".png",sep=""))
			png(paste("plots/",phoneNames[pn],"_Maps_MA",substr(metric,1,3),".png",sep=""),10000,1000)	
			#metric = "Memory Usage [KB]"
			#plot(means[[1]])
			#get timestamps
			ANtime = means[[2]][,(which(colnames(means[[2]])==metric)-1)]
			RNtime = means[[5]][,(which(colnames(means[[5]])==metric)-1)]
			IOtime = means[[8]][,(which(colnames(means[[8]])==metric)-1)]
			
			#get maximums
			max = max(c(
							max(means[[2]][,metric]),
							max(means[[5]][,metric]),
							max(means[[8]][,metric]))
			)
			
			#get mins
			min = min(c(
							min(means[[2]][,metric]),
							min(means[[5]][,metric]),
							min(means[[8]][,metric]))	
			)
			
			if(debug)
				browser()
			plot(ANtime, means[[2]][,metric] ,type="l", col="Green", lwd=2, ylim=c(min, max), xlab = "Time (ms)",ylab=metric, )
			lines(RNtime, means[[5]][,metric], col="Blue", lwd=2, ylim=c(min, max))
			lines(IOtime, means[[8]][,metric], col="Red", lwd=2, ylim=c(min, max))
			
			#plot legend
			legend(0,max,c("Android","ReactNative","Ionic"),c("green","blue","red"))
			dev.off()
			
			ANapp = allData[[pn]][[2]]
			RNapp = allData[[pn]][[5]]
			IOapp = allData[[pn]][[8]]
			
			sigCompare(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),"_ANvsRN_SigComp_Smooth.png",sep=""),ANapp, RNapp, metric, c("green","blue"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),"_ANvsIO_SigComp_Smooth.png",sep=""),ANapp, IOapp, metric, c("green","Red"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Maps_",substr(metric,1,3),"_RNvsIO_SigComp_Smooth.png",sep=""),RNapp, IOapp, metric, c("blue","red"), FALSE, TRUE)
			
			
			#-------------------------------
			#matrix
			png(paste("plots/",phoneNames[pn],"_Matr_MA",substr(metric,1,3),".png",sep=""),10000,1000)	
			#metric = "Memory Usage [KB]"
			#plot(means[[1]])
			#get timestamps
			ANtime = means[[3]][,(which(colnames(means[[3]])==metric)-1)]
			RNtime = means[[6]][,(which(colnames(means[[6]])==metric)-1)]
			IOtime = means[[9]][,(which(colnames(means[[9]])==metric)-1)]
			
			#get maximums
			max = max(c(
							max(means[[3]][,metric]),
							max(means[[6]][,metric]), 
							max(means[[9]][,metric]))
			)
			
			#get mins
			min = min(c(
							min(means[[3]][,metric]),
							min(means[[6]][,metric]),
							min(means[[9]][,metric]))	
			)
			
			if(debug)
				browser()
			plot(ANtime, means[[3]][,metric] ,type="l", col="Green", lwd=2, ylim=c(min, max), xlab = "Time (ms)",ylab=metric, )
			lines(RNtime, means[[6]][,metric], col="Blue", lwd=2, ylim=c(min, max))
			lines(IOtime, means[[9]][,metric], col="Red", lwd=2, ylim=c(min, max))
			
			#plot legend
			legend(0,max,c("Android","ReactNative","Ionic"),c("green","blue","red"))
			dev.off()
			
			ANapp = allData[[pn]][[3]]
			RNapp = allData[[pn]][[6]]
			IOapp = allData[[pn]][[9]]
			
			sigCompare(paste("plots/",phoneNames[pn],"_Matrix_",substr(metric,1,3),"_ANvsRN_SigComp_Smooth.png",sep=""),ANapp, RNapp, metric, c("green","blue"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Matrix_",substr(metric,1,3),"_ANvsIO_SigComp_Smooth.png",sep=""),ANapp, IOapp, metric, c("green","Red"), FALSE, TRUE)
			sigCompare(paste("plots/",phoneNames[pn],"_Matrix_",substr(metric,1,3),"_RNvsIO_SigComp_Smooth.png",sep=""),RNapp, IOapp, metric, c("blue","red"), FALSE, TRUE)
			
		}
	}
	
	print("plotting finished")
	
	closeAllConnections()#just in case
}

sigCompute=function(app1, app2, metric = "CPU Load (Normalized) [%]",smooth=TRUE){
	mean1 = getMean(app1, smooth)
	mean2 = getMean(app2, smooth)
	
	#app1Metric = lapply(app1, function(x){return(x[,metric])})
	var1 = sampleVariance(app1, smooth, metric)
	var2 = sampleVariance(app2, smooth, metric)
	varAv = (var1+var2)/2
	
	meanDiff = mean1[,metric]-mean2[,metric]
	mse = lapply(varAv, function(x){sqrt((2*x)/length(app1))})
	#browser()
	tstat = meanDiff/as.double(mse)
	#browser()
	dof = 2*length(app1)-2
	#browser()
	time = app1[[1]][1:min(length(tstat),nrow(app1[[1]])),(which(colnames(app1[[1]])==metric))-1]
	#plot(time, tstat, type="l")
	significant= qt(c(.1, .90), df=dof)
	#abline(h=significant, col="blue")
	return(list(tstat, significant ,mean1,mean2,time))
}

sigCompare=function(name, app1, app2, 
					metric = "CPU Load (Normalized) [%]", 
					col=c("red","blue"), smooth=TRUE, Drawpng=FALSE){
	sigRes = sigCompute(app1, app2, metric, smooth)
	
	
	tstat=sigRes[[1]]
	sig = sigRes[[2]]
	mean1 = sigRes[[3]][,metric]
	mean2 = sigRes[[4]][,metric]
	time = sigRes[[5]]

	min = min(min(mean1),min(mean2))
	max = max(max(mean1),max(mean2))
	
	if(Drawpng){
		png = png(name,10000,1000)
		print(name)
	}
	plot(time, time ,type="l", col="white", lwd=0, ylim=c(min, max), xlim=c(0,max(time)), xlab = "Time (ms)",ylab=metric)
	
	#proportional
	#lwd = abs(tstat*3) 
	
	#quadratic
	#lwd = abs(tstat^2)
	
	#binary
	lwd = double(length(time))
	sigIndeces = which(abs(tstat)>(sig[2]))
	lwd[sigIndeces] = 5
	lwd[-sigIndeces] = 1	
	
	
	plotWidthChart(time, mean1, mean2, lwd, col)
	if(Drawpng)
		dev.off()
	#browser()
	#par(new=TRUE)
	#trimmed = trimToSmaller(time, tstat)
	#time=trimmed[1]
	#tstat=trimmed[2]
	
	#lines(time, tstat, ylim = c(-30, +30))
	
	#dev.off()
	#closeAllConnections()
}

plotWidthChart=function(x, y1, y2, thickness, col){
	for(i in 1:(min(length(y1),length(y2))-1))
	{
		thicc = (thickness[i]+thickness[i+1])/2
		segments(x[i], y1[i], x[i+1], y1[i+1],col=col[1],lwd=thicc)
		segments(x[i], y2[i], x[i+1], y2[i+1],col=col[2],lwd=thicc)
	}
}



plotMeans=function(means){
	
	#get timestamps
	time1 = mean1[,(which(colnames(mean1)==metric)-1)]
	time2 = mean2[,(which(colnames(mean2)==metric)-1)]
	
	#normalize times so the graphs line up
	
	t1start = time1[1]
	t2start = time2[1]
	#browser()
	#determine offset
	
	diff = t2start-t1start
	
	#shift by offset
	time2 = time2-diff
}






