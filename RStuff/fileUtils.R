# TODO: Add 
# 
# Author: dj2watso
###############################################################################


extractCSV=function(filename, name = filename){
	rawData = read.csv(filename, header = FALSE,na.strings = c("", "NA"),sep=',')
	
	App = rawData[2,1]
	Package = rawData[2,2]
	Time = rawData[2,3]
	Duration = rawData[2,4]
	colNames = rawData[4,]
	#print(colNames)
	for(i in 5:nrow(rawData)){			#find end of data
		if(all(is.na(rawData[i,]))){
			break
		}
	}
	rowNames = as.character(unlist(seq(from = 1, to = i-1, by = 1)))
	#print(dim(rowNames))
	
	dataPoints = as.matrix(rawData[c(6:i-1), -11]) #trim
	storage.mode(dataPoints) <- "numeric"
	
	
	#apply attributes
	attr(dataPoints, 'app') = App
	attr(dataPoints, 'package') = Package
	attr(dataPoints, 'time') = Time
	attr(dataPoints, 'duration') = Duration
	colNames = as.character(unlist(colNames))
	print(colNames)
	
	
	dataPoints = filterRows(dataPoints)
	print("dim:")
	print(dim(dataPoints))
	#print(typeof(dataPoints))
	colnames(dataPoints) = colNames
	rownames(dataPoints) <- 1:nrow(dataPoints)
	
	
	
	
	return(dataPoints)
}

extractTrace=function(filename,name = filename){
	dataFile = file(filename)
	rawData = readLines(dataFile, -1)
	
	rawData = strsplit(rawData, ",|:")
	return(rawData)
	
	delim = vector("numeric", 30)
	d = 1
	
	for(i in 1:length(rawData)){
		if(length(rawData[[i]])==1){
			delim[d] = i
			d=d+1
		}
	}
}

generatePlotForFiles = function(csvFile, n=10, metric = "CPU Load (Normalized) [%]", traceFile=null, aggregator=getaggregator(TRUE)){
	rawData = extractCSV(csvFile)
	instances = splitInstances(rawData, n)
	plotInstances(instances[-1], metric)
}






