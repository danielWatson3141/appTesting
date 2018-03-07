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
	colnames(dataPoints) = colNames
	rownames(dataPoints) <- 1:nrow(dataPoints)
	
	return(dataPoints)
}
