## backtest_2022_rising_rates.R
## Backtest the portfolio rebalancing strategy during 2022 Rising Rate Environment
## Period: January 2022 - October 2022

library(tidyverse)

# Historical monthly returns for 2022 (Jan - Oct)
# Data approximated from representative ETFs: VTI, VEA, VWO, AGG, BNDX
monthly_returns <- tibble(
  month = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"),
  us_stocks = c(-0.0531, -0.0299, 0.0357, -0.0892, -0.0021, -0.0838, 0.0920, -0.0411, -0.0932, 0.0804),
  intl_dev = c(-0.0470, -0.0240, 0.0068, -0.0660, -0.0145, -0.0920, 0.0765, -0.0567, -0.0958, 0.0558),
  intl_emerg = c(0.0181, 0.0065, 0.0320, -0.0565, -0.0050, -0.0630, 0.0145, -0.0195, -0.1160, -0.0375),
  us_bonds = c(-0.0249, -0.0120, -0.0277, -0.0385, -0.0009, -0.0154, 0.0238, -0.0298, -0.0432, -0.0162),
  intl_bonds = c(-0.0180, -0.0095, -0.0210, -0.0320, 0.0025, -0.0480, 0.0180, -0.0410, -0.0655, 0.0285)
)

# Target allocation (aggregated from target_allocation.csv)
target_allocation <- tibble(
  asset_class = c("us_stocks", "intl_dev", "intl_emerg", "us_bonds", "intl_bonds"),
  target_pct = c(38.7, 16.8, 11.5, 17.4, 15.6)
)

calculate_portfolio_performance <- function(returns, allocation, rebalance = TRUE) {
  initial_value <- 100000
  
  # Initialize positions
  positions <- allocation %>%
    mutate(value = initial_value * target_pct / 100) %>%
    select(asset_class, value)
  
  portfolio_values <- c(initial_value)
  monthly_returns_list <- c()
  
  for (i in 1:nrow(returns)) {
    # Apply returns
    positions <- positions %>%
      mutate(value = case_when(
        asset_class == "us_stocks" ~ value * (1 + returns$us_stocks[i]),
        asset_class == "intl_dev" ~ value * (1 + returns$intl_dev[i]),
        asset_class == "intl_emerg" ~ value * (1 + returns$intl_emerg[i]),
        asset_class == "us_bonds" ~ value * (1 + returns$us_bonds[i]),
        asset_class == "intl_bonds" ~ value * (1 + returns$intl_bonds[i])
      ))
    
    # Calculate total value
    total_value <- sum(positions$value)
    portfolio_values <- c(portfolio_values, total_value)
    
    # Calculate monthly return
    monthly_ret <- (total_value - portfolio_values[length(portfolio_values) - 1]) / portfolio_values[length(portfolio_values) - 1]
    monthly_returns_list <- c(monthly_returns_list, monthly_ret)
    
    # Rebalance if specified
    if (rebalance) {
      positions <- allocation %>%
        mutate(value = total_value * target_pct / 100) %>%
        select(asset_class, value)
    }
  }
  
  # Calculate metrics
  total_return <- (portfolio_values[length(portfolio_values)] - initial_value) / initial_value
  annualized_return <- (1 + total_return)^(12 / 10) - 1
  
  monthly_vol <- sd(monthly_returns_list)
  annualized_vol <- monthly_vol * sqrt(12)
  
  # Max drawdown
  running_max <- initial_value
  max_dd <- 0
  for (val in portfolio_values) {
    if (val > running_max) running_max <- val
    dd <- (running_max - val) / running_max
    if (dd > max_dd) max_dd <- dd
  }
  
  # Sharpe ratio
  risk_free_rate <- 0.02
  sharpe_ratio <- (annualized_return - risk_free_rate) / annualized_vol
  
  list(
    total_return = total_return,
    annualized_return = annualized_return,
    volatility = annualized_vol,
    max_drawdown = max_dd,
    sharpe_ratio = sharpe_ratio,
    final_value = portfolio_values[length(portfolio_values)]
  )
}

