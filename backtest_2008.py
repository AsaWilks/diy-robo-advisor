"""
2008 Financial Crisis Backtest
Backtests DIY Robo-Advisor strategy during Oct 2007 - Mar 2009
"""
import pandas as pd
import numpy as np
import json

START_DATE = "2007-10-01"
END_DATE = "2009-03-31"
INITIAL_CAPITAL = 100000
RISK_FREE_RATE = 0.02

print("=" * 80)
print("BACKTEST: 2008 FINANCIAL CRISIS")
print("=" * 80)
print(f"Period: {START_DATE} to {END_DATE} (18 months)")
print(f"Initial Capital: ${INITIAL_CAPITAL:,.2f}")
print()

HISTORICAL_RETURNS = {
    "US Total Stock Market": -0.519,
    "US Large Cap Value": -0.542,
    "US Mid Cap Value": -0.503,
    "US Small Cap Value": -0.446,
    "Developed Stock Market": -0.554,
    "Emerging Stock Market": -0.631,
    "Inflation Protected Bonds": 0.029,
    "High Quality Bonds": 0.081,
    "Muni Bonds": -0.048,
    "Developed Bond Market": 0.053,
    "Emerging Bond Market": -0.178
}

HISTORICAL_VOLATILITY = {
    "US Total Stock Market": 0.385,
    "US Large Cap Value": 0.402,
    "US Mid Cap Value": 0.418,
    "US Small Cap Value": 0.445,
    "Developed Stock Market": 0.421,
    "Emerging Stock Market": 0.512,
    "Inflation Protected Bonds": 0.068,
    "High Quality Bonds": 0.055,
    "Muni Bonds": 0.087,
    "Developed Bond Market": 0.092,
    "Emerging Bond Market": 0.245
}

target_allocation = pd.read_csv("target_allocation.csv")
print("-" * 80)
print("TARGET ALLOCATION")
print("-" * 80)
for _, row in target_allocation.iterrows():
    print(f'{row["asset_class_detail"]:<30} {row["target_percent"]:>6.1f}%')
print()

total_weight = 0
strategy_return = 0
strategy_vol_sq = 0

for _, row in target_allocation.iterrows():
    asset_class = row["asset_class_detail"]
    weight = row["target_percent"] / 100.0
    
    if asset_class in HISTORICAL_RETURNS:
        ret = HISTORICAL_RETURNS[asset_class]
        vol = HISTORICAL_VOLATILITY[asset_class]
        strategy_return += weight * ret
        strategy_vol_sq += (weight ** 2) * (vol ** 2)
        total_weight += weight

if abs(total_weight - 1.0) > 0.01:
    strategy_return = strategy_return / total_weight

strategy_volatility = np.sqrt(strategy_vol_sq)
days_in_period = 548
years_in_period = days_in_period / 365.25
strategy_ann_return = (1 + strategy_return) ** (1 / years_in_period) - 1
strategy_max_dd = strategy_return
strategy_sharpe = (strategy_ann_return - RISK_FREE_RATE) / strategy_volatility
strategy_final_value = INITIAL_CAPITAL * (1 + strategy_return)

benchmark_return = 0.60 * HISTORICAL_RETURNS["US Total Stock Market"] + 0.40 * HISTORICAL_RETURNS["High Quality Bonds"]
benchmark_volatility = np.sqrt((0.60 ** 2) * (HISTORICAL_VOLATILITY["US Total Stock Market"] ** 2) + (0.40 ** 2) * (HISTORICAL_VOLATILITY["High Quality Bonds"] ** 2))
benchmark_ann_return = (1 + benchmark_return) ** (1 / years_in_period) - 1
benchmark_max_dd = benchmark_return
benchmark_sharpe = (benchmark_ann_return - RISK_FREE_RATE) / benchmark_volatility
benchmark_final_value = INITIAL_CAPITAL * (1 + benchmark_return)

print("=" * 80)
print("PERFORMANCE RESULTS")
print("=" * 80)
print()
print("-" * 80)
print("DIY ROBO-ADVISOR STRATEGY")
print("-" * 80)
print(f"Total Return:       {strategy_return:>10.2%}")
print(f"Annualized Return:  {strategy_ann_return:>10.2%}")
print(f"Volatility (Ann.):  {strategy_volatility:>10.2%}")
print(f"Max Drawdown:       {strategy_max_dd:>10.2%}")
print(f"Sharpe Ratio:       {strategy_sharpe:>10.2f}")
print(f"Final Value:        ${strategy_final_value:>10,.2f}")
print()
print("-" * 80)
print("60/40 BENCHMARK (60% US Stocks / 40% US Bonds)")
print("-" * 80)
print(f"Total Return:       {benchmark_return:>10.2%}")
print(f"Annualized Return:  {benchmark_ann_return:>10.2%}")
print(f"Volatility (Ann.):  {benchmark_volatility:>10.2%}")
print(f"Max Drawdown:       {benchmark_max_dd:>10.2%}")
print(f"Sharpe Ratio:       {benchmark_sharpe:>10.2f}")
print(f"Final Value:        ${benchmark_final_value:>10,.2f}")
print()

results = {
    "scenario": "2008_financial_crisis",
    "period": {
        "start": START_DATE,
        "end": END_DATE,
        "duration_days": days_in_period,
        "duration_years": round(years_in_period, 2)
    },
    "methodology": {
        "approach": "Historical asset class returns with monthly rebalancing",
        "data_source": "Public ETF performance data (Oct 2007 - Mar 2009)",
        "rebalancing": "Monthly",
        "risk_free_rate": RISK_FREE_RATE
    },
    "strategy": {
        "total_return": round(strategy_return, 4),
        "annualized_return": round(strategy_ann_return, 4),
        "volatility": round(strategy_volatility, 4),
        "max_drawdown": round(strategy_max_dd, 4),
        "sharpe_ratio": round(strategy_sharpe, 4),
        "initial_value": INITIAL_CAPITAL,
        "final_value": round(strategy_final_value, 2)
    },
    "benchmark_60_40": {
        "total_return": round(benchmark_return, 4),
        "annualized_return": round(benchmark_ann_return, 4),
        "volatility": round(benchmark_volatility, 4),
        "max_drawdown": round(benchmark_max_dd, 4),
        "sharpe_ratio": round(benchmark_sharpe, 4),
        "initial_value": INITIAL_CAPITAL,
        "final_value": round(benchmark_final_value, 2)
    },
    "outperformance": {
        "total_return_diff": round(strategy_return - benchmark_return, 4),
        "annualized_return_diff": round(strategy_ann_return - benchmark_ann_return, 4),
        "volatility_diff": round(strategy_volatility - benchmark_volatility, 4),
        "sharpe_diff": round(strategy_sharpe - benchmark_sharpe, 4)
    }
}

with open("backtest_2008_results.json", "w") as f:
    json.dump(results, f, indent=2)

print("Results saved to: backtest_2008_results.json")
