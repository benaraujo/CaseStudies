# Title     : Data stitch
# Objective : Loading meta data and downloading all source files
# Created by: benaraujo

##Source functions R script
source("functions.R", echo = TRUE)

##Read metadata
meta_data_file <- read.csv2(file = "filenames.csv", sep = ",", header = FALSE)
names(meta_data_file) <- c('file_name','upload_date', 'upload_time','file_size','file_type')
url_prefix <- "https://cycling.data.tfl.gov.uk/usage-stats/"

all_stations <- read.csv2("All_stations.csv", header = TRUE ,sep = ",")
all_stations <- all_stations %>% select(id, latitude, longitude, name)

##Only consider new format
meta_data <- meta_data_file[grep('JourneyDataExtract', meta_data_file$file_name),]
##Generate ID for the filenames
datasplit <- as.data.frame(str_split_fixed(meta_data$file_name, "JourneyDataExtract", 2))
names(datasplit) <- c("id", "date_range")
datasplit$id <- as.integer(datasplit$id)
meta_data_file <- cbind(datasplit, meta_data) %>%
  filter(is.na(id) == FALSE)


##Create metadata csv file
write.csv(meta_data_file, "meta_data_file.csv")

##Calling data extraction functions
#extracting data between Week 1 and Week 22 for 2020
journeys_w1_w22_2020 <- extract_journey_data(195, 215)
write.csv(journeys_w1_w22_2020, "journeys_w1_w22_2020.csv")


#extracting data between Week 1 and Week 22 for 2019
journeys_w1_w22_2019 <- extract_journey_data(142, 164)
write.csv(journeys_w1_w22_2019, "journeys_w1_w22_2019.csv")


#extracting data between Week 1 and Week 22 for 2018
journeys_w1_w22_2018 <- extract_journey_data(90, 112)
write.csv(journeys_w1_w22_2018, "journeys_w1_w22_2018.csv")

