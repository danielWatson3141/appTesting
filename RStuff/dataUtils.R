# TODO: Add comment
# 
# Author: dj2watso
###############################################################################


ma <- function(arr, n=15){	#convert vector to moving average
	res = arr
	#print(typeof(arr))
	for(i in n:length(arr)){
		#browser()
		res[i] = mean(as.numeric(arr[(i-n):i]))
	}
	res
}

maCols = function(x, n=15){	#convert vector or matrix to moving average form
	#browser("",debug)
	res = mat.or.vec(nrow(x),ncol(x))
	for(i in seq(2,ncol(x),2)){
		res[,i] = ma(unlist(x[,i]), n)
	}
	for(i in seq(1,ncol(x),2)){
		res[,i] = x[,i]
	}
	res = res[n:nrow(res),]
	colnames(res) = colnames(x)
	return(res)
}

sampleVariance=function(lst,smooth, metric = "CPU Load (Normalized) [%]"){
	aggregator=getAggregator(smooth, TRUE, n=10)
	if(debug)
		browser()
	lst = aggregator(lst)	
	d = length(lst)
	n = nrow(lst[[1]])
	timeInd = which(colnames(lst[[1]])==metric)-1
	#if(smooth)
		#lst = lapply(lst, maCols, 10)
	#browser
	
	#compute vectors of variance
	res = vector("numeric",n)
	
	for(i in 1:n){
		sumDif = 0
		pointMean = lst[[d]][i,metric]
		for(inst in lst[-d]){
			val = inst[i,metric]
			if(!is.na(val)){
				sumDif=sumDif+(val-pointMean)^2
			}	
		}
		#browser()
		res[i] = sumDif/(d-1)
	}
	
	return(res)
}

splitInstances = function(x, n){ 
	#given a profile consisting of multiple runs (x) separated by screen shut-off, number of runs(n)
	#list of mat consisting of each instance with junk at beginning, end, and between runs culled
	#x must have column labeled "Screen State"
	
	l = vector("list", n)
	#print(colnames(x))
	if(debug)
		browser()
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
		
		while(scrnst[i]==1){
			i=i+1
			if(debug && i>length(scrnst))
				browser(condition = i>length(scrnst))
		}
		end = i
		
		#extract instance
		instance =  x[start:end,]
		
		#normalize timestamps. First record is 0.
		starttime = as.numeric(instance[1,1])
		#print(starttime)
		for(col in seq(1,ncol(x),2)){
			instance[,col]=as.numeric(instance[,col])-starttime
		}
		
		#keep track of minimal length for normalizing
		if(end-start<minLen){
			print(c(start, end, end-start))
			if(debug)
				browser()
			minLen = end-start
		}
		#print(c(end, start))
		
		l[[inst]] = instance
	}
	if(debug)
		browser()
	for(inst in 1:n){
		if(length(l[[inst]])>minLen){
			l[[inst]] = l[[inst]][1:minLen,]
		}
	}
	
	return(l)
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
		if(debug)
			browser()
		#print(paste(dim(sum), length(lst)))
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

getMean = function(instances, rollmean=FALSE){
	#browser("",debug)
	aggr = getAggregator(rollmean, TRUE, length(instances))
	return(aggr(instances)[[length(instances)+1]])
}

computeAttr = function(instance){
	attr(instance, "means") = colMeans(instance)
	attr(instance, "medians") = apply(instance, 2, median)
	attr(instance, "maximum") = apply(instance, 2, max)
	attr(instance, "minimum") = apply(instance, 2, min)
	#print(attributes(instance))
	return(instance)
}

splitTrace = function(trace){
	nums = trace[2]
	nums = apply(nums, 1, function(x){gsub("[^0-9\\.]","",x)})
	nums = as.numeric(nums)
	touches = sum(is.na(nums))
	ct = 1
	#print(touches)
	ends = matrix(0, touches, 2)
	ends[1,1] = 0
	for(i in 2:length(nums)){
		if(is.na(nums[i])){
			ends[ct,2] = nums[i-1]
			if(ct<touches){
				ct = ct+1
				ends[ct,1] = nums[i+1]
			}	
		}
	}
	ends[touches, 2] = nums[length(nums)]
	return(ends)
}

