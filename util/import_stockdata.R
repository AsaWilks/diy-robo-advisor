library(quantmod)
library(tidyverse)

symbolBasket <- c('VTI', 'SPY')
getSymbols(symbolBasket , src='yahoo')


VTI_weekly <- VTI %>%
  as.data.frame() %>%
  mutate(day_counter = 1:n(),
         week_ind = (day_counter-1) %/% 5) %>%
  group_by(week_ind) %>%
  summarize(avg_close = mean(VTI.Close, na.rm = TRUE),
            max_price = max(VTI.High, na.rm = TRUE),
            min_price = min(VTI.Low, na.rm = TRUE),
            avg_volume = mean(VTI.Volume, na.rm = TRUE),
            avg_adj = mean(VTI.Adjusted, na.rm = TRUE))

VTI_weekly[,-1] <- scale(VTI_weekly[,-1])

trainsize <- nrow(VTI) * 0.8


## create training set looking at the last 52 weeks of data

datalags = 52
train = VTI_weekly[seq(trainsize + datalags), ]
test = VTI_weekly[trainsize + datalags + seq(length(VTI_weekly) - trainsize + datalags), ]
batch.size = 50

x.train = array(data = lag(cbind(train$avg_close, train$avg_volume), datalags)[-(1:datalags), ], dim = c(nrow(train) - datalags, datalags, 2))
y.train = array(data = train$avg_close[-(1:datalags)], dim = c(nrow(train)-datalags, 1))

x.test = array(data = lag(cbind(test$avg_volume, test$avg_close), datalags)[-(1:datalags), ], dim = c(nrow(test) - datalags, datalags, 2))
y.test = array(data = test$avg_close[-(1:datalags)], dim = c(nrow(test) - datalags, 1))


