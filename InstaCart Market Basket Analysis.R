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

#Customer Lifetime Value (CLV) using order frequency and average basket size per customer. This will help segment users into High / Medium / Low Value tiers.

#Step 1:📥 Prepare Customer-Level Metrics
# Calculate order frequency and average basket size per user
customer_metrics <- orders %>%
  filter(!is.na(user_id)) %>%
  inner_join(order_products, by = "order_id") %>%
  group_by(user_id) %>%
  summarise(
    num_orders = n_distinct(order_id),
    total_items = n(),
    avg_basket_size = total_items / num_orders,
    .groups = "drop"
  )

#Step 2. 🧮 Calculate CLV Proxy Score
customer_metrics <- customer_metrics %>%
  mutate(CLV_proxy = num_orders * avg_basket_size)

#Step 3. 📊 Segment into High / Medium / Low Value
customer_metrics <- customer_metrics %>%
  mutate(
    clv_segment = case_when(
      CLV_proxy >= quantile(CLV_proxy, 0.75) ~ "High Value",
      CLV_proxy >= quantile(CLV_proxy, 0.25) ~ "Medium Value",
      TRUE ~ "Low Value"
    )
  )

#Step 4. 📈 Visualize the Segmentation
ggplot(customer_metrics, aes(x = CLV_proxy, fill = clv_segment)) +
  geom_histogram(bins = 50, color = "white") +
  scale_fill_manual(values = c("High Value" = "#1b9e77", "Medium Value" = "#7570b3", "Low Value" = "#d95f02")) +
  labs(title = "Customer Lifetime Value Segments",
       x = "CLV Proxy Score", y = "Number of Customers") +
  theme_minimal()


#Clustering Products by Co-Purchase Behavior

#Step 1: Build the Product-Basket Matrix
# Filter for a manageable number of products (e.g., top 100)
top_products <- order_products %>%
  count(product_id, sort = TRUE) %>%
  top_n(100, wt = n) %>%
  pull(product_id)

# Filter orders that contain these top products
filtered_orders <- order_products %>%
  filter(product_id %in% top_products)

# Create a basket matrix: order_id × product_id
basket_matrix <- filtered_orders %>%
  mutate(value = 1) %>%
  pivot_wider(names_from = product_id, values_from = value, values_fill = 0)

#Step 2: Create Product Co-occurrence Matrix
# Remove order_id column and convert to matrix
basket_matrix_data <- as.matrix(basket_matrix[ , -1])

# Co-occurrence: product x product
co_occurrence <- t(basket_matrix_data) %*% basket_matrix_data

# Top 50 products instead of 100
top_products <- order_products %>%
  count(product_id, sort = TRUE) %>%
  slice_head(n = 50) %>%
  pull(product_id)

# Filter orders that only include top products
filtered_orders <- order_products %>%
  filter(product_id %in% top_products)

# Optional: limit to smaller baskets (2–10 products)
valid_orders <- filtered_orders %>%
  count(order_id) %>%
  filter(n >= 2 & n <= 10) %>%
  pull(order_id)

filtered_orders <- filtered_orders %>%
  filter(order_id %in% valid_orders)

library(tidyr)

basket_matrix <- filtered_orders %>%
  mutate(value = 1) %>%
  pivot_wider(names_from = product_id, values_from = value, values_fill = list(value = 0))

set.seed(123)
sample_orders <- sample(unique(order_products$order_id), 5000)

filtered_orders <- order_products %>%
  filter(product_id %in% top_products, order_id %in% sample_orders)

# Rebuild basket_matrix as before
basket_matrix <- filtered_orders %>%
  mutate(value = 1) %>%
  pivot_wider(names_from = product_id, values_from = value, values_fill = list(value = 0))

#Step 3: Apply K-means Clustering
# Normalize rows
library(scales)
norm_matrix <- apply(co_occurrence, 1, function(x) rescale(x, to = c(0, 1)))
norm_matrix <- t(norm_matrix)  # Transpose back

# Run K-means (e.g., 5 clusters)
set.seed(123)
k_clusters <- kmeans(norm_matrix, centers = 5)

# Assign cluster labels
product_clusters <- data.frame(
  product_id = rownames(co_occurrence),
  cluster = as.factor(k_clusters$cluster)
)

# Remove order_id column (if still present)
basket_data <- basket_matrix %>% select(-order_id)

# Scale data before PCA
basket_scaled <- scale(basket_data)

# Apply PCA
pca_result <- prcomp(basket_scaled, center = TRUE, scale. = TRUE)

