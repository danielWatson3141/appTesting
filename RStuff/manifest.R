# TODO: Add comment
# 
# Author: dj2watso
###############################################################################


refresh = function(){
	source("Rstuff/fileUtils.R")
	source("Rstuff/manifest.R")
	source("Rstuff/dataUtils.R")
	source("Rstuff/plottingUtils.R")
	gc()
}

lv = function(){
	return(.Last.value)
}

st = function(){
	return(traceback())
}

num = function(x){
	return(as.numeric(x))
}

filterRows =function(final){
	row.is.na = apply(final, 1, function(x){any(is.na(x))})
	print(sum(row.is.na))
	return(final[!row.is.na,])
}

#add matrices elementwise
add <- function(x) Reduce("+", x)

#adds ternary operator cause why not :P

`?` <- function(x, y)
	eval(
			sapply(
					strsplit(
							deparse(substitute(y)), 
							":"
					), 
					function(e) parse(text = e)
			)[[2 - as.logical(x)]])


