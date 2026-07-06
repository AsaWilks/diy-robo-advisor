# Backtest Report: 2022 Rising Rate Environment

**Scenario:** 2022 Rising Rate Environment  
**Period:** January 2022 - October 2022 (10 months)  
**Analysis Date:** July 6, 2026  
**Analyst:** Backtest Analyst Agent (Claude Sonnet 4.5)

## Executive Summary

The DIY Robo-Advisor portfolio rebalancing strategy was tested against the 2022 rising interest rate environment. The strategy **underperformed** the 60/40 benchmark by **1.41%** during this period.

## Performance Metrics

### DIY Robo-Advisor Strategy

| Metric | Value |
|--------|-------|
| Total Return | -19.23% |
| Annualized Return | -22.61% |
| Volatility (Annualized) | 15.92% |
| Max Drawdown | 22.17% |
| Sharpe Ratio | -1.546 |

### 60/40 Benchmark

| Metric | Value |
|--------|-------|
| Total Return | -17.82% |
| Annualized Return | -20.98% |
| Volatility (Annualized) | 16.14% |
| Max Drawdown | 21.11% |
| Sharpe Ratio | -1.424 |

## Structured Results

```json
{
  "scenario": "2022_rising_rates",
  "period": "2022-01-01 to 2022-10-31",
  "strategy": {
    "total_return": -0.1923,
    "annualized_return": -0.2261,
    "volatility": 0.1592,
    "max_drawdown": 0.2217,
    "sharpe_ratio": -1.546
  },
  "benchmark_60_40": {
    "total_return": -0.1782,
    "annualized_return": -0.2098,
    "volatility": 0.1614,
    "max_drawdown": 0.2111,
    "sharpe_ratio": -1.424
  }
}
```

## Historical Context

The 2022 rising rate environment was characterized by:

- **Federal Reserve Rate Hikes:** The Fed aggressively raised interest rates to combat inflation
- **Bond Market Collapse:** Both stocks and bonds declined simultaneously
- **Inflation Concerns:** CPI peaked above 9% in June 2022
- **Global Uncertainty:** Ukraine conflict, supply chain disruptions, energy crisis

## Analysis

### Why the Strategy Underperformed

1. **Higher International Exposure:** The DIY strategy allocates 28.3% to international stocks vs 0% in 60/40
2. **Emerging Market Exposure:** 11.5% allocation experienced high volatility
3. **International Bond Weakness:** 15.6% allocation performed poorly amid global monetary tightening

### Relative Strengths

1. **Lower Volatility:** Strategy had slightly lower volatility (15.92% vs 16.14%)
2. **Better Diversification:** In normal conditions, international exposure provides risk reduction

## Monthly Performance

| Month | US Stocks | Intl Dev | Intl Emerg | US Bonds | Intl Bonds |
|-------|-----------|----------|------------|----------|------------|
| Jan   | -5.31%    | -4.70%   | 1.81%      | -2.49%   | -1.80%     |
| Feb   | -2.99%    | -2.40%   | 0.65%      | -1.20%   | -0.95%     |
| Mar   | 3.57%     | 0.68%    | 3.20%      | -2.77%   | -2.10%     |
| Apr   | -8.92%    | -6.60%   | -5.65%     | -3.85%   | -3.20%     |
| May   | -0.21%    | -1.45%   | -0.50%     | -0.09%   | 0.25%      |
| Jun   | -8.38%    | -9.20%   | -6.30%     | -1.54%   | -4.80%     |
| Jul   | 9.20%     | 7.65%    | 1.45%      | 2.38%    | 1.80%      |
| Aug   | -4.11%    | -5.67%   | -1.95%     | -2.98%   | -4.10%     |
| Sep   | -9.32%    | -9.58%   | -11.60%    | -4.32%   | -6.55%     |
| Oct   | 8.04%     | 5.58%    | -3.75%     | -1.62%   | 2.85%      |

## Methodology

### Portfolio Construction

**DIY Strategy Allocation:**
- US Stocks: 38.7%
- International Developed: 16.8%
- International Emerging: 11.5%
- US Bonds: 17.4%
- International Bonds: 15.6%

**60/40 Benchmark:**
- US Stocks: 60%
- US Bonds: 40%

### Simulation Details

- Starting Value: $100,000
- Rebalancing: Monthly
- Transaction Costs: Zero (assumed)
- Data Source: Representative ETFs (VTI, VEA, VWO, AGG, BNDX)
- Risk-Free Rate: 2%

### Limitations

1. Monthly returns approximated from representative ETFs
2. Asset class aggregation from target_allocation.csv
3. Zero transaction costs assumed
4. Perfect rebalancing capability assumed
5. No tax considerations

## Conclusions

The DIY Robo-Advisor strategy underperformed the 60/40 benchmark by 1.41% during the 2022 rising rate environment. This is primarily due to higher international exposure during a period when international markets underperformed US markets.

### Key Takeaways

1. **Extreme Scenario:** 2022 was historically unusual with simultaneous stock and bond declines
2. **Diversification Trade-off:** International diversification provided risk reduction (lower volatility) but hurt returns
3. **Long-Term Focus:** Strategy designed for long-term wealth accumulation across multiple market regimes
4. **Risk-Adjusted Performance:** Slightly lower volatility suggests potential benefits in normal conditions

## Files Referenced

- Rebalancing Algorithm: `C:\Users\awilks\Documents\git_repos\diy-robo-advisor\compute_balance.R`
- Target Allocation: `C:\Users\awilks\Documents\git_repos\diy-robo-advisor\target_allocation.csv`
- Asset List: `C:\Users\awilks\Documents\git_repos\diy-robo-advisor\asset_list.csv`
- Backtest Script: `C:\Users\awilks\Documents\git_repos\diy-robo-advisor\util\backtest_2022_rising_rates.R`
