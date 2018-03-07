# TODO: Add comment
# 
# Author: dj2watso
###############################################################################


ma <- function(arr, n=15){	#convert vector to moving average
	res = arr
	#print(typeof(arr))
	for(i in n:length(arr)){
		res[i] = mean(as.numeric(arr[(i-n):i]))
	}
	res
}

maCols = function(x, n=15){	#convert vector or matrix to moving average form
	res = mat.or.vec(nrow(x),ncol(x))
	for(i in 1:ncol(x)){
		res[,i] = ma(unlist(x[,i]), n)
	}
	return(res)
}

splitInstances = function(x, n ){ 
	#given a profile consisting of multiple runs (x) separated by screen shut-off, number of runs(n)
	#list of mat consisting of each instance with junk at beginning, end, and between runs culled
	#x must have column labeled "Screen State"
	
	l = vector("list", n)
	scrnst = x[,'Screen State']	
	i=1
	#The first screen shut off indicates the beginning of the experiment
	while(scrnst[i]==1){i=i+1}
	
	minLen = Inf
	#extract exactly n instances
	for(inst in 1:n){
		#skip to screen turning back on
		while(scrnst[i]==0){i=i+1}
		start = i
		
		#skip to screen turning back off as this indicates the end of the experiment
		while(scrnst[i]==1){i=i+1}
		end = i
		
		#extract instance
		instance =  x[start:end,]
		
		#normalize timestamps. First record is 0.
		starttime = as.numeric(instance[1,1])
		print(starttime)
		for(col in seq(1,ncol(x),2)){
			instance[,col]=as.numeric(instance[,col])-starttime
		}
		
		#keep track of minimal length for normalizing
		if(end-start<minLen)
			minLen = end-start
		
		l[[inst]] = instance
	}
	
	for(inst in 1:n){
		if(length(l[[inst]])>minLen){
			l[[inst]] = l[[inst]][1:minLen,]
		}
	}
	
	return(l)
}

plotInstances=function(lst, metric = 6, aggregator=NULL, colors=NULL, Ylim=NULL){
	#lst: list of instances
	#metric: metric to be plotted (column index)
	#aggregator: function that takes such a list and aggregates info DEFAULT: none
	#list of colors to plot with REQ: length(colors) >= length(aggregator(lst)).
	#If an aggregator is present, the last instance is assumed to be the aggregated sample, and therefore will be bolded
	
	metricName = colnames(lst[[1]])[metric]
	
	agg = !is.null(aggregator)
	n=length(lst)
	if(agg){
		print("bip")
		lst = aggregator(lst)
		n=length(lst)
	}
	print("pib")
	if(is.null(colors))
		colors = rainbow(n)
	
	#find max and min of all datapoints
	max = -Inf
	min = Inf
	
	for(i in 1:length(lst)){
		instance = lst[[i]]
		Cmax = max(instance[,metric])
		Cmin = min(instance[,metric])
		max = max(max, Cmax)
		min = min(min, Cmin)
	}
	
	
	#create plot with first instance
	#print(lst[[1]])
	graphics.off()
	
	plot(lst[[1]][,metric-1], lst[[1]][,metric], #data
			type="l", col=colors[1],	#colored line
			xlab = "time (ms)",	#label x axis
			ylab = metricName, #label y axis
			ylim = c(min, max), 	#ensure y axis is scaled properly
			main = paste(metricName, " VS ", "Time")
			)
	print("first")
	
	#plot the rest of the instances minus final
	for(i in 2: n-1){
		lines(lst[[i]][,metric-1], lst[[i]][,metric], col=colors[i])
	}
	
	#plot final instance in black and bold if an aggregator is present or normally otherwise
	if(agg)
		lines(lst[[n]][,metric-1], lst[[n]][,metric], col="black", lwd=3)
	else
		lines(lst[[n]][,metric-1], lst[[n]][,metric], col=colors[n])
}

getAggregator = function(rollMean = FALSE, rollMeanBefore=TRUE, n = 10){
	
	
	toRet = function(lst){
		#print("bop")
		if(rollMeanBefore && rollMean){
			for(i in 1:length(lst)){
				#print(c("rollin",i))
				lst[[i]] = maCols(lst[[i]], n)
			}
		}
		
		#print("beep")
		sum = add(lst)
		#print("boop")
		mean = sum/length(lst)
		lst = c(lst,list(mean))
		if(!rollMeanBefore && rollMean){
			for(i in 1:length(lst)){
				lst[[i]] = maCols(lst[[i]], n)
			}
		}
		return(lst)
	}
	return(toRet)
}