# Use top 2 components
pca_df <- as.data.frame(pca_result$x[, 1:2])

#Step 4: K-Means Clustering on Products Based on Co-Purchase
# Transpose the basket data to make it product-wise (for clustering products)
product_matrix <- t(as.matrix(basket_data))

# Apply K-means (let’s try 5 clusters)
set.seed(123)
k_result <- kmeans(product_matrix, centers = 5)

# Add cluster info to product_id
product_clusters <- data.frame(
  product_id = colnames(basket_data),
  cluster = k_result$cluster
)

#Step 5: Visualize Product Clusters (if PCA was used)
# Use PCA of transposed matrix (products)
product_pca <- prcomp(product_matrix, center = TRUE, scale. = TRUE)
pca_products_df <- as.data.frame(product_pca$x[, 1:2])
pca_products_df$product_id <- rownames(product_pca$x)
pca_products_df$cluster <- as.factor(product_clusters$cluster)

ggplot(pca_products_df, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(alpha = 0.7) +
  labs(title = "Product Clusters Based on Co-Purchase Behavior") +
  theme_minimal()

#Demand Forecasting using time-series analysis
#Step 1: Install & Load Required Libraries
install.packages("prophet")
library(prophet)
library(dplyr)
library(lubridate)

#Step 2: Prepare Data – Daily Demand for a Top Product
# Filter for that product and join with orders
product_demand <- order_products %>%
  filter(product_id == 24852) %>%
  inner_join(orders, by = "order_id") %>%
  filter(!is.na(order_number), !is.na(order_dow)) %>%
  group_by(order_date = as.Date(eval_set == "prior", origin = "2015-01-01") + days(order_number)) %>%
  summarise(demand = n(), .groups = "drop")

# Simulate order_date based on order_number per user
orders <- orders %>%
  arrange(user_id, order_number) %>%
  group_by(user_id) %>%
  mutate(order_date = as.Date("2016-01-01") + days(order_number)) %>%
  ungroup()

# Now calculate daily demand for a top product (e.g., 24852 = organic bananas)
product_demand <- order_products %>%
  filter(product_id == 24852) %>%
  inner_join(orders, by = "order_id") %>%
  group_by(order_date) %>%
  summarise(demand = n(), .groups = "drop")

df_prophet <- product_demand %>%
  rename(ds = order_date, y = demand)

library(prophet)

model <- prophet(df_prophet)
future <- make_future_dataframe(model, periods = 30)
forecast <- predict(model, future)
plot(model, forecast)

#Use days_since_prior_order to reconstruct a user’s actual ordering timeline, relative to a start date.
# Convert NA to 0 for first orders
orders$days_since_prior_order[is.na(orders$days_since_prior_order)] <- 0

#Simulate realistic dates per user
library(dplyr)
library(lubridate)

# Simulate realistic order dates using cumulative sum of days
orders <- orders %>%
  arrange(user_id, order_number) %>%
  group_by(user_id) %>%
  mutate(
    order_date = as.Date("2016-01-01") + cumsum(days_since_prior_order)
  ) %>%
  ungroup()

head(orders %>% select(user_id, order_number, days_since_prior_order, order_date))

##🧯 Outlier Detection

#Calculate Order Frequency per User
order_freq <- orders %>%
  group_by(user_id) %>%
  summarise(total_orders = max(order_number), .groups = "drop")

#Calculate Average Basket Size per User
basket_size <- order_products %>%
  group_by(user_id = order_id) %>%   # order_id used as proxy for user
  summarise(basket = n(), .groups = "drop") %>%
  group_by(user_id) %>%
  summarise(avg_basket_size = mean(basket), .groups = "drop")

#Join Both Metrics
user_stats <- order_freq %>%
inner_join(basket_size, by = "user_id")

#. Define Outliers Using IQR Method
# IQR function
get_outliers <- function(x) {
  q1 <- quantile(x, 0.25)
  q3 <- quantile(x, 0.75)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  return(which(x < lower | x > upper))
}

# Detect outliers
outlier_orders <- get_outliers(user_stats$total_orders)
outlier_baskets <- get_outliers(user_stats$avg_basket_size)

# Flag users
user_stats <- user_stats %>%
  mutate(
    is_order_outlier = row_number() %in% outlier_orders,
    is_basket_outlier = row_number() %in% outlier_baskets
  )

#View Outliers
user_stats %>%
  filter(is_order_outlier | is_basket_outlier) %>%
  arrange(desc(total_orders), desc(avg_basket_size))

