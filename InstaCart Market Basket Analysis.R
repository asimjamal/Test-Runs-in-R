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
library(dplyr)
library(tidyr)

#Read the data file#
orders <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/Instacart Dataset/orders.csv", header = T,sep = ",", na.strings = "?")
order_products <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/Instacart Dataset/order_products__prior.csv", header = T,sep = ",", na.strings = "?")
products <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/Instacart Dataset/products.csv", header = TRUE, sep = ",", na.strings = "?")
departments <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/Instacart Dataset/departments.csv", header = TRUE, sep = ",", na.strings = "?")

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

##Reorder Vs First time orders
reorder_counts <- order_products %>%
  mutate(order_type = ifelse(reordered == 1, "Reorder", "First Time")) %>%
  group_by(order_type) %>%
  summarise(count = n())

# Plot
ggplot(reorder_counts, aes(x = order_type, y = count, fill = order_type)) +
  geom_bar(stat = "identity") +
  labs(title = "Reorders vs First-Time Orders",
       x = "Order Type", y = "Number of Products") +
  theme_minimal()

##Merge Product data with Department Info
# Merge prior order data with products and departments
prior_merged <- order_products %>%
  left_join(products, by = "product_id") %>%
  left_join(departments, by = "department_id") %>%
  left_join(orders, by = "order_id")

#Top 10 reordered products
top_reordered_products <- prior_merged %>%
  filter(reordered == 1) %>%
  group_by(product_name) %>%
  summarise(reorder_count = n()) %>%
  arrange(desc(reorder_count)) %>%
  slice_head(n = 10)