# Run backtest for target portfolio
cat("================================================================================\n")
cat("BACKTEST ANALYSIS: 2022 Rising Rate Environment\n")
cat("Period: January 2022 - October 2022\n")
cat("================================================================================\n\n")

portfolio_results <- calculate_portfolio_performance(monthly_returns, target_allocation, rebalance = TRUE)

cat("--- Target Portfolio Performance (Monthly Rebalancing) ---\n")
cat(sprintf("Total Return:        %8.2f%%\n", portfolio_results$total_return * 100))
cat(sprintf("Annualized Return:   %8.2f%%\n", portfolio_results$annualized_return * 100))
cat(sprintf("Volatility (Ann.):   %8.2f%%\n", portfolio_results$volatility * 100))
cat(sprintf("Max Drawdown:        %8.2f%%\n", portfolio_results$max_drawdown * 100))
cat(sprintf("Sharpe Ratio:        %8.3f\n", portfolio_results$sharpe_ratio))
cat(sprintf("Final Value:         $%,.2f\n", portfolio_results$final_value))

# Run 60/40 benchmark
benchmark_allocation <- tibble(
  asset_class = c("us_stocks", "intl_dev", "intl_emerg", "us_bonds", "intl_bonds"),
  target_pct = c(60, 0, 0, 40, 0)
)

benchmark_results <- calculate_portfolio_performance(monthly_returns, benchmark_allocation, rebalance = TRUE)

cat("\n--- 60/40 Portfolio Performance (Monthly Rebalancing) ---\n")
cat(sprintf("Total Return:        %8.2f%%\n", benchmark_results$total_return * 100))
cat(sprintf("Annualized Return:   %8.2f%%\n", benchmark_results$annualized_return * 100))
cat(sprintf("Volatility (Ann.):   %8.2f%%\n", benchmark_results$volatility * 100))
cat(sprintf("Max Drawdown:        %8.2f%%\n", benchmark_results$max_drawdown * 100))
cat(sprintf("Sharpe Ratio:        %8.3f\n", benchmark_results$sharpe_ratio))
cat(sprintf("Final Value:         $%,.2f\n", benchmark_results$final_value))

# Comparison
cat("\n================================================================================\n")
cat("COMPARATIVE ANALYSIS\n")
cat("================================================================================\n")
cat(sprintf("Relative Return:     %8.2f%%\n", (portfolio_results$total_return - benchmark_results$total_return) * 100))
cat(sprintf("Relative Volatility: %8.2f%%\n", (portfolio_results$volatility - benchmark_results$volatility) * 100))
cat(sprintf("Relative Sharpe:     %8.3f\n", portfolio_results$sharpe_ratio - benchmark_results$sharpe_ratio))

if (portfolio_results$total_return > benchmark_results$total_return) {
  cat(sprintf("\nThe DIY strategy OUTPERFORMED the 60/40 benchmark by %.2f%%.\n", 
              (portfolio_results$total_return - benchmark_results$total_return) * 100))
} else {
  cat(sprintf("\nThe DIY strategy UNDERPERFORMED the 60/40 benchmark by %.2f%%.\n", 
              (benchmark_results$total_return - portfolio_results$total_return) * 100))
}

cat("\n================================================================================\n")
cat("NOTES AND LIMITATIONS\n")
cat("================================================================================\n")
cat("1. Monthly returns approximated from representative ETFs (VTI, VEA, VWO, AGG, BNDX)\n")
cat("2. Rebalancing assumed monthly with zero transaction costs\n")
cat("3. Asset class groupings aggregate multiple detailed classes from target_allocation.csv\n")
cat("4. Risk-free rate of 2% used for Sharpe ratio calculations\n")
cat("5. 2022 was a historically challenging year with Fed rate hikes and inflation\n")
cat("================================================================================\n")
