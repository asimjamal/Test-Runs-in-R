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

#Combine with Order to see user trends
# Merge to get user_id per order
order_user_items <- orders %>%
  inner_join(order_size, by = "order_id")

# Average items per order per user
user_order_stats <- order_user_items %>%
  group_by(user_id) %>%
  summarise(avg_items = mean(num_items))

ggplot(user_order_stats, aes(x = avg_items)) +
  geom_histogram(binwidth = 1, fill = "dodgerblue", color = "black") +
  labs(title = "Avg Items Per Order Per User", x = "Avg Items", y = "Users") +
  theme_minimal()

##Reorder Ratio by order #
# Calculate reorder ratio for each order number
reorder_by_number <- orders %>%
  inner_join(order_products, by = "order_id") %>%
  group_by(order_number) %>%
  summarise(reorder_ratio = mean(reordered, na.rm = TRUE))

# Plot
ggplot(reorder_by_number, aes(x = order_number, y = reorder_ratio)) +
  geom_line(color = "steelblue") +
  geom_smooth(se = FALSE, color = "darkred", linetype = "dashed") +
  labs(title = "Reorder Ratio by Order Number",
       x = "Order Number (User Order Sequence)",
       y = "Reorder Ratio") +
  theme_minimal()




