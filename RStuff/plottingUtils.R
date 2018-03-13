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

plotInstances=function(lst, metric = "CPU Load (Normalized) [%]", aggregator=getAggregator(TRUE), colors=NULL, Ylim=NULL){
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
		max = max(max, Cmax)
		min = min(min, Cmin)
		#print(c(max, min))
		if(is.na(min) || is.na(max)){
			print(c("current",Cmax, Cmin))
		}
	}
	
	
	#create plot with first instance
	#print(lst[[1]])
	graphics.off()
	#print(c(min, max))
	
	plotSingleInstance(lst[[1]],metric, colors[1], min, max)
	#print("first")
	timeInd = which(colnames(lst[[1]])==metric)-1
	#plot the rest of the instances minus final
	for(i in 2: n-1){
		lines(lst[[i]][,timeInd], lst[[i]][,metric], col=colors[i])
	}
	
	#plot final instance in black and bold if an aggregator is present or normally otherwise
	if(agg)
		lines(lst[[n]][,timeInd], lst[[n]][,metric], col="black", lwd=3)
	else
		lines(lst[[n]][,timeInd], lst[[n]][,metric], col=colors[n])
}
