---
name: backtest
description: Backtest the portfolio rebalancing strategy across historical market scenarios
model: sonnet
---

# Backtest Portfolio Strategy

Run a comprehensive backtest of the rebalancing algorithm across multiple historical stress scenarios.

## What This Does

This skill invokes the `backtest-strategy` workflow, which:

1. **Spawns parallel backtest-analyst agents** — one for each historical scenario
2. **Tests the rebalancing strategy** from `compute_balance.R` against real market conditions
3. **Calculates performance metrics**: returns, volatility, drawdowns, Sharpe ratios
4. **Compares to a 60/40 benchmark** to assess relative performance
5. **Aggregates results** ranked by risk-adjusted returns

## Scenarios Tested

- **2008 Financial Crisis** (Oct 2007 - Mar 2009): Peak-to-trough of the Great Recession
- **2020 COVID Crash** (Feb 2020 - Apr 2020): Rapid pandemic-driven market collapse and recovery
- **2022 Rising Rates** (Jan 2022 - Oct 2022): Fed rate hikes impacting bonds and growth stocks

## Usage

Invoke this skill with:

```
/backtest
```

Or call the workflow directly with custom scenarios:

```javascript
Workflow({ name: 'backtest-strategy' })
```

## Output

You'll receive:
- **Summary statistics**: Average returns, Sharpe ratios, drawdowns across all scenarios
- **Scenario-by-scenario results**: Detailed metrics for each historical period
- **Benchmark comparison**: How the strategy performed vs. a simple 60/40 portfolio

## When to Use

- After modifying `target_allocation.csv` to test new allocation mixes
- Before implementing the strategy with real money
- To validate robustness across different market regimes
- As part of a comprehensive investment review (after `/investment-review`)

## Requirements

- The backtest uses publicly available market data
- Results are simulations based on historical proxies (e.g., S&P 500 for US stocks)
- Monthly rebalancing frequency is assumed
- All agents run in parallel — this will consume ~100-200k tokens total

---

## Instructions

When this skill is invoked:

1. Call the `Workflow` tool with `name: 'backtest-strategy'`
2. Wait for the workflow to complete (it runs in the background)
3. When results return, format them for the user:
   - Lead with the summary statistics in a table
   - Show scenario results ranked by Sharpe ratio
   - Highlight any scenarios where the strategy underperformed the 60/40 benchmark
   - Note any data availability issues

4. Provide a brief interpretation:
   - Which scenarios favored the strategy?
   - Where did it struggle?
   - Overall assessment: robust or fragile?

Do NOT run the backtests yourself — delegate to the workflow. Your role is to invoke it and interpret the results.
