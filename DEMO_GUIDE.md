# Demo Guide: Claude Code Agents & Workflows

This repository demonstrates a complete Claude Code setup with custom agents and workflows for portfolio backtesting.

## What's Been Implemented

### 1. Custom Agent: `backtest-analyst`

**Location**: [.claude/agents/backtest-analyst.md](.claude/agents/backtest-analyst.md)

A specialized quantitative analyst with:
- Read-only tool access (can't modify allocation files)
- Domain expertise in backtesting and performance metrics
- Structured JSON output (Sharpe ratios, drawdowns, returns)

### 2. Workflow: `backtest-strategy`

**Location**: [.claude/workflows/backtest-strategy.js](.claude/workflows/backtest-strategy.js)

Orchestrates 3 parallel `backtest-analyst` agents to test the rebalancing algorithm against:
- 2008 Financial Crisis (Oct 2007 - Mar 2009)
- 2020 COVID Crash (Feb 2020 - Apr 2020)
- 2022 Rising Rates (Jan 2022 - Oct 2022)

Aggregates results and ranks by risk-adjusted return.

### 3. Skill: `/backtest`

**Location**: [.claude/skills/backtest/SKILL.md](.claude/skills/backtest/SKILL.md)

User-facing slash command that invokes the workflow and formats results.

### 4. Supporting Files

- [util/backtest_helper.R](util/backtest_helper.R) — R functions for calculating performance metrics
- [BACKTEST_EXAMPLE.md](BACKTEST_EXAMPLE.md) — Detailed explanation of the architecture
- [.claude/agents/README.md](.claude/agents/README.md) — Agent documentation
- [.claude/workflows/README.md](.claude/workflows/README.md) — Workflow patterns and best practices

## Demo Flow

### Basic Usage

```bash
# Invoke via skill (simplest)
/backtest

# Or invoke workflow directly
Workflow({ name: 'backtest-strategy' })
```

### Expected Output

```
🔄 Testing rebalancing strategy across 3 historical scenarios...

Phase: Backtest
├─ backtest:2008-financial-crisis ✓
├─ backtest:2020-covid-crash ✓
└─ backtest:2022-rate-hikes ✓

Phase: Compare
└─ Aggregating results from 3 scenarios...

✅ Backtest complete. Results ranked by Sharpe ratio.

Summary Statistics:
┌─────────────────────────────┬────────┐
│ Metric                      │ Value  │
├─────────────────────────────┼────────┤
│ Scenarios tested            │ 3      │
│ Avg annualized return       │ 8.2%   │
│ Avg Sharpe ratio            │ 0.65   │
│ Avg max drawdown            │ -18.3% │
│ Excess vs 60/40 benchmark   │ +1.4%  │
└─────────────────────────────┴────────┘

Scenario Results (ranked by Sharpe):
1. 2020-covid-crash:     Sharpe 0.82, Return 12.1%, Drawdown -15.2%
2. 2022-rate-hikes:      Sharpe 0.61, Return  6.8%, Drawdown -19.8%
3. 2008-financial-crisis: Sharpe 0.51, Return  5.7%, Drawdown -19.9%

Interpretation:
Strategy performed best during rapid crashes (2020) where rebalancing
captured the recovery. Struggled more in prolonged drawdowns (2008).
Consider increasing bond allocation for better downside protection.
```

## Teaching Points for Your Audience

### Why Custom Agents?

**Without custom agent:**
```javascript
// Have to repeat instructions for each scenario
const result1 = await agent("You are a quant analyst. Test 2008 crisis. Calculate Sharpe ratio, drawdown, returns...")
const result2 = await agent("You are a quant analyst. Test 2020 COVID. Calculate Sharpe ratio, drawdown, returns...")
const result3 = await agent("You are a quant analyst. Test 2022 rates. Calculate Sharpe ratio, drawdown, returns...")
```

**With custom agent:**
```javascript
// Instructions baked into agent definition, just vary the scenario
const results = await parallel(
  SCENARIOS.map(s => () => agent(`Test ${s.name}`, { agentType: 'backtest-analyst' }))
)
```

**Benefits:**
- DRY: Don't repeat domain expertise for each call
- Safety: Constrained tool access (read-only)
- Consistency: Same analytical lens across all scenarios
- Reusability: Other workflows can use `backtest-analyst` too

### Why Workflows?

**Without workflow:**
- Run each backtest manually: `/backtest-2008`, `/backtest-2020`, `/backtest-2022`
- Copy results into spreadsheet
- Manually calculate averages and rankings
- 3× the wait time (sequential)

**With workflow:**
- One command: `/backtest`
- Runs in parallel (3 scenarios tested simultaneously)
- Auto-aggregates and ranks results
- Wall-clock time = slowest single scenario, not sum of all 3

### Key Architectural Concepts

1. **Composition over duplication**
   - 1 agent definition × 3 parallel calls > 3 separate skills

2. **Structured output**
   - `schema` parameter forces JSON → no parsing prose for numbers

3. **Parallelism by default**
   - `parallel()` runs agents concurrently (not sequential loops)

4. **Progressive disclosure**
   - Simple: `/backtest` (just works)
   - Intermediate: Read [.claude/workflows/backtest-strategy.js](.claude/workflows/backtest-strategy.js) to see orchestration
   - Advanced: Modify workflow or create your own

5. **Safety through constraints**
   - Agent only has read-only tools → can't accidentally modify `target_allocation.csv`

## Directory Structure

```
.claude/
├── agents/
│   ├── backtest-analyst.md      # Custom agent definition
│   └── README.md                # Agent documentation
├── workflows/
│   ├── backtest-strategy.js     # Multi-scenario backtest workflow
│   └── README.md                # Workflow patterns
├── skills/
│   ├── backtest/
│   │   └── SKILL.md             # /backtest command
│   ├── code-review/             # Existing: formal RAND QA review
│   ├── style-review/            # Existing: tidyverse style check
│   └── investment-review/       # Existing: allocation strategy review
└── rules/
    ├── r-style.md               # Tidyverse style guide
    ├── rand-code-qa.md          # QA policies
    └── code-review-memo-template.md
```

## Live Demo Script

### Part 1: The Problem (2 min)

"I have a portfolio rebalancing algorithm. Before using it with real money, I want to test it against historical crashes. Manually testing each scenario would take hours and the code would be repetitive."

### Part 2: The Solution (3 min)

"I created a **custom agent** called `backtest-analyst` — a specialized quantitative analyst that knows how to backtest strategies. Then I wrote a **workflow** that spawns 3 of these agents in parallel, one for each scenario."

Show:
- [.claude/agents/backtest-analyst.md](.claude/agents/backtest-analyst.md) — Domain expertise, constrained tools
- [.claude/workflows/backtest-strategy.js](.claude/workflows/backtest-strategy.js) — `parallel()` call, schema enforcement

### Part 3: Demo It (3 min)

Run:
```bash
/backtest
```

While it runs, explain:
- "Notice it says 'Phase: Backtest' with 3 agents running"
- "They're testing 2008, 2020, 2022 simultaneously"
- "Each agent returns structured JSON — Sharpe ratios, drawdowns, returns"
- "The workflow aggregates them and ranks by risk-adjusted performance"

Show results when complete.

### Part 4: Extend It (2 min)

"Now that we have the `backtest-analyst` agent, we can use it in other workflows:"

Ideas:
- Test 50 random allocation mixes, use `backtest-analyst` to score each
- Monte Carlo simulation: 1000 scenarios with varying starting conditions
- Optimization: loop until you find the allocation with best Sharpe across all scenarios

"The agent is a reusable building block. Write once, compose into many workflows."

## Advanced: Customization

### Add More Scenarios

Edit [.claude/workflows/backtest-strategy.js](.claude/workflows/backtest-strategy.js):

```javascript
const SCENARIOS = [
  // ... existing scenarios
  {
    name: '2000-dot-com-crash',
    description: 'Dot-com Bubble Burst (Mar 2000 - Oct 2002)',
    start_date: '2000-03-01',
    end_date: '2002-10-31',
  },
]
```

### Pass Custom Scenarios at Runtime

```javascript
Workflow({
  name: 'backtest-strategy',
  args: {
    scenarios: [
      { name: 'my-crash', start: '2015-08-01', end: '2016-02-01' }
    ]
  }
})
```

Then in the workflow script:
```javascript
const SCENARIOS = args?.scenarios || DEFAULT_SCENARIOS
```

### Create a Portfolio Optimizer Workflow

```javascript
// .claude/workflows/optimize-allocation.js
export const meta = {
  name: 'optimize-allocation',
  description: 'Find optimal allocation via parallel backtesting',
  phases: [
    { title: 'Generate', detail: 'Create 50 random allocations' },
    { title: 'Backtest', detail: 'Test each via backtest-analyst' },
    { title: 'Select', detail: 'Pick best Sharpe ratio' },
  ],
}

phase('Generate')
const allocations = generateRandomAllocations(50)

phase('Backtest')
const results = await parallel(
  allocations.map(alloc => () =>
    agent(
      `Backtest this allocation: ${JSON.stringify(alloc)}`,
      { agentType: 'backtest-analyst', schema: BACKTEST_SCHEMA }
    )
  )
)

phase('Select')
const best = results.filter(Boolean).sort((a, b) => b.sharpe_ratio - a.sharpe_ratio)[0]
return best
```

## Cost Estimate

- **Per backtest**: ~30-40k tokens per scenario
- **Full workflow**: 3 scenarios × 35k tokens = ~105k tokens
- **With Sonnet**: ~$0.30 per full backtest run
- **Comparison**: Manual testing (3 separate conversations) would use similar tokens but take 3× longer

## Next Steps

1. **Run it**: Try `/backtest` to see it in action
2. **Read the code**: Check [.claude/workflows/backtest-strategy.js](.claude/workflows/backtest-strategy.js)
3. **Modify it**: Add a 4th scenario (e.g., 2011 EU debt crisis)
4. **Extend it**: Create a new workflow that uses `backtest-analyst` differently

## Questions for Your Audience

- "When would you use a custom agent vs. just calling the Agent tool?"
- "Why use `parallel()` here instead of a for-loop?"
- "How would you add a Monte Carlo simulation workflow?"
- "What other domain-specific agents would be useful? (e.g., `legal-reviewer`, `sql-optimizer`)"

## Resources

- [BACKTEST_EXAMPLE.md](BACKTEST_EXAMPLE.md) — Detailed explanation of the architecture
- [.claude/agents/README.md](.claude/agents/README.md) — Agent best practices
- [.claude/workflows/README.md](.claude/workflows/README.md) — Workflow patterns (fan-out, pipeline, loop-until-dry)
- [Claude Agent SDK Docs](https://docs.anthropic.com/en/agents) — Official documentation
