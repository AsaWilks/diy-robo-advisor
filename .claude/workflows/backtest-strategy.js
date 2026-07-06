// Backtest Strategy Workflow
// Tests the rebalancing algorithm across multiple historical market scenarios

export const meta = {
  name: 'backtest-strategy',
  description: 'Backtest portfolio rebalancing across historical stress scenarios',
  whenToUse: 'When validating allocation strategy robustness against historical crashes, corrections, and regime changes',
  phases: [
    { title: 'Backtest', detail: 'Simulate strategy across historical scenarios', model: 'sonnet' },
    { title: 'Compare', detail: 'Aggregate results and rank by risk-adjusted return' },
  ],
}

// Historical stress scenarios to test
const SCENARIOS = [
  {
    name: '2008-financial-crisis',
    description: '2008 Financial Crisis - peak to trough (Oct 2007 - Mar 2009)',
    start_date: '2007-10-01',
    end_date: '2009-03-31',
  },
  {
    name: '2020-covid-crash',
    description: 'COVID-19 Market Crash (Feb 2020 - Apr 2020)',
    start_date: '2020-02-01',
    end_date: '2020-04-30',
  },
  {
    name: '2022-rate-hikes',
    description: '2022 Rising Rate Environment (Jan 2022 - Oct 2022)',
    start_date: '2022-01-01',
    end_date: '2022-10-31',
  },
]

// Schema for backtest results
const BACKTEST_SCHEMA = {
  type: 'object',
  properties: {
    scenario: { type: 'string' },
    total_return: { type: 'number' },
    annualized_return: { type: 'number' },
    volatility: { type: 'number' },
    sharpe_ratio: { type: 'number' },
    max_drawdown: { type: 'number' },
    benchmark_60_40_return: { type: 'number' },
    benchmark_60_40_sharpe: { type: 'number' },
    excess_return: { type: 'number' },
    data_availability: { type: 'string' },
    notes: { type: 'string' },
  },
  required: [
    'scenario',
    'total_return',
    'annualized_return',
    'sharpe_ratio',
    'max_drawdown',
    'data_availability',
  ],
}

phase('Backtest')
log(`Testing rebalancing strategy across ${SCENARIOS.length} historical scenarios...`)

// Run all scenarios in parallel using the backtest-analyst agent
const results = await parallel(
  SCENARIOS.map(scenario => () =>
    agent(
      `Backtest the portfolio rebalancing strategy during the ${scenario.description}.

Period: ${scenario.start_date} to ${scenario.end_date}

Your task:
1. Fetch or simulate historical returns for the asset classes in target_allocation.csv
2. Apply the rebalancing algorithm from compute_balance.R conceptually (monthly rebalancing)
3. Calculate performance metrics: total return, annualized return, volatility, Sharpe ratio, max drawdown
4. Compare to a 60/40 portfolio (60% stocks, 40% bonds)
5. Return structured results

For simplicity:
- Use broad market proxies (S&P 500 for US stocks, MSCI EAFE for intl stocks, AGG for bonds)
- If exact historical data is unavailable, document this and provide best approximation
- Monthly rebalancing frequency
- 2% risk-free rate for Sharpe calculations

Read compute_balance.R, target_allocation.csv, and asset_list.csv to understand the strategy.`,
      {
        label: `backtest:${scenario.name}`,
        phase: 'Backtest',
        schema: BACKTEST_SCHEMA,
        agentType: 'backtest-analyst',
      }
    )
  )
)

const valid_results = results.filter(Boolean)

if (valid_results.length === 0) {
  log('No backtest results returned. Check agent outputs for errors.')
  return { error: 'All backtests failed' }
}

phase('Compare')
log(`Aggregating results from ${valid_results.length} scenarios...`)

// Sort by Sharpe ratio (risk-adjusted return)
const ranked = valid_results.sort((a, b) => b.sharpe_ratio - a.sharpe_ratio)

// Calculate summary statistics
const avg_return = valid_results.reduce((sum, r) => sum + r.annualized_return, 0) / valid_results.length
const avg_sharpe = valid_results.reduce((sum, r) => sum + r.sharpe_ratio, 0) / valid_results.length
const avg_max_dd = valid_results.reduce((sum, r) => sum + r.max_drawdown, 0) / valid_results.length
const avg_excess = valid_results.reduce((sum, r) => sum + (r.excess_return || 0), 0) / valid_results.length

log('Backtest complete. Results ranked by Sharpe ratio.')

// Return aggregated results
return {
  summary: {
    scenarios_tested: valid_results.length,
    avg_annualized_return: avg_return,
    avg_sharpe_ratio: avg_sharpe,
    avg_max_drawdown: avg_max_dd,
    avg_excess_vs_60_40: avg_excess,
  },
  scenarios: ranked,
  interpretation: valid_results.length === SCENARIOS.length
    ? 'All scenarios completed successfully'
    : `${SCENARIOS.length - valid_results.length} scenarios failed - check data availability`,
}
