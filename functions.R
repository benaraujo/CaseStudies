# Title     : Functions file
# Objective : Lists all the custom functions used for the project
# Created by: benaraujo


##Data extraction function

extract_journey_data <- function (id_starting, id_ending){
  #enter the starting and end id

   download_files <- meta_data_file %>%
  filter(between(id, id_starting, id_ending))

  number_of_files <- dim(download_files)[1]

  for(i in 1:number_of_files){
  if(i == 1) {journey_data_stitch <- read.csv2(paste(url_prefix,download_files$file_name[i]), sep = ",", header = TRUE) %>% mutate(file_id = download_files$id[i])}
  if(i>1){
    tempdata <- read.csv2(paste(url_prefix, download_files$file_name[i]), sep = ",", header = TRUE) %>% mutate(file_id = download_files$id[i])
    journey_data_stitch <- rbind(journey_data_stitch, tempdata)
  }
    print(paste("successfully processed ", i, " out of ", number_of_files, " files...."))
}
  names(journey_data_stitch) <- c("rental_id", "duration", "bike_id", "end_date", "endstation_id", "endstation_name", "start_date", "startstation_id", "startstation_name", "file_id")

  return(journey_data_stitch)
}


