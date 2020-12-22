#!/usr/bin/env Rscript

# a script to process a folder with results from Nanoplot on different datasets

# create a list of files that need to be processed by the script

setwd("/Temp/Radar_mapping/nanoplot_results/")

#functions
# check.packages function: install and load multiple R packages. 
# (downloaded from: https://gist.github.com/smithdanielle/9913897)
# Check to see if packages are installed. Install them if they are not, then load them into the R session.
check.packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE, repos="https://cran.uib.no/")
  sapply(pkg, require, character.only = TRUE)
}

#Libraries to load and install if needed.
packages<-c("stringr")
check.packages(packages)

#making a list of all the files that need to be processed
np_stat_files <- list.files(getwd(), recursive = TRUE, pattern = "NanoStats.txt", full.names = TRUE)

number <- length(np_stat_files)

#use a for loop that takes each file and then adds the numbers in the second column to a dataframe
np_stats_all <- data.frame(c("Mean read length",
                                "Mean read quality",
                                "Median read length",
                                "Median read quality",
                                "Number of reads",
                                "Read length N50",
                                "Total bases"))
colnames(np_stats_all) <- "General.summary"


datalist = list()

for (i in 1:number) {
  #collection datasets
  myfile <- read.delim(np_stat_files[i],sep = ":")
  
  myfile <- myfile[1:7,]
  myfile$X <- as.numeric(gsub(",","",myfile$X))
  myfile2 <- data.frame(myfile$X)
  rownames(myfile2) <- myfile$General.summary
  
  name <- str_trunc(np_stat_files[i],37, "left", ellipsis = "") # getting the name of the dataset, trim left
  name <- str_trunc(name,9, "right", ellipsis = "") # trim right
 
  colnames(myfile2) <- sub("./", "", name) # keeping track which itteration produced this name
  datalist[[i]] <- myfile2  # add sample to list
}


np_stats_all <- do.call(cbind, datalist)

#transpose dataframe

np_stats_all <- data.frame(t(np_stats_all)
write.table(np_stats_all, file="nanoplot_stats_combined", sep="\t", quote = FALSE)

