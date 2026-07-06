# Claude Code Architecture for DIY Robo-Advisor

This document explains the Claude Code configuration for this project.

## Directory Structure

```
diy-robo-advisor/
├── compute_balance.R              # Main rebalancing algorithm
├── target_allocation.csv          # Target portfolio allocation
├── asset_list.csv                 # Investment instruments
├── util/
│   └── backtest_helper.R          # Performance metrics & simulation functions
├── CLAUDE.md                      # Main project documentation
├── BACKTEST_EXAMPLE.md            # Architecture explanation
├── DEMO_GUIDE.md                  # Presentation guide
└── .claude/
    ├── ARCHITECTURE.md            # This file
    ├── agents/
    │   ├── README.md              # Agent documentation
    │   └── backtest-analyst.md    # Quantitative analyst agent
    ├── workflows/
    │   ├── README.md              # Workflow patterns
    │   └── backtest-strategy.js   # Multi-scenario backtest orchestration
    ├── skills/
    │   ├── backtest/
    │   │   └── SKILL.md           # /backtest command
    │   ├── code-review/
    │   │   ├── SKILL.md           # /code-review command
    │   │   └── memo_template.md
    │   ├── style-review/
    │   │   ├── SKILL.md           # /style-review command
    │   │   └── checklist.md
    │   └── investment-review/
    │       ├── SKILL.md           # /investment-review command
    │       └── checklist.md
    └── rules/
        ├── r-style.md             # Tidyverse style guide (paths: **/*.R)
        ├── rand-code-qa.md        # QA policies
        └── code-review-memo-template.md
```

## Component Interaction

```
User types "/backtest"
       ↓
Skill (.claude/skills/backtest/SKILL.md)
       ↓
Invokes Workflow tool with name: 'backtest-strategy'
       ↓
Workflow (.claude/workflows/backtest-strategy.js)
       ↓
Spawns 3 parallel agents via agent() function
       ↓
Each agent uses agentType: 'backtest-analyst'
       ↓
Agent (.claude/agents/backtest-analyst.md)
       ↓
Uses tools: Read, Bash, Grep, WebFetch (read-only)
       ↓
Returns structured JSON (via schema parameter)
       ↓
Workflow aggregates results & ranks by Sharpe ratio
       ↓
Skill formats output for user
```

## Configuration Layers

### 1. Rules (Always Active)

Located in `.claude/rules/`

- **r-style.md** — Automatically loaded when touching `**/*.R` files
- **rand-code-qa.md** — Always loaded (defines QA standards)
- **code-review-memo-template.md** — Always loaded (defines review format)

Rules are instructions Claude follows automatically. No user invocation needed.

### 2. Skills (User-Invoked)

Located in `.claude/skills/<name>/`

Slash commands that users invoke:
- `/code-review` — Formal RAND QA review
- `/style-review` — Tidyverse style check
- `/investment-review` — Allocation strategy review
- `/backtest` — Multi-scenario backtest

Skills are like macros: they wrap complex workflows into simple commands.

### 3. Agents (Programmatic)

Located in `.claude/agents/`

Custom agent types invoked via workflows or Agent tool:
- `backtest-analyst` — Read-only quantitative analyst

Agents are building blocks. You don't invoke them directly; workflows compose them.

### 4. Workflows (Orchestration)

Located in `.claude/workflows/`

Multi-agent orchestration scripts:
- `backtest-strategy.js` — 3 parallel backtests → aggregate → rank

Workflows coordinate many agents to complete complex tasks.

## When to Use What

| Task | Use |
|---|---|
| One-off backtest | Direct Agent tool call |
| Test 3 scenarios | `/backtest` skill (invokes workflow) |
| Test 50 scenarios | Workflow with `parallel()` |
| Optimize allocation | New workflow using `backtest-analyst` agent |
| Review code | `/code-review` skill |
| Custom analysis | Write a new workflow |

## Further Reading

- [../BACKTEST_EXAMPLE.md](../BACKTEST_EXAMPLE.md) — Detailed architecture explanation
- [../DEMO_GUIDE.md](../DEMO_GUIDE.md) — Presentation guide
- [agents/README.md](agents/README.md) — Agent best practices
- [workflows/README.md](workflows/README.md) — Workflow patterns
