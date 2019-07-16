ip <- as.data.frame(installed.packages())
ip <- ip[!ip$Priority %in% c('base', 'recommended'),]
sapply(ip[,1], remove.packages, lib = .libPaths()[1])
