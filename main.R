# Title     : Main file
# Objective : Run this file! this is the only file you need to run.
# Created by: benaraujo

##Clear workspace
rm(list = ls())

##Install libraries
#install.packages("dplyr")
#install.packages("readr")
#install.packages("stringr")
#install.packages("lubridate")

##Load libraries
library(dplyr)
library(readr)
library(stringr)
library(lubridate)


#Run data_stitch.R
source("data_stitch.R", echo = T)
print("data_stitch.R has run successfully")

#Run data_analysis.R
source("data_analysis.R", echo = T)
print("data_analysis.R has run successfully")

