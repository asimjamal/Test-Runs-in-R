# Starwars EDA in R #
# Author: Asim Jamal#
# Dataset link : https://www.fabricionarcizo.com/post/starwars/starwars.csv #

#Installing Packages#
install.packages("dplyr")
install.packages("reshape2")
install.packages("ggplot2")
#Activating Packages#
library(dplyr)
library(ggplot2)
library(reshape2)

#Read the data file#
data <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/starwars.csv", header = T,sep = ",", na.strings = "?")

#Convert Non-Numeric to NA
starwars_data <- data %>%
  mutate_if(is.character, as.numeric)

#Remove non-numeric columns
starwars_data <- select_if(starwars_data, is.numeric)

#Function to check for Infinite or Missing Values
check_data_quality <- function(data) {
  missing_values <- sum(is.na(data))
  infinite_values <- sum(!is.finite(as.matrix(data)))
  return(list(missing_values = missing_values, infinite_values = infinite_values))
}

#Check for missing data or infinite data
data_quality <- check_data_quality(starwars_data)
missing_values <- data_quality_clean$missing_values
infinite_values_clean <- data_quality_clean$infinite_values