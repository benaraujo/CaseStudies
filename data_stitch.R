rm(list = ls())

##Install libraries
#install.packages("dplyr")
#install.packages("readr")
library(dplyr)
library(readr)

##Read data

journeys_data <- read.csv2("All_journeys_29thApr-26thMay.csv", header = TRUE ,sep = ",")
names(journeys_data) <- c("rental_id", "duration", "bike_id", "end_date", "end_station_id", "end_station_name", "start_date", "start_station_id", "start_station_name")
all_stations <- read.csv2("All_stations.csv", header = TRUE ,sep = ",")
all_stations <- all_stations %>% select(id, latitude, longitude, name)
##data manipulation

#calculate number of journeys at starting point

journey_start <- journeys_data %>% group_by(start_station_id) %>% summarise(num_start_journeys = n_distinct(rental_id))

#calculate number of journeys at ending point

journey_end <- journeys_data %>% group_by(end_station_id) %>% summarise(num_end_journeys = n_distinct(rental_id))

#join the data tables
total_touchpoints_data <- all_stations %>% left_join(journey_start, by = c("id" = "start_station_id")) %>% left_join(journey_end, by = c("id" = "end_station_id"))

# Add total Touchpoints and touch points per week

total_touchpoints_data <- total_touchpoints_data %>% mutate(total_touchpoints = num_start_journeys + num_end_journeys) %>% mutate(weekly_touchpoints = total_touchpoints/4)


#Output for Tableau

write.csv(total_touchpoints_data, "total_cycle_touchpoints.csv")

## Further Analysis

conv_rate <- 0.12

week_dock_table <- data.frame(1:166) %>% 
  rename(num_stations_r = X1.166) %>%
  mutate(num_weeks = floor(((50000/num_stations_r) -100)/200)) %>%
  group_by(num_weeks) %>%
  summarise(num_stations = max(num_stations_r)) %>%
  mutate(campaign_cost = num_stations*((200*num_weeks) + 100))

#plot(week_dock_table$num_stations, week_dock_table$num_weeks)




agg_touchpoints <- total_touchpoints_data %>% arrange(desc(weekly_touchpoints)) %>% 
  mutate(rn = row_number(), sum_weekly_touchpoints = cumsum(floor(weekly_touchpoints))) %>% select(rn, sum_weekly_touchpoints)

week_dock_touches <- week_dock_table %>% left_join(agg_touchpoints, by = c("num_stations"="rn")) %>% mutate(total_touches = num_weeks*sum_weekly_touchpoints)
  
echo_data_output <- week_dock_touches %>% mutate(Expected_Campaign_Revenue_per_week = sum_weekly_touchpoints * conv_rate * 179)



#testing

#ben <- journeys_data %>% filter(start_station_id == 191)

write.csv(echo_data_output, "echo_data_output.csv")
