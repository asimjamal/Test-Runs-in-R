# Instacart EDA in R #
# Author: Asim Jamal#
# Dataset link : https://www.kaggle.com/datasets/psparks/instacart-market-basket-analysis #

#Installing Packages#
install.packages("tidyverse")
install.packages("data.table")
install.packages("ggplot2")
install.packages("scales")

#Activating Packages#
library(tidyverse)
library(data.table)
library(ggplot2)
library(scales) 

#Read the data file#
orders <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/Instacart Dataset/orders.csv", header = T,sep = ",", na.strings = "?")
order_products <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/Instacart Dataset/order_products__prior.csv", header = T,sep = ",", na.strings = "?")

#Frequency of Orders - Days Since Prior Order
ggplot(orders[!is.na(orders$days_since_prior_order), ], aes(x = days_since_prior_order)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  labs(title = "Days Since Prior Order", x = "Days", y = "Number of Orders") +
  theme_minimal()

#Order by day of the week
orders$order_dow <- factor(orders$order_dow,
                           levels = 0:6,
                           labels = c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))

ggplot(orders, aes(x = order_dow)) +
  geom_bar(fill = "orange") +
  labs(title = "Orders by Day of Week", x = "Day", y = "Order Count") +
  theme_minimal()

#Orders by Hour of the day
ggplot(orders, aes(x = order_hour_of_day)) +
  geom_histogram(binwidth = 1, fill = "seagreen", color = "black") +
  labs(title = "Orders by Hour of Day", x = "Hour", y = "Order Count") +
  theme_minimal()

#Average Numers of Items per Order
order_size <- order_products %>%
  group_by(order_id) %>%
  summarise(num_items = n())

ggplot(order_size, aes(x = num_items)) +
  geom_histogram(binwidth = 1, fill = "purple", color = "white") +
  labs(title = "Number of Items per Order", x = "Items", y = "Frequency") +
  theme_minimal() +
  xlim(0, 50)

