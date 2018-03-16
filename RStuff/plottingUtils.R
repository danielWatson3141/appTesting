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
	}else{
		toRem = sample(length(met2), length(met2)-length(met1), replace = FALSE)
		met2 = met2[-toRem]
	}
	
	ymin = min(c(met1, met2))
	ymax = max(c(met1, met2))
	
	indMax = max(length(met1), length(met2))
	
	print(c(length(met1), length(met2)))
	
	plot(met1, col="red", xlim = c(1, indMax), ylim = c(ymin, ymax))
	points(met2, col="blue",  xlim = c(1, indMax), ylim = c(ymin, ymax))
}

compareMeans = function(mean1, mean2, metric="CPU Load (Normalized) [%]", colors, min, max){
	plotSingleInstance(mean1, metric, colors[1], min, max)
	
	time1 = mean1[,(which(colnames(mean1)==metric)-1)]
	time2 = mean2[,(which(colnames(mean2)==metric)-1)]
	
	#normalize times so the graphs line up
	
	t1start = time1[1]
	t2start = time2[1]
	browser()
	#determine offset
	
	diff = t2start-t1start
	
	#shift by offset
	time2 = time2-diff
	
	
	
	lines(time2, mean2[,metric], col=colors[2], lwd=1)
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
	graphics.off()
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

makeDygraph = function(lst, metric = "CPU Load (Normalized) [%]", colors=NULL, Ylim=NULL){
	
	aggregator=getAggregator(TRUE)
	lst = aggregator(lst)	
	d = length(lst)
	n = nrow(lst[[1]])
	timeInd = which(colnames(lst[[1]])==metric)-1
	
	
	maxes = vector('numeric', n)
	mins = vector('numeric', n)
	
	#compute vectors of maxes and mins
	#There's an apply way to do this but
	#fuckin R isn't working with me today
	for(i in 1:n){
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
	
	#return(ext)
	plot(lst[[1]][,timeInd],maxes, ylab=metric, xlab='Time (ms)', type="l", ylim=Ylim, col="red")
	lines(lst[[1]][,timeInd],mins, col="blue")
	lines(lst[[1]][,timeInd],lst[[d]][,metric], lwd=3)
	
}

plotTrace = function(spTrace, leadTime, plotHeight=0){
	spTrace = (spTrace)*1000+leadTime*1000
	print(spTrace)
	drawLine = function(x){
		lines(x, c(plotHeight, plotHeight), lwd=10)
	}
	apply(spTrace, 1, drawLine)
}
GenerateAndSavePlots = function(csvMat){
	
	dirs = c("plots/property", "plots/maps", "plots/matrix")
	
	for(i in 1:3){
		
		#Dygraph Each
		
		
		png("")
		
		
		#Compare Means
		
		#Compare Sorts
		
	}
}
