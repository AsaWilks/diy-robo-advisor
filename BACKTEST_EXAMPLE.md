# Backtesting Example: Custom Agents & Workflows

This demonstrates how to extend Claude Code with custom agents and multi-agent workflows.

## The Problem

You have a portfolio rebalancing algorithm in `compute_balance.R`. Before using it with real money, you want to test it against historical market crashes (2008 crisis, 2020 COVID, 2022 rate hikes). Testing each scenario manually would be slow and repetitive.

## The Solution: Custom Agent + Workflow

### 1. **Custom Agent** (`.claude/agents/backtest-analyst.md`)

A specialized "quantitative analyst" agent with:
- **Constrained tools**: Read-only access (Grep, Read, WebFetch) — can't modify code
- **Domain expertise**: System prompt trained on backtesting and performance metrics
- **Structured output**: Returns Sharpe ratios, drawdowns, returns as JSON (not prose)

```yaml
---
name: backtest-analyst
description: Quantitative analyst for backtesting portfolio strategies
model: sonnet
tools: [Read, Bash, Grep, Glob, WebFetch]
---
```

This agent becomes a reusable building block you can call many times with different scenarios.

### 2. **Workflow** (`.claude/workflows/backtest-strategy.js`)

Orchestrates multiple backtest-analyst agents in parallel:

```javascript
const SCENARIOS = [
  { name: '2008-financial-crisis', start: '2007-10-01', end: '2009-03-31' },
  { name: '2020-covid-crash', start: '2020-02-01', end: '2020-04-30' },
  { name: '2022-rate-hikes', start: '2022-01-01', end: '2022-10-31' },
]

// Run all scenarios concurrently
const results = await parallel(
  SCENARIOS.map(scenario => () =>
    agent(
      `Backtest the strategy during ${scenario.description}...`,
      {
        agentType: 'backtest-analyst',
        schema: BACKTEST_SCHEMA,  // Forces structured JSON output
      }
    )
  )
)

// Aggregate and rank by Sharpe ratio
return ranked_results
```

**Key workflow features:**
- `parallel()` runs all 3 agents at once (not sequentially)
- `schema` parameter enforces structured output — no parsing needed
- Results aggregate cleanly across agents
- Wall-clock time = slowest single agent, not sum of all

### 3. **Skill** (`.claude/skills/backtest/SKILL.md`)

Wraps the workflow in a slash command for easy invocation:

```bash
/backtest
```

The skill handles:
- Invoking the workflow
- Formatting results for users
- Interpreting findings (which scenarios were favorable/risky)

## Why This Architecture?

| Approach | When to Use |
|---|---|
| **Skill** | Top-level workflow you invoke directly (`/backtest`) |
| **Agent** | Reusable specialist you'll call many times with varying inputs |
| **Workflow** | Multi-step orchestration (fan-out, aggregate, loop patterns) |

### Skills vs Agents

- **Skills** are for *you* (the user) — they're slash commands
- **Agents** are for *Claude* — they're composable primitives in workflows

You could write 3 separate skills (`/backtest-2008`, `/backtest-2020`, etc.) but that duplicates logic. Better: 1 agent definition, 1 workflow that calls it 3 times in parallel.

## Try It

```bash
# Option 1: Via skill
/backtest

# Option 2: Direct workflow invocation
Workflow({ name: 'backtest-strategy' })

# Option 3: Custom scenarios
Workflow({
  scriptPath: '.claude/workflows/backtest-strategy.js',
  args: {
    scenarios: [
      { name: 'custom-crash', start: '2000-03-01', end: '2002-10-31' }
    ]
  }
})
```

## Expected Output

```
Summary Statistics:
  Scenarios tested:       3
  Avg annualized return:  8.2%
  Avg Sharpe ratio:       0.65
  Avg max drawdown:       -18.3%
  Excess vs 60/40:        +1.4%

Scenario Results (ranked by Sharpe):
1. 2020-covid-crash:     Sharpe 0.82, Return 12.1%, Drawdown -15.2%
2. 2022-rate-hikes:      Sharpe 0.61, Return  6.8%, Drawdown -19.8%
3. 2008-financial-crisis: Sharpe 0.51, Return  5.7%, Drawdown -19.9%

Interpretation: Strategy held up well in rapid crashes (2020) but
struggled in prolonged drawdowns (2008). Consider increasing bond allocation.
```

## Cost Estimate

- 3 scenarios × ~30k tokens per agent = ~90k tokens
- Plus workflow overhead = ~100-120k tokens total
- With Sonnet agents = $0.30-0.36 per run

## Teaching Points for Your Audience

1. **Agent isolation** — The backtest-analyst agent is read-only by design. It can't accidentally modify your portfolio allocation.

2. **Parallel by default** — The workflow uses `parallel()` not sequential loops. All 3 scenarios test simultaneously.

3. **Structured output** — The `schema` parameter forces JSON responses. No regex parsing, no "extract the number from this paragraph" logic.

4. **Composition** — You can call `backtest-analyst` from any workflow, not just this one. Maybe a future workflow tests 50 random allocation mixes — same agent, different caller.

5. **Progressive disclosure** — Start with `/backtest` (simple). Dig into `.claude/workflows/backtest-strategy.js` (advanced). Modify the workflow or create your own (expert).

## Next Steps

- Add more scenarios (dot-com crash, 1987 Black Monday, 2011 EU crisis)
- Create a `portfolio-optimizer` agent that tries different allocations and uses `backtest-analyst` to score each
- Chain workflows: `/investment-review` → `/backtest` → "If max drawdown > 20%, propose allocation tweaks" → `/backtest` again
