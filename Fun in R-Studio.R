install.packages("tidyverse")
library("tidyverse")

datasetpath <- "/Users/asimjamal/Downloads/"
dataset1 <- read_csv(str_c(datasetpath,"Most_Visited_Destination_in_2018_and_2019.csv"))

dataset1

dataset1 %>%
  class()

dataset1 %>%
  view()

dataset2 <- dataset1 %>%
  rename('2019' = 'International  tourist  arrivals  (2019)')
dataset2

dataset3 <- dataset2 %>%
  rename('T2018' = 'International  tourist  arrivals  (2018)')
dataset3

dataset4 <- dataset3 %>%
  select(- '...1' ,- '2019')
dataset4

view(dataset4)
le6 <- 1000000

dataset5 <- dataset4 %>%
  mutate(across(everything(), ~ replace(., . == "-", NA)),
         T2018 = as.numeric(str_replace(T2018, " million","")))

dataset6 <- dataset5 %>%
  mutate(T2018 = as.numeric(T2018) * 1000000)

dataset7 <- dataset6 %>%
  na.omit()
view(dataset7)

dataset8 <- dataset7 %>%
  filter(Destination != "Egypt" | Region == "Africa")
view(dataset8)

plot <- dataset8 %>%
  mutate(Destination = reorder(Destination, T2018)) %>%
  ggplot(aes(x = Destination,
             y = T2018,
             fill = Region)) +
  geom_col() + 
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1,
                                   vjust = 0.6))
plot

colnames(dataset1)
----- Exp

newdataset <- dataset1 %>%
  rename(T2019 = 'International  tourist  arrivals  (2019)') %>%
  rename(T2018 = 'International  tourist  arrivals  (2018)') %>%
  select(- '...1' ,- 'T2019') %>%
  mutate(across(everything(), ~ replace(., . == "-", NA)),
         T2018 = as.numeric(str_replace(T2018, " million","")))%>%
  mutate(T2018 = as.numeric(T2018) * 1000000)%>%
  na.omit()%>%
  filter(Destination != "Egypt" | Region == "Africa")

plot <- newdataset %>%
  mutate(Destination = reorder(Destination, T2018)) %>%
  ggplot(aes(x = Destination,
             y = T2018,
             fill = Region)) +
  geom_col() + 
  theme(axis.text.x = element_text(angle = 45,
                                   hjust = 1,
                                   vjust = 0.6))
plot


library(ggplot2)
library(dplyr)

d <- diamonds
view(d)

d1 <- d %>%
  dplyr::select(cut,price)%>%
  dplyr::mutate(meanprice = mean(price))
view(d1)

d2 <- d %>%
  dplyr::select(cut,price)%>%
  dplyr::summarise(meanprice = mean(price))
view(d2)


d3 <- d %>%
  dplyr::select(cut,price)%>%
  dplyr::group_by(cut)%>%
  dplyr::summarise(meanprice = mean(price))
view(d3)

d4 <- d %>%
  dplyr::select(cut,price)%>%
  dplyr::group_by(cut)%>%
  dplyr::summarise(meanprice = mean(price))%>%
  ggplot(aes(x = cut, y = meanprice)) + geom_bar(stat = "identity")

d4 <- d %>%
  dplyr::select(cut,price)%>%
  dplyr::group_by(cut)%>%
  dplyr::summarise(meanprice = mean(price), n = n())%>%
  dplyr::relocate(n, .after = cut)
view(d4)

d5 <- d %>%
  dplyr::select(cut,price)%>%
  dplyr::group_by(cut)%>%
  arr
  dplyr::summarise(min_price = min(price),
                   max_price = max(price),
                   median = median(price),
                   q1 = quantile(price, c(0.25)),
                   q2_median = quantile(price, c(0.5)),
                   q3 = quantile(price, c(0.75)))
view(d5)

d6 <- d %>%
  dplyr::rowwise()%>%
  dplyr::summarise(mean(c(x,y,z)))

d7 <- d %>%
  dplyr::rowwise()%>%
  dplyr::mutate(Avg_xyz = mean(c(x,y,z)))


datapath <- "/Users/asimjamal/Downloads/"

data1 <- read_csv(str_c(datapath, "data1.csv"))
data1
data2 <- read_csv(str_c(datapath, "data2.csv"))
data2


string <- "string example"
string

substr(string, 2, 7)

nlast <- 3
substr(string, nchar(string) - nlast - 1, nchar(string))

install.packages("stringr")
library("stringr")

str_sub(string, -3, -1)

library(tibble)
reviews <- tribble(
  ~review_id, ~customer_name, ~review_text, ~date,
  1, "Smith, John", "Great product! Arrived on time. Rating: 5 stars.", "2021-07-15",
  2, "Doe, Jane", "Not bad, but could be better. Rating: 3 stars.", "2021-07-16",
  3, "Brown, Bob", "Terrible experience. Rating: 1 star.", "2021-07-17",
  4, "Lee, Alice", "Excellent! Highly recommend. Rating: 5 stars.", "2021-07-18"
)

library(dplyr)
library(stringr)
library(tidyr)

reviews_clean <- reviews %>%
  separate(customer_name, into = c("last_name", "first_name"), sep = ",") %>%
  mutate(
    first_name = str_to_title(first_name),
    last_name = str_to_title(last_name)
  )

rating_clean <- reviews_clean %>%
  mutate(rating = as.numeric(str_extract(review_text, "(?<=Rating: )\\d")))

date_clean <- rating_clean %>%
  mutate(date = as.Date(date))

final_clean <- reviews %>%
  separate(customer_name, into = c("last_name", "first_name"), sep = ",")%>%
  mutate(
    first_name = str_to_title(first_name),
    last_name = str_to_title(last_name)) %>%
  mutate(rating = as.numeric(str_extract(review_text, "(?<=Rating: )\\d")))%>%
  mutate(review_text = str_remove(review_text, "Rating: \\d+ stars?\\.?"))%>%
  mutate(date = as.Date(date))

