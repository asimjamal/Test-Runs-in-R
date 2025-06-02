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

#2. Find the distribution of the Numeric variables


library(tidyr)

# Pivot data for plotting
starwars %>%
  select(where(is.numeric)) %>%
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value") %>%
  ggplot(aes(x = Variable, y = Value)) +
  geom_boxplot() +
  labs(title = "Distribution of Numeric Variables in Starwars Dataset") +
  theme_minimal()

#3. Find the columns that contain missing or infinite values

missing_col <- sapply(data, function(col) sum(is.na(col)))
infinite_col <- sapply(starwars, function(col) if(is.numeric(col)) sum(!is.finite(col)) else 0)

data.frame(
  Variable = names(data),
  Missing = missing_col,
  Infinite = infinite_col
) %>% filter(Missing > 0 | Infinite > 0)

#4. Clean the dataset
# Keeping only numeric columns & removing rows with N/A

data_clean <- data %>%
  select(where(is.numeric)) %>%
  drop_na()


#5. How many cluster best represent the numeric data in the starwars dataset
# K-means clustering for K = 2 to 5
k_values <- 2:5
cluster_results <- lapply(k_values, function(k) {
  kmeans_result <- kmeans(starwars_clean, centers = k, nstart = 10)
  return(list(data = starwars_clean, clusters = kmeans_result$cluster))
})

# (Your WCSS calculation line appears incorrect, but intended logic is to calculate total within-cluster sum of squares)
# Correct form should be:
wcss <- sapply(k_values, function(k) {
  kmeans(starwars_clean, centers = k, nstart = 10)$tot.withinss
})

elbow_df <- data.frame(K = k_values, WCSS = wcss)

ggplot(elbow_df, aes(x = K, y = WCSS)) +
  geom_line() +
  geom_point(color = "red") +
  labs(title = "Elbow Method for Optimal Number of Clusters",
       x = "Number of Clusters (K)", y = "Within-Cluster Sum of Squares (WCSS)") +
  theme_minimal()

#6. What does the data look like when segmented into 2-5 clusters
cluster_results <- lapply(k_values, function(k) {
  kmeans_result <- kmeans(starwars_clean, centers = k, nstart = 10)
  return(list(data = starwars_clean, clusters = kmeans_result$cluster))
})

# Extract and print the optimal cluster
optimal_k <- elbow_df$K[which.min(wcss)]  # This part isn't ideal; usually elbow is visual, not based on min
cluster_result_optimal <- cluster_results[[which(k_values == optimal_k)]]
print(cluster_result_optimal)
























