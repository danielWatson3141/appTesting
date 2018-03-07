# TODO: Add comment
# 
# Author: dj2watso
###############################################################################


refresh = function(){
	source("fileUtils.R")
	source("manifest.R")
	source("dataUtils.R")
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


