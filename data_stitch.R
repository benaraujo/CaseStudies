rm(list = ls())

##Install libraries
#install.packages("dplyr")
#install.packages("readr")
library(dplyr)
library(readr)
library(stringr)

##Read metadata from Website
meta_data_file <- read.csv2(file = "filenames.csv", sep = ",", header = FALSE)
names(meta_data_file) <- c('file_name','upload_date', 'upload_time','file_size','file_type')

##Only consider new format
Journey_data <- meta_data_file[grep('JourneyDataExtract', meta_data_file$file_name),]
##Generate ID for the filenames
datasplit <- as.data.frame(str_split_fixed(Journey_data$file_name, "JourneyDataExtract", 2))
names(datasplit) <- c("id", "date_range")
datasplit$id <- as.integer(datasplit$id)
Journey_data_indexed <- cbind(datasplit, Journey_data)

##Create list of files to be downloaded
download_files <- Journey_data_indexed %>%
  filter(between(id, 195, 215))

ben <- read.csv2(paste("https://cycling.data.tfl.gov.uk/usage-stats/",download_files$file_name[1]), sep = ",", header = TRUE)
names(ben)


for(i in 1:dim(download_files)[1]){
  if(i == 1) {journey_data_stitch <- read.csv2(paste("https://cycling.data.tfl.gov.uk/usage-stats/",download_files$file_name[i]), sep = ",", header = TRUE) }
  if(i>1){
    tempdata <- read.csv2(paste("https://cycling.data.tfl.gov.uk/usage-stats/",download_files$file_name[i]), sep = ",", header = TRUE)
    journey_data_stitch <- rbind(journey_data_stitch, tempdata)
  }
}
names(journey_data_stitch) <- c("rental_id", "duration", "bike_id", "end_date", "endstation_id", "endstation_name", "start_date", "startstation_id", "startstation_name")
write.csv(journey_data_stitch, "journey_data_stitch_2020.csv")


