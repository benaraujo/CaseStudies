# Title     : data_analysis.R
# Objective : Summarise, Group and Analyse the data
# Created by: benaraujo
# Created on: 15/07/2020

##Read data files

journeys_data_2020 <- read.table("journeys_w1_w22_2020.csv", header = TRUE ,sep = ",") %>% select(-X)
journeys_data_2019 <- read.table("journeys_w1_w22_2019.csv", header = TRUE ,sep = ",") %>% select(-X)
journeys_data_2018 <- read.table("journeys_w1_w22_2018.csv", header = TRUE ,sep = ",") %>% select(-X)


##Yearly comparisons
journey_data <- bind_rows(journeys_data_2018, journeys_data_2019, journeys_data_2020)

journey_data_yoy <- journey_data %>%
  mutate(year_date = as.integer(year(as.Date(start_date, format = "%d/%m/%Y"))), week_num = as.integer(isoweek(as.Date(start_date, format = "%d/%m/%Y")))) %>%
  filter(between(week_num, 1, 21)) %>%
  group_by(year_date, week_num) %>%
  summarise(number_of_journeys = n_distinct(rental_id), duration_in_hours = sum(duration)/3600)


write.csv(journey_data_yoy, "journey_data_yoy.csv")

############################################################
##Most Popular routes after lockdown
#journey_data_route <- journey_data %>%
#  mutate(year_date = as.integer(year(as.Date(start_date, format = "%d/%m/%Y"))), week_num = as.integer(isoweek(as.Date(start_date, format = "%d/%m/%Y")))) %>%
#  filter(between(week_num, 14, 21) & between(year_date, 2019, 2020) & startstation_id != endstation_id) %>%
#  mutate(route = paste(startstation_name, " to ", endstation_name)) %>%
#  group_by(year_date, route) %>%
#  summarise(number_of_journeys = n_distinct(rental_id), duration_in_hours = sum(duration)/3600) %>%
#  filter(number_of_journeys >= 100)
############################################################

#calculate number of journeys at starting point

journey_start <- journey_data %>%
  mutate(year_date = as.integer(year(as.Date(start_date, format = "%d/%m/%Y"))), week_num = as.integer(isoweek(as.Date(start_date, format = "%d/%m/%Y")))) %>%
  group_by(year_date, week_num, startstation_id) %>%
  summarise(num_start_journeys = n_distinct(rental_id))

#calculate number of journeys at ending point

journey_end <- journey_data %>%
  mutate(year_date = as.integer(year(as.Date(end_date, format = "%d/%m/%Y"))), week_num = as.integer(isoweek(as.Date(end_date, format = "%d/%m/%Y")))) %>%
  group_by(year_date, week_num, endstation_id) %>%
  summarise(num_end_journeys = n_distinct(rental_id))

#join the data tables
total_journeys_data <- journey_start %>%
  full_join(journey_end, by = c("startstation_id" = "endstation_id", "year_date"="year_date", "week_num" = "week_num")) %>%
  left_join(all_stations, by = c("startstation_id" = "id")) %>%
  rename("id" = "startstation_id")

# Add total journeys

total_journeys_data <- total_journeys_data %>% mutate(total_journeys = num_start_journeys + num_end_journeys)


#Output for Tableau

write.csv(total_journeys_data, "total_journeys_data.csv")
