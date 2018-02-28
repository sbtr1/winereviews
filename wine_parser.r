library(tidyverse)
library(tm)

#Read csv file:
wine_reviews <- read_csv("wine_reviews.csv")
mywords <- read_csv("topwords3.csv")
mywords <- mywords[, -2]
mywords <- mywords[['word']]
mywords_tbl <- data.frame(mywords)
colnames(mywords_tbl) <- "word"
mywords_tbl$word <- sort(mywords_tbl$word)

#Clean up reviews:
wine_reviews <- subset(wine_reviews, variety!="White")
wine_reviews <- subset(wine_reviews, variety!="Red")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Corvina, Rondinella, Molinara", "Corvina")

#Group by variety:
wine_by_variety <- wine_reviews %>%
  group_by(variety) %>%
  summarise(
    points = mean(points, na.rm=TRUE),
    price = mean(price, na.rm=TRUE),
    n = n()
  ) %>%
  filter(n > 360)

#Plot by variety:
ggplot(wine_by_variety, aes(x=price, y=points, label=variety)) +
  geom_point(color='grey50') +
  geom_smooth(method = "loess") +
  #geom_text(aes(label=variety), hjust = 0, nudge_x = 0.6, size=3.5) +
  labs(x = "Price", y = "Avg Rating") +
  ylim(86.5,91)

#Natural language processing to find most common words:
for (my_variety in wine_by_variety$variety) {
  dummyb <- wine_reviews[which(wine_reviews$variety == my_variety), ]
  corpus <- Corpus(VectorSource(dummyb$description)) # create corpus object
  corpus <- tm_map(corpus, tolower) # convert all text to lower case
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  tdm <- TermDocumentMatrix(corpus)
  dummydf <- termFreq(corpus$content, control=list(dictionary = mywords))
  dummydf <- data.frame(dummydf)
  colnames(dummydf) <- my_variety
  dummydf <- as_tibble(rownames_to_column(dummydf, var="word"))
  print(my_variety)
  mywords_tbl <- merge(x = mywords_tbl, y = dummydf, by = "word", all.x = TRUE)
}

mywords_tbl[is.na(mywords_tbl)] <- 0
mywords_tbl <- column_to_rownames(mywords_tbl, var = "word")
mywords <- t(mywords_tbl)
mywords_freq <- 100*mywords/rowSums(mywords)
wine_by_variety <- cbind(wine_by_variety, mywords_freq)

#Clean up workspace:
rm(corpus)
rm(dummyb)
rm(dummydf)
rm(tdm)
rm(my_variety)
rm(mywords)
rm(wine_reviews)
rm(mywords_tbl)
rm(mywords_freq)

#Export to csv file for Processing:
wine_by_variety <- arrange(wine_by_variety, desc(n))
write.csv(wine_by_variety, "wine_by_variety.csv", row.names=FALSE)







#Group by country:
wine_by_country <- wine_reviews %>%
  group_by(country) %>%
  summarise(
    points = mean(points, na.rm=TRUE),
    price = mean(price, na.rm=TRUE),
    n = n()
  ) %>%
  filter(n > 50)


ggplot(wine_by_country, aes(x=price, y=points, label=country)) +
  geom_point(color='red3') +
  geom_smooth(method = "lm") +
  geom_text(aes(label=country), hjust = -0, nudge_x = 0.5, size=3.5) +
  labs(x = "Price", y = "Avg Rating") 



#Group by province:
wine_by_province <- wine_reviews %>%
  group_by(province) %>%
  summarise(
    points = mean(points, na.rm=TRUE),
    price = mean(price, na.rm=TRUE),
    n = n()
  ) %>%
  filter(n > 500)

ggplot(wine_by_province, aes(x=price, y=points, label=province)) +
  geom_point(color='red3') +
  geom_smooth(method = "loess") +
  geom_text(aes(label=province), hjust = -0, nudge_x = 0.5, size=3.5) +
  labs(x = "Price", y = "Avg Rating") 



#Elbow Method for finding the optimal number of clusters
set.seed(123)
# Compute and plot wss for k = 2 to k = 15.
k.max <- 15
data <- wine_by_variety[, c(5:129)]
wss <- sapply(1:k.max, 
              function(k){kmeans(data, k, nstart=50,iter.max = 15 )$tot.withinss})
wss
plot(1:k.max, wss,
     type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares",
     main="Elbow method for K means clustering, Michigan")

#K-means clustering:
wine_by_variety$cluster <- NULL
winecluster<- kmeans(data, 3, nstart = 20)
wine_by_variety <- cbind(wine_by_variety, winecluster$cluster)
names(wine_by_variety)[names(wine_by_variety) == 'winecluster$cluster'] <- 'cluster'

wine_by_variety <- arrange(wine_by_variety, cluster)
wine_by_variety$cluster
wine_by_variety[, c(1,130)]
