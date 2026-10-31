# DIY Robo-Advisor

Personal investment portfolio rebalancing tool written in R. Reads brokerage position exports, compares actual allocation against targets, and generates buy orders to rebalance.

## Project Structure

```
compute_balance.R      # Payday run script: settings at top, prints and saves buy orders
R/rebalance.R          # All rebalancing functions (parse, map, drift, allocate, round)
tests/                 # testthat suite; run with `Rscript tests/testthat.R`
  testthat/fixtures/   # Synthetic Schwab export (fake numbers, safe to commit)
asset_list.csv         # Funds: sleeve, buy_priority (1 = primary, 2 = harvest partner,
                       #   blank = legacy hold-only), index family
target_allocation.csv  # Target percentage per sleeve, with asset_type (equity/bond)
data/                  # Position exports and wash_sale_lockouts.csv (gitignored)
util/                  # Backtesting helpers and experimental stock data import
output/                # Generated outputs (gitignored)
  orders/              # Dated buy-order CSVs from each run
  backtests/           # Backtest results, scripts, intermediate data
  reports/             # Summary reports and visualizations
.claude/               # Claude Code configuration
  agents/              # Custom agent definitions
  workflows/           # Multi-agent workflow scripts
  skills/              # Invocable review and analysis workflows
  rules/               # Code standards and QA policies
```

## Rules (Standards)

All code in this repository should conform to these standards, located in `.claude/rules/`. Rules are automatically loaded by Claude Code — the style guide is scoped to `.R` files via `paths:` frontmatter; the others load for every session.

- **R Style**: `.claude/rules/r-style.md` — tidyverse style guide (loaded when touching `**/*.R`)
- **RAND Code QA Policy**: `.claude/rules/rand-code-qa.md` — verification, reproducibility, formal review requirements
- **Code Review Memo Template**: `.claude/rules/code-review-memo-template.md` — required output format for formal code reviews

## Skills

All review workflows are skills in `.claude/skills/<name>/`, each bundling a `SKILL.md` prompt and supporting files (checklists, templates). Invoke with `/<name>`.

| Skill | Model | Purpose | Bundled Files |
|---|---|---|---|
| `/code-review` | Sonnet | Formal RAND Code QA review — produces a review memo | `memo_template.md` |
| `/style-review` | Sonnet | Tidyverse style compliance check with per-file grades | `checklist.md` |
| `/investment-review` | Opus | Substantive review of allocation strategy and algorithm | `checklist.md` |
| `/backtest` | Sonnet | Multi-scenario backtest via parallel agents | Invokes `backtest-strategy` workflow |

To run a full review, invoke all three in sequence: `/style-review`, then `/code-review`, then `/investment-review`.

## Agents

Custom agents in `.claude/agents/<name>.md` provide specialized capabilities that can be composed into workflows.

| Agent | Model | Tools | Purpose |
|---|---|---|---|
| `backtest-analyst` | Sonnet | Read, Bash, Grep, Glob, WebFetch | Quantitative analyst for backtesting strategies across historical scenarios. Returns structured performance metrics (returns, Sharpe, drawdowns). |

Agents are invoked programmatically via the `agent()` function in workflow scripts or through the Agent tool with `agentType` parameter.

## Workflows

Multi-agent workflows in `.claude/workflows/<name>.js` orchestrate complex analysis across many parallel subagents.

| Workflow | Phases | Purpose |
|---|---|---|
| `backtest-strategy` | Backtest → Compare | Tests rebalancing algorithm across 3 historical scenarios (2008 crisis, 2020 COVID, 2022 rates) using parallel backtest-analyst agents. Returns aggregated metrics and scenario rankings. |

Invoke via `/backtest` skill or directly: `Workflow({ name: 'backtest-strategy' })`.

## Conventions

- R code follows the tidyverse style guide (snake_case, `<-` for assignment, base `|>` pipe)
- Position data files go in `data/` and are not committed to git; the run picks the newest `*Positions*.csv`
- Target allocations are in `target_allocation.csv` at the repo root
- Asset metadata (symbols, sleeves, buy priorities) is in `asset_list.csv`
- Every holding must map to a sleeve; an unmapped symbol stops the run rather than silently dropping out of drift
- Legacy low-basis funds (IQLT, IVE) count toward their sleeve but are never bought; new money goes to the primary fund
- Wash-sale lockouts: `data/wash_sale_lockouts.csv` (`symbol,locked_until`) switches a sleeve to its harvest partner
- The rebalancing algorithm is a greedy equal-step approach credited to the developer's father; ties go to one sleeve per step so the total never exceeds the cash
- Orders are whole shares (Schwab doesn't do fractional ETF shares); funds with no price get dollar-only orders and a warning
- The bond-sale check is advisory only: it flags when equities are >10 points below target and suggests selling munis down to a $30k floor
- Tests use a synthetic fixture only; never commit a real export
- Generated outputs (orders, backtest results, reports) go in `output/` and are gitignored
