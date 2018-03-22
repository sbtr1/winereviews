library(tidyverse)
library(tm)

#Read csv file:
wine_reviews <- read_csv("wine_reviews.csv")
mywords <- read_csv("topwords.csv")
mywords <- mywords[['word']]
mywords_tbl <- data.frame(mywords)
colnames(mywords_tbl) <- "word"
mywords_tbl$word <- sort(mywords_tbl$word)

#Clean up reviews:
wine_reviews <- subset(wine_reviews, variety!="White")
wine_reviews <- subset(wine_reviews, variety!="Rose")
wine_reviews <- subset(wine_reviews, variety!="Red")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Corvina, Rondinella, Molinara", "Corvina")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Tempranillo Blend", "Tempranillo")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Bordeaux-style Red", "Bordeaux Red")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Bordeaux-style White", "Bordeaux White")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Rhone-style Red", "Rhone Red")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Rhone-style White", "Rhone White")
wine_reviews$variety <- str_replace(wine_reviews$variety, "Champagne Blend", "Champagne")

wine_reviews <- wine_reviews %>%
  add_count(variety) %>%
  filter(n > 320)
country_count <- wine_reviews %>% count(variety, country, sort = FALSE)


#Group by variety:
wine_by_variety <- wine_reviews %>%
  group_by(variety) %>%
  summarise(
    points = mean(points, na.rm=TRUE),
    price = mean(price, na.rm=TRUE),
    n = n()
  )

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
wine_by_variety <- arrange(wine_by_variety, variety)
write.csv(wine_by_variety, "wine_by_variety2.csv", row.names=FALSE)
write.csv(country_count, "country_count.csv", row.names=FALSE)





