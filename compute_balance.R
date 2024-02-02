## compute_balance.R
## read position summary data
## compare with specified targets

library(stringr)
library(tidyverse)
setwd("C:/Users/awilks/Documents/git_repos/diy-robo-advisor")


convert_currency <- function(currency) {
  currency1 <- sub('$','',as.character(currency),fixed=TRUE)
  currency2 <- as.numeric(gsub('\\,','',as.character(currency1))) 
  currency2
}



##
# file names
##

posit_sum_fn <- "Joint_Tenant-Positions-2024-02-02-113935.csv"
tgt_alloc_fn <- "target_allocation.csv"
asset_list_fn <- "asset_list.csv"

##
# read data
##

posit_sum <- read_csv(file.path("./data", posit_sum_fn), skip = 2)
tgt_alloc <- read_csv(file.path(".", tgt_alloc_fn))
asset_list <- read_csv(file.path(".", asset_list_fn))

##
# prep balance comp file
##

actual_alloc_symbols <- posit_sum %>%
  mutate(market_value = convert_currency(`Market Value`)) %>%
  rename(symbol = Symbol) %>%
  filter(!`Security Type` %in% c('Cash and Money Market', '--')) %>%
  full_join(asset_list, by = 'symbol') 

balance_comparison <- actual_alloc_symbols %>%
  group_by(asset_class_detail) %>%
  summarize(actual_value = sum(market_value, na.rm = TRUE)) %>%
  mutate(actual_percent = actual_value / sum(actual_value) * 100) %>%
  left_join(tgt_alloc, by = 'asset_class_detail') %>%
  mutate(imbalance = target_percent - actual_percent)

##
# build_buy_orders.R
##

new_investment <- 1587
increment_onepct <- new_investment / 100

# initialize updating variables at current values

balance_update <- balance_comparison %>%
  mutate(new_value = actual_value,
         new_imbalance = imbalance)

# allocate new investment - hat tip dad for the algo

for(i in 1:100){

  print(paste("Buy Increment", i))

  balance_update <- balance_update %>%
  mutate(new_value = if_else(new_imbalance == max(new_imbalance),
                             new_value + increment_onepct,
                             new_value),
         new_percent = new_value / sum(new_value) * 100,
         new_imbalance = target_percent - new_percent)
}
##
# buy orders
##

# one row for every asset
buy_orders_allassets <- balance_update %>%
  mutate(buy_order = new_value - actual_value) %>%
  left_join(actual_alloc_symbols, by = 'asset_class_detail') %>%
  select(buy_order, symbol, asset_class_detail, expense_ratio, class_priority)

# subset by highest priorty wtihin asset class
buy_orders <- buy_orders_allassets %>% 
  group_by(asset_class_detail) %>%
    slice_min(class_priority, n = 1)

# print total invested
print(paste("Total New Investment:",
            sum(balance_update$new_value) - sum(balance_update$actual_value)))

buy_orders
      
      







