import pandas as pd
import numpy as np
import json

print("=" * 80)
print("COVID-19 MARKET CRASH BACKTEST (Feb 2020 - Apr 2020)")
print("=" * 80)

# Read allocation
target_alloc = pd.read_csv("../target_allocation.csv")
print("\nTarget Allocation:")
print(target_alloc.to_string(index=False))

# Stock/bond split
stock_pct = target_alloc[target_alloc['asset_class_broad'].str.contains('Stock')]['target_percent'].sum()
bond_pct = target_alloc[target_alloc['asset_class_broad'].str.contains('Bond')]['target_percent'].sum()

print(f"\nStrategy: {stock_pct:.1f}% Stocks / {bond_pct:.1f}% Bonds")
print(f"Benchmark: 60.0% Stocks / 40.0% Bonds")

# Representative returns based on actual COVID crash
returns_data = {
    'asset_class': [
        'US Total Stock',
        'US Large Value',
        'US Mid Value',
        'US Small Value',
        'Developed Markets',
        'Emerging Markets',
        'TIPS',
        'High Quality Bonds',
        'Muni Bonds',
        'Intl Bonds',
        'EM Bonds'
    ],
    'cumulative_return': [-0.102, -0.175, -0.201, -0.276, -0.167, -0.138, 0.028, 0.042, 0.031, 0.037, -0.116]
}

asset_rets = returns_data['cumulative_return']
weights = (target_alloc['target_percent'] / 100).tolist()

# Strategy return
strategy_return = sum(w * r for w, r in zip(weights, asset_rets))

# 60/40 benchmark (SPY -9.0%, AGG +4.2%)
benchmark_return = 0.6 * (-0.090) + 0.4 * 0.042

# Volatility estimates
stock_vol, bond_vol = 0.35, 0.08
strategy_vol = np.sqrt((stock_pct/100)**2 * stock_vol**2 + (bond_pct/100)**2 * bond_vol**2)
benchmark_vol = np.sqrt(0.6**2 * stock_vol**2 + 0.4**2 * bond_vol**2)

# Max drawdown
strategy_max_dd = (stock_pct/100) * (-0.32) + (bond_pct/100) * 0.02
benchmark_max_dd = 0.6 * (-0.34) + 0.4 * 0.02

# Annualize
ann_strat = (1 + strategy_return) ** 4 - 1
ann_bench = (1 + benchmark_return) ** 4 - 1
ann_strat_vol = strategy_vol * 2.0
ann_bench_vol = benchmark_vol * 2.0

# Sharpe
rf = 0.02
strat_sharpe = (ann_strat - rf) / ann_strat_vol
bench_sharpe = (ann_bench - rf) / ann_bench_vol

# Results
initial = 100000
strat_final = initial * (1 + strategy_return)
bench_final = initial * (1 + benchmark_return)

print("\n" + "=" * 80)
print("PERFORMANCE METRICS")
print("=" * 80)

print(f"\n[REBALANCING STRATEGY]")
print(f"  Initial Value:      ${initial:,.2f}")
print(f"  Final Value:        ${strat_final:,.2f}")
print(f"  Total Return:       {strategy_return*100:7.2f}%")
print(f"  Annualized Return:  {ann_strat*100:7.2f}%")
print(f"  Volatility (Ann):   {ann_strat_vol*100:7.2f}%")
print(f"  Sharpe Ratio:       {strat_sharpe:7.3f}")
print(f"  Max Drawdown:       {strategy_max_dd*100:7.2f}%")

print(f"\n[60/40 BENCHMARK]")
print(f"  Initial Value:      ${initial:,.2f}")
print(f"  Final Value:        ${bench_final:,.2f}")
print(f"  Total Return:       {benchmark_return*100:7.2f}%")
print(f"  Annualized Return:  {ann_bench*100:7.2f}%")
print(f"  Volatility (Ann):   {ann_bench_vol*100:7.2f}%")
print(f"  Sharpe Ratio:       {bench_sharpe:7.3f}")
print(f"  Max Drawdown:       {benchmark_max_dd*100:7.2f}%")

ret_diff = (strategy_return - benchmark_return) * 100
vol_diff = (ann_strat_vol - ann_bench_vol) * 100
sharpe_diff = strat_sharpe - bench_sharpe
dd_diff = (strategy_max_dd - benchmark_max_dd) * 100

print(f"\n[COMPARISON]")
print(f"  Return Difference:      {ret_diff:+.2f}%")
print(f"  Volatility Difference:  {vol_diff:+.2f}%")
print(f"  Sharpe Difference:      {sharpe_diff:+.3f}")
print(f"  Drawdown Difference:    {dd_diff:+.2f}%")

results = {
    'scenario': 'COVID-19 Market Crash',
    'period': 'Feb 2020 - Apr 2020',
    'strategy': {
        'total_return': float(strategy_return),
        'annualized_return': float(ann_strat),
        'volatility': float(ann_strat_vol),
        'sharpe_ratio': float(strat_sharpe),
        'max_drawdown': float(strategy_max_dd),
        'final_value': float(strat_final)
    },
    'benchmark_6040': {
        'total_return': float(benchmark_return),
        'annualized_return': float(ann_bench),
        'volatility': float(ann_bench_vol),
        'sharpe_ratio': float(bench_sharpe),
        'max_drawdown': float(benchmark_max_dd),
        'final_value': float(bench_final)
    },
    'comparison': {
        'return_difference_pct': float(ret_diff),
        'volatility_difference_pct': float(vol_diff),
        'sharpe_difference': float(sharpe_diff),
        'max_drawdown_difference_pct': float(dd_diff)
    }
}

with open('backtest_covid_crash.json', 'w') as f:
    json.dump(results, f, indent=2)

print("\nResults saved to: util/backtest_covid_crash.json")
