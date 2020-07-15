# Title     : TODO
# Objective : TODO
# Created by: benaraujo
# Created on: 15/07/2020
library(lubridate)
library(dplyr)

journeys_data <- read.csv2("journey_data_stitch_2020.csv", header = TRUE ,sep = ",")
#names(journeys_data) <- c("rental_id", "duration", "bike_id", "end_date", "end_station_id", "end_station_name", "start_date", "start_station_id", "start_station_name")
all_stations <- read.csv2("All_stations.csv", header = TRUE ,sep = ",")
all_stations <- all_stations %>% select(id, latitude, longitude, name)
##data manipulation

#calculate number of journeys at starting point

journey_start <- journeys_data %>%
  mutate(year_date = as.integer(year(as.Date(start_date, format = "%d/%m/%y"))), week_num = as.integer(isoweek(as.Date(start_date, format = "%d/%m/%y")))) %>%
  group_by(year_date, week_num, startstation_id) %>%
  summarise(num_start_journeys = n_distinct(rental_id))

#calculate number of journeys at ending point

journey_end <- journeys_data %>%
  mutate(year_date = as.integer(year(as.Date(end_date, format = "%d/%m/%y"))), week_num = as.integer(isoweek(as.Date(end_date, format = "%d/%m/%y")))) %>%
  group_by(year_date, week_num, endstation_id) %>%
  summarise(num_end_journeys = n_distinct(rental_id))

#join the data tables
total_touchpoints_data <- journey_start %>%
  full_join(journey_end, by = c("startstation_id" = "endstation_id", "year_date"="year_date", "week_num" = "week_num")) %>%
  left_join(all_stations, by = c("startstation_id" = "id")) %>%
  rename("id" = "startstation_id")

# Add total Touchpoints and touch points per week

total_touchpoints_data <- total_touchpoints_data %>% mutate(total_touchpoints = num_start_journeys + num_end_journeys)


#Output for Tableau

write.csv(total_touchpoints_data, "total_cycle_touchpoints.csv")

## Further Analysis