# Repository Structure

Clean, organized structure for a portfolio rebalancing tool with Claude Code integration.

## Directory Layout

```
diy-robo-advisor/
│
├── Core R Scripts
│   ├── compute_balance.R           # Main rebalancing algorithm
│   └── import_stockdata.R          # Stock data fetching (experimental)
│
├── Configuration Files
│   ├── asset_list.csv              # Investment instruments with metadata
│   └── target_allocation.csv       # Target portfolio allocation percentages
│
├── Data (gitignored)
│   └── data/                       # Brokerage position exports (real account data)
│
├── Helper Functions
│   └── util/
│       └── backtest_helper.R       # Performance metrics & simulation utilities
│
├── Generated Outputs (gitignored)
│   └── output/
│       ├── backtests/              # Backtest results, scripts, intermediate data
│       ├── reports/                # Analysis summaries and visualizations
│       └── README.md               # Output directory documentation
│
├── Claude Code Configuration
│   └── .claude/
│       ├── agents/                 # Custom agent definitions
│       │   ├── backtest-analyst.md # Quantitative analyst agent
│       │   └── README.md
│       ├── workflows/              # Multi-agent orchestration scripts
│       │   ├── backtest-strategy.js
│       │   └── README.md
│       ├── skills/                 # User-invocable slash commands
│       │   ├── backtest/           # /backtest command
│       │   ├── code-review/        # /code-review command
│       │   ├── style-review/       # /style-review command
│       │   └── investment-review/  # /investment-review command
│       ├── rules/                  # Code standards (auto-loaded)
│       │   ├── r-style.md          # Tidyverse style guide
│       │   ├── rand-code-qa.md     # QA policies
│       │   └── code-review-memo-template.md
│       └── ARCHITECTURE.md         # System overview
│
├── Documentation
│   ├── CLAUDE.md                   # Main project documentation
│   ├── STRUCTURE.md                # This file
│   ├── BACKTEST_EXAMPLE.md         # Agent/workflow architecture explanation
│   └── DEMO_GUIDE.md               # Presentation guide
│
└── Legacy/Archive
    └── reviews/                    # Historical code review artifacts
```

## Key Principles

### 1. Separation of Concerns

| Directory | Purpose | Versioned? |
|---|---|---|
| Root | Core logic (R scripts) | ✅ Yes |
| `data/` | Real account data | ❌ No (gitignored) |
| `output/` | Generated artifacts | ❌ No (gitignored) |
| `.claude/` | Claude Code config | ✅ Yes |
| `util/` | Helper functions | ✅ Yes |

### 2. Clean Root Directory

Only essential files at the root:
- Core R scripts
- Configuration CSVs
- Key documentation

Everything else is in subdirectories.

### 3. Gitignore Strategy

**Ignored:**
- `data/` — Contains real account positions (sensitive)
- `output/` — Generated artifacts (reproducible from code)
- Workflow intermediate files

**Committed:**
- All code (R scripts, helper functions)
- Claude Code configuration (`.claude/`)
- Documentation

## Common Operations

### Running a Backtest

```bash
/backtest
```

Outputs go to: `output/backtests/`

### Cleaning Up

```bash
rm -rf output/backtests/* output/reports/*
```

All files in `output/` are safe to delete.

### Adding a New Workflow

1. Create `.claude/workflows/my-workflow.js`
2. Optionally wrap in `.claude/skills/my-skill/SKILL.md`
3. Outputs should go to `output/` subdirectories

## Why This Structure?

### Before Reorganization

```
diy-robo-advisor/
├── compute_balance.R
├── backtest_2008.py              ❌ Clutter
├── backtest_2008_report.md       ❌ Clutter
├── backtest_2008_results.json    ❌ Clutter
├── util/
│   ├── backtest_helper.R
│   ├── backtest_2022.json        ❌ Wrong location
│   └── backtest_covid.json       ❌ Wrong location
└── ...
```

**Problems:**
- Root directory cluttered with generated files
- Workflow outputs mixed with source code
- Hard to distinguish what should be versioned
- Risk of committing sensitive backtest data

### After Reorganization

```
diy-robo-advisor/
├── compute_balance.R             ✅ Core logic
├── util/
│   └── backtest_helper.R         ✅ Helpers
├── output/                       ✅ All outputs organized
│   └── backtests/
│       ├── backtest_2008.py
│       ├── backtest_2008_report.md
│       ├── backtest_2008_results.json
│       ├── backtest_2022.json
│       └── backtest_covid.json
└── ...
```

**Benefits:**
- ✅ Clean root (only source code)
- ✅ Clear ownership (code vs. outputs)
- ✅ Safe gitignore (can't accidentally commit sensitive results)
- ✅ Easy cleanup (`rm -rf output/*`)

## For Presenters

When demoing this repository:

1. **Start with the root** — Show clean structure with only essential files
2. **Show `.claude/`** — Organized configuration (agents, workflows, skills, rules)
3. **Run `/backtest`** — Watch outputs appear in `output/backtests/`
4. **Show `output/README.md`** — Explain that all outputs are gitignored and safe to delete
5. **Emphasize separation** — Code (committed) vs. outputs (ephemeral)

This structure demonstrates professional repo organization that scales as the project grows.