# Plot
ggplot(top_reordered_products, aes(x = reorder(product_name, reorder_count), y = reorder_count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Reordered Products", x = "Product", y = "Reorder Count") +
  theme_minimal()


#Reorder rate by department
reorder_rate_dept <- prior_merged %>%
  group_by(department, reordered) %>%
  summarise(order_count = n(), .groups = "drop") %>%
  pivot_wider(names_from = reordered, values_from = order_count, values_fill = 0) %>%
  rename(not_reordered = `0`, reordered = `1`) %>%
  mutate(total_orders = reordered + not_reordered,
         reorder_rate = reordered / total_orders) %>%
  arrange(desc(reorder_rate))

# Plot
ggplot(reorder_rate_dept, aes(x = reorder(department, reorder_rate), y = reorder_rate)) +
  geom_col(fill = "darkgreen") +
  coord_flip() +
  labs(title = "Reorder Rate by Department", x = "Department", y = "Reorder Rate") +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()

#Reorder distribution per customer
customer_reorders <- prior_merged %>%
  group_by(user_id = user_id) %>%
  summarise(total_orders = n(),
            total_reorders = sum(reordered == 1, na.rm = TRUE)) %>%
  mutate(reorder_ratio = total_reorders / total_orders)

# Plot
ggplot(customer_reorders, aes(x = reorder_ratio)) +
  geom_histogram(binwidth = 0.05, fill = "orange", color = "black") +
  labs(title = "Reorder Ratio per Customer", x = "Reorder Ratio", y = "Number of Customers") +
  theme_minimal()

## Average Basket Size and Product Diversity
# Calculate basket size per order
basket_size <- order_products %>%
  group_by(order_id) %>%
  summarise(total_items = n())

# Plot distribution of basket sizes
ggplot(basket_size, aes(x = total_items)) +
  geom_histogram(binwidth = 1, fill = "skyblue", color = "black") +
  labs(title = "Distribution of Basket Sizes", x = "Number of Items per Order", y = "Count of Orders") +
  theme_minimal()

#Calculate average markey size per customer
# Merge order_products with orders to get user_id
basket_per_user <- order_products %>%
  left_join(orders, by = "order_id") %>%
  group_by(user_id, order_id) %>%
  summarise(items_in_order = n()) %>%
  group_by(user_id) %>%
  summarise(avg_basket_size = mean(items_in_order))

# Plot distribution of average basket sizes per user
ggplot(basket_per_user, aes(x = avg_basket_size)) +
  geom_histogram(binwidth = 1, fill = "mediumpurple", color = "black") +
  labs(title = "Average Basket Size per Customer", x = "Average Items per Order", y = "Number of Customers") +
  theme_minimal()

#Product Diversity per customer
product_diversity <- order_products %>%
  left_join(orders, by = "order_id") %>%
  group_by(user_id) %>%
  summarise(unique_products = n_distinct(product_id))

# Plot distribution of product diversity
ggplot(product_diversity, aes(x = unique_products)) +
  geom_histogram(binwidth = 5, fill = "tomato", color = "black") +
  labs(title = "Product Diversity per Customer", x = "Number of Unique Products", y = "Number of Customers") +
  theme_minimal()

##Reorder Probability by Product (Stickiness Score)
#This will help us:
#Identify products customers love and come back for.
#Lay the groundwork for recommendation systems.

# Step 1: Merge order details with product data
order_data <- order_products %>%
  inner_join(orders, by = "order_id")

# Group by product_id to calculate reorder probability
product_reorder_stats <- order_data %>%
  group_by(product_id) %>%
  summarise(
    total_orders = n(),
    times_reordered = sum(reordered, na.rm = TRUE),
    reorder_prob = round(times_reordered / total_orders, 3)
  ) %>%
  arrange(desc(reorder_prob))

product_reorder_stats <- product_reorder_stats %>%
  inner_join(products, by = "product_id") %>%
  select(product_id, product_name, everything())

top_reordered <- product_reorder_stats %>%
  top_n(15, reorder_prob)

ggplot(top_reordered, aes(x = reorder(product_name, reorder_prob), y = reorder_prob)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  coord_flip() +
  labs(
    title = "Top 15 Products with Highest Reorder Probability",
    x = "Product Name",
    y = "Reorder Probability"
  ) +
  theme_minimal()

##Time Gap Between Orders (Customer Retention Analysis)

# Filter prior orders and remove NA values
order_gaps <- orders %>%
  filter(eval_set == "prior", !is.na(days_since_prior_order))

ggplot(order_gaps, aes(x = days_since_prior_order)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "black") +
  labs(
    title = "Time Gap Between Orders",
    x = "Days Since Prior Order",
    y = "Number of Orders"
  ) +
  theme_minimal()

#Calculate average time gap per user 
avg_gap_per_user <- order_gaps %>%
  group_by(user_id) %>%
  summarise(
    avg_gap = mean(days_since_prior_order, na.rm = TRUE),
    orders_count = n()
  ) %>%
  arrange(avg_gap)

ggplot(avg_gap_per_user, aes(x = avg_gap)) +
  geom_histogram(binwidth = 1, fill = "coral", color = "black") +
  labs(
    title = "Average Time Between Orders per Customer",
    x = "Average Days Between Orders",
    y = "Number of Customers"
  ) +
  theme_minimal()


##Segment Time Gaps by Weekday vs Weekend Shoppers
#Identify weekend vs. weekday orders
orders <- orders %>%
  mutate(
    day_type = case_when(
      order_dow %in% c(0, 6) ~ "Weekend",  # 0 = Sunday, 6 = Saturday
      TRUE ~ "Weekday"
    )
  )

#Compare days_since_prior_order between both segments
ggplot(orders %>% filter(!is.na(days_since_prior_order), eval_set == "prior"),
       aes(x = days_since_prior_order, fill = day_type)) +
  geom_density(alpha = 0.6) +
  labs(
    title = "Time Gap Between Orders by Day Type",
    x = "Days Since Prior Order",
    y = "Density",
    fill = "Day Type"
  ) +
  theme_minimal()

#Check avg gap
orders %>%
  filter(!is.na(days_since_prior_order), eval_set == "prior") %>%
  group_by(day_type) %>%
  summarise(avg_gap = mean(days_since_prior_order))

##Compare Loyal vs Infrequent Customers
#Count total orders per user
user_order_counts <- orders %>%
  filter(eval_set == "prior") %>%
  group_by(user_id) %>%
  summarise(total_orders = n())

#Merge with orders & classify loyalty
orders_loyalty <- orders %>%
  inner_join(user_order_counts, by = "user_id") %>%
  mutate(loyalty_group = case_when(
    total_orders >= 20 ~ "Loyal",
    total_orders <= 5 ~ "Infrequent",
    TRUE ~ "Moderate"
  ))

#Compare reorder gap between loyalty groups
ggplot(orders_loyalty %>% filter(!is.na(days_since_prior_order), eval_set == "prior"),
       aes(x = days_since_prior_order, fill = loyalty_group)) +
  geom_density(alpha = 0.6) +
  labs(
    title = "Reorder Time Gap by Customer Loyalty",
    x = "Days Since Prior Order",
    y = "Density",
    fill = "Loyalty Group"
  ) +
  theme_minimal()

orders_loyalty %>%
  filter(!is.na(days_since_prior_order), eval_set == "prior") %>%
  group_by(loyalty_group) %>%
  summarise(avg_gap = mean(days_since_prior_order))

##Churn Risk Prediction Using Time Gaps Between Orders
#Step 1: Calculate average and most recent gaps per customer
# Filter for relevant data
prior_orders <- orders %>% filter(eval_set == "prior" & !is.na(days_since_prior_order))

# Calculate average and last gap per user
user_gap_stats <- prior_orders %>%
  group_by(user_id) %>%
  summarise(
    avg_gap = mean(days_since_prior_order, na.rm = TRUE),
    last_gap = days_since_prior_order[order_number == max(order_number)]
  ) %>%
  mutate(
    gap_ratio = last_gap / avg_gap,
    churn_risk = case_when(
      gap_ratio > 1.5 ~ "High Risk",
      gap_ratio > 1.1 ~ "Moderate Risk",
      TRUE ~ "Low Risk"
    )
  )

#Step 2: Visualize churn risk categories
ggplot(user_gap_stats, aes(x = gap_ratio, fill = churn_risk)) +
  geom_histogram(binwidth = 0.1, alpha = 0.7, color = "black") +
  scale_fill_manual(values = c("Low Risk" = "#2ca02c", "Moderate Risk" = "#ff7f0e", "High Risk" = "#d62728")) +
  labs(
    title = "Churn Risk Distribution Based on Time Gap Trends",
    x = "Last Gap / Average Gap (Gap Ratio)",
    y = "Number of Users",
    fill = "Churn Risk Level"
  ) +
  theme_minimal()

#Step 3: View proportions of churn risk
user_gap_stats %>%
  count(churn_risk) %>%
  mutate(percent = round(100 * n / sum(n), 1))


#Simple Churn Prediction Model (Logistic Regression)
#We’ll predict whether a user is at high churn risk (based on gap ratio) using a few behavioral features.

#Step 1: Prep the Dataset
# 1. Average basket size per user
basket_size <- order_products %>%
  group_by(order_id) %>%
  summarise(items = n()) %>%
  left_join(orders, by = "order_id") %>%
  filter(eval_set == "prior") %>%
  group_by(user_id) %>%
  summarise(avg_basket_size = mean(items))

# 2. Reorder ratio
reorder_rate <- order_products %>%
  filter(!is.na(reordered)) %>%
  left_join(orders, by = "order_id") %>%
  filter(eval_set == "prior") %>%
  group_by(user_id) %>%
  summarise(reorder_ratio = mean(reordered))

# 3. Merge with churn labels
churn_model_data <- user_gap_stats %>%
  left_join(basket_size, by = "user_id") %>%
  left_join(reorder_rate, by = "user_id") %>%
  mutate(churn_flag = ifelse(churn_risk == "High Risk", 1, 0)) %>%
  select(user_id, avg_gap, last_gap, gap_ratio, avg_basket_size, reorder_ratio, churn_flag) %>%
  na.omit()

# Step 2: Train a Logistic Regression Model
# Fit logistic regression model
churn_model <- glm(churn_flag ~ gap_ratio + avg_basket_size + reorder_ratio,
                   data = churn_model_data, family = "binomial")

summary(churn_model)

#Step 3: Evaluate Performance (Optional Quick View)
# Predict probabilities
churn_model_data$predicted_prob <- predict(churn_model, type = "response")

# Basic thresholding (0.5)
churn_model_data$predicted_class <- ifelse(churn_model_data$predicted_prob > 0.5, 1, 0)

# Accuracy
mean(churn_model_data$predicted_class == churn_model_data$churn_flag)

#Step 4: Visualize Predicted Churn Risk Distribution
ggplot(churn_model_data, aes(x = predicted_prob)) +
  geom_histogram(binwidth = 0.05, fill = "steelblue", color = "white") +
  labs(title = "Predicted Churn Probability", x = "Probability", y = "Users") +
  theme_minimal()


#Product-Level Churn Signals : Find products that users used to buy often, but have stopped buying recently — a signal of disengagement or churn.
#Step 1: Identify Last Order per User
# Get each user's last order
last_orders <- orders %>%
  filter(eval_set == "prior") %>%
  group_by(user_id) %>%
  summarise(last_order_id = order_id[which.max(order_number)])

#Step 2: Find Products NOT Purchased in Last Order
# All products bought before last order
all_purchases <- order_products %>%
  inner_join(orders, by = "order_id") %>%
  filter(eval_set == "prior")

# Get products per user across all prior orders except last one
prior_product_history <- all_purchases %>%
  inner_join(last_orders, by = "user_id") %>%
  filter(order_id != last_order_id) %>%
  group_by(user_id, product_id) %>%
  summarise(times_bought = n(), .groups = "drop")

# Products bought in last order
last_order_products <- order_products %>%
  semi_join(last_orders, by = "order_id") %>%
  select(order_id, product_id) %>%
  distinct()

# Products dropped in last order
# Rename last_order_id to match the column name in order_products
last_order_ids <- last_orders %>%
  rename(order_id = last_order_id)

# Now join to get products in those last orders
last_order_products <- order_products %>%
  semi_join(last_order_ids, by = "order_id") %>%
  select(order_id, product_id) %>%
  distinct()

#Step 3: Identify Top Dropped Products
# Total times each product was ever bought
product_order_counts <- order_products %>%
  group_by(product_id) %>%
  summarise(total_orders = n(), .groups = "drop")

# Times each product appeared in a user's last order
last_order_ids <- last_orders %>%
  rename(order_id = last_order_id)

last_order_products <- order_products %>%
  semi_join(last_order_ids, by = "order_id") %>%
  select(order_id, product_id) %>%
  distinct()

last_product_counts <- last_order_products %>%
  group_by(product_id) %>%
  summarise(last_ordered = n(), .groups = "drop")

# Merge and calculate drop-off
product_churn_risk <- product_order_counts %>%
  left_join(last_product_counts, by = "product_id") %>%
  mutate(last_ordered = replace_na(last_ordered, 0),
         churn_ratio = 1 - (last_ordered / total_orders)) %>%
  arrange(desc(churn_ratio)) %>%
  filter(total_orders > 20)  # optional: exclude rarely purchased products

#Step 4: Visualize Top Dropped Products
# Join product names
top_dropped <- product_churn_risk %>%
  inner_join(products, by = "product_id") %>%
  select(product_name, churn_ratio, total_orders) %>%
  arrange(desc(churn_ratio)) %>%
  slice_head(n = 15)

# Plot
ggplot(top_dropped, aes(x = reorder(product_name, churn_ratio), y = churn_ratio)) +
  geom_col(fill = "tomato") +
  coord_flip() +
  labs(title = "Top Dropped Products (Churn Risk)",
       x = "Product",
       y = "Churn Ratio") +
  theme_minimal()


#Customer Segmentation using RFM Analysis using the Instacart dataset
#Step 1:Prep Required Data
# Combine user orders with product count
order_items_per_user <- order_products %>%
  inner_join(orders, by = "order_id") %>%
  group_by(user_id, order_id, order_number, order_dow, order_hour_of_day, days_since_prior_order) %>%
  summarise(products_purchased = n(), .groups = "drop")

# Get the most recent order number for each user
last_order_info <- orders %>%
  group_by(user_id) %>%
  summarise(last_order_number = max(order_number, na.rm = TRUE), .groups = "drop")
#Step 2:Calculate RFM Metrics
# RFM Metrics per user
rfm <- order_items_per_user %>%
  group_by(user_id) %>%
  summarise(
    recency = sum(days_since_prior_order[order_number == max(order_number, na.rm = TRUE)], na.rm = TRUE),
    frequency = n_distinct(order_id),
    monetary = mean(products_purchased),
    .groups = "drop"
  ) %>%
  na.omit()

#Step 3: Segment Users Using K-means Clustering
# Scale the RFM values
rfm_scaled <- rfm %>%
  select(-user_id) %>%
  scale()

# Apply K-means (choose 3 to 5 clusters to start)
set.seed(42)
rfm_clusters <- kmeans(rfm_scaled, centers = 4, nstart = 25)

# Attach cluster labels
rfm$segment <- as.factor(rfm_clusters$cluster)

#Step 4:Visualize Clusters

ggplot(rfm, aes(x = frequency, y = monetary, color = segment)) +
  geom_point(alpha = 0.7) +
  labs(title = "Customer Segmentation using RFM",
       x = "Frequency (# Orders)",
       y = "Monetary (Avg. Items per Order)",
       color = "Segment") +
  theme_minimal()

#Segment 1: Loyal + Big basket shoppers
#Segment 2: Infrequent + Small basket
#Segment 3: High frequency but low value
#Segment 4: Recent reactivations, etc.


#Market Basket Analysis using Association Rules with the arules package in R. This technique helps us find frequently bought together products — super useful for cross-sell strategies and product placement.

#Step 1: Install & Load Required Libraries
install.packages("arules")
install.packages("arulesViz")
library(arules)
library(arulesViz)
library(dplyr)
#Step 2: Prepare the Data
# Load product names
products <- read.csv("/Users/asimjamal/Downloads/Website/R EDA/Instacart Dataset/products.csv")

# Merge product names into the order_products
order_products_named <- order_products %>%
  left_join(products, by = "product_id") %>%
  select(order_id, product_name)
# Create transactions object
# Convert to list format grouped by order
transactions_list <- split(order_products_named$product_name, order_products_named$order_id)

# Convert to transactions format
transactions <- as(transactions_list, "transactions")

#Step 3: Apply the Apriori Algorithm
rules <- apriori(transactions,
                 parameter = list(supp = 0.01, conf = 0.2, minlen = 2))

# Step 4: Explore Top Rules
# Sort by lift and show top 10
inspect(sort(rules, by = "lift")[1:10])

#Step 5: Visualize Association Rules
plot(rules, method = "graph", engine = "htmlwidget")
