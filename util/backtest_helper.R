# backtest_helper.R
# Helper functions for backtesting the rebalancing strategy

library(tidyverse)

#' Calculate portfolio performance metrics
#'
#' @param returns A numeric vector of period returns
#' @param periods_per_year Number of periods per year (12 for monthly, 252 for daily)
#' @return A list of performance metrics
calculate_metrics <- function(returns, periods_per_year = 12) {

  # Remove any NA values
  returns <- returns[!is.na(returns)]

  if (length(returns) == 0) {
    return(list(
      total_return = NA,
      annualized_return = NA,
      volatility = NA,
      sharpe_ratio = NA,
      max_drawdown = NA
    ))
  }

  # Total return
  total_return <- prod(1 + returns) - 1

  # Annualized return
  n_periods <- length(returns)
  years <- n_periods / periods_per_year
  annualized_return <- (1 + total_return)^(1 / years) - 1

  # Volatility (annualized)
  volatility <- sd(returns) * sqrt(periods_per_year)

  # Sharpe ratio (assuming 2% risk-free rate)
  risk_free_rate <- 0.02
  sharpe_ratio <- (annualized_return - risk_free_rate) / volatility

  # Max drawdown
  cumulative_returns <- cumprod(1 + returns)
  running_max <- cummax(cumulative_returns)
  drawdown <- (cumulative_returns - running_max) / running_max
  max_drawdown <- min(drawdown)

  list(
    total_return = total_return,
    annualized_return = annualized_return,
    volatility = volatility,
    sharpe_ratio = sharpe_ratio,
    max_drawdown = max_drawdown
  )
}

#' Simulate rebalancing over a time period
#'
#' @param asset_returns A data frame with columns: date, symbol, return
#' @param target_allocation Data frame with asset_class_detail and target_percent
#' @param asset_list Data frame mapping symbols to asset classes
#' @param rebalance_frequency Number of periods between rebalances (e.g., 12 for annual)
#' @return A list with portfolio returns and metrics
simulate_rebalancing <- function(
  asset_returns,
  target_allocation,
  asset_list,
  rebalance_frequency = 12
) {

  # Join asset returns with asset class info
  returns_with_class <- asset_returns %>%
    left_join(asset_list %>% select(symbol, asset_class_detail), by = "symbol")

  # Calculate asset class returns (equal-weight within class for simplicity)
  class_returns <- returns_with_class %>%
    group_by(date, asset_class_detail) %>%
    summarize(return = mean(return, na.rm = TRUE), .groups = "drop") %>%
    arrange(date)

  # Get unique dates
  dates <- sort(unique(class_returns$date))

  # Initialize portfolio
  initial_weights <- target_allocation %>%
    select(asset_class_detail, target_percent) %>%
    mutate(weight = target_percent / 100)

  portfolio_value <- 10000  # Start with $10k
  portfolio_returns <- numeric(length(dates))

  current_weights <- initial_weights

  for (i in seq_along(dates)) {
    # Get returns for this period
    period_returns <- class_returns %>%
      filter(date == dates[i]) %>%
      select(asset_class_detail, return)

    # Calculate portfolio return
    portfolio_return <- current_weights %>%
      left_join(period_returns, by = "asset_class_detail") %>%
      summarize(port_return = sum(weight * return, na.rm = TRUE)) %>%
      pull(port_return)

    portfolio_returns[i] <- portfolio_return
    portfolio_value <- portfolio_value * (1 + portfolio_return)

    # Update weights based on returns
    current_weights <- current_weights %>%
      left_join(period_returns, by = "asset_class_detail") %>%
      mutate(
        new_value = weight * (1 + replace_na(return, 0)),
        weight = new_value / sum(new_value)
      ) %>%
      select(asset_class_detail, weight)

    # Rebalance if needed
    if (i %% rebalance_frequency == 0) {
      current_weights <- initial_weights
    }
  }

  list(
    returns = portfolio_returns,
    dates = dates,
    final_value = portfolio_value
  )
}
