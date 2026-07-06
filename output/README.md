# Output Directory

This directory contains generated artifacts from workflows and analysis runs. **All contents are gitignored** and safe to delete.

## Structure

```
output/
├── backtests/     # Backtest results and intermediate files
│   ├── *.json     # Structured backtest results
│   ├── *.py       # Generated backtest scripts
│   ├── *.md       # Detailed reports
│   └── *.csv      # Intermediate data
└── reports/       # Summary reports and visualizations
    ├── *.md       # Analysis summaries
    ├── *.png      # Charts and graphs
    └── *.html     # Interactive reports
```

## Purpose

### `backtests/`

Contains outputs from the `/backtest` skill and `backtest-strategy` workflow:
- JSON files with performance metrics (Sharpe ratios, drawdowns, returns)
- Python/R scripts generated during analysis
- Intermediate data files used for calculations

Example:
```
backtest_2008_results.json
backtest_2008_report.md
backtest_2008.py
```

### `reports/`

Contains summary reports from review workflows:
- Code review memos (from `/code-review`)
- Style compliance reports (from `/style-review`)
- Investment analysis summaries (from `/investment-review`)

## Cleanup

It's safe to delete everything in this directory at any time. Outputs are regenerated when you re-run workflows.

To clean up:
```bash
rm -rf output/backtests/* output/reports/*
```

## Why Gitignored?

1. **Reproducibility** - Generated outputs should be recreated from source code and data
2. **Sensitivity** - May contain market data or analysis details
3. **Size** - Backtest results can accumulate and bloat the repo
4. **Noise** - Reduces git diff noise from regenerated files

If you want to preserve specific backtest results, copy them to a dedicated `docs/` or `analysis/` directory and commit them explicitly.
