# DIY Robo-Advisor

Personal investment portfolio rebalancing tool written in R. Reads brokerage position exports, compares actual allocation against targets, and generates buy orders to rebalance.

## Project Structure

```
compute_balance.R      # Main script: reads positions, computes imbalance, generates buy orders
import_stockdata.R     # Stock data fetching and preprocessing (experimental/ML prep)
asset_list.csv         # Investment instruments with asset classes, expense ratios, priorities
target_allocation.csv  # Target allocation percentages by asset class
data/                  # Brokerage position export CSVs (gitignored)
util/                  # Helper functions (backtesting utilities)
.claude/
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

- R code follows the tidyverse style guide (snake_case, `<-` for assignment, `%>%` pipes)
- Position data files go in `data/` and are not committed to git
- Target allocations are in `target_allocation.csv` at the repo root
- Asset metadata (symbols, classes, expense ratios) is in `asset_list.csv`
- The rebalancing algorithm uses a greedy 1%-increment approach credited to the developer's father
