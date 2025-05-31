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

#1. What are the summary statistics (min, max, mean, mode) of each column in the starwars dataset

#Function to calculate Mode

get_mode <- function(v){
  uniqv <- unique(na.omit(v))
  uniqv[which.max(tabulate(match(v,uniqv)))]
}

#Apply Summary Stats

summary_df <- data %>%
  summarise(across(everything(), list(
    min = ~if(is.numeric(.)) min(., na.rm = TRUE) else NA,
    max = ~if(is.numeric(.)) max(., na.rm = TRUE) else NA,
    mean = ~if(is.numeric(.)) mean(., na.rm = TRUE) else NA,
    mode = ~get_mode(.)
  ), .names = "{.col}_{.fn}"))


print(t(summary_df))