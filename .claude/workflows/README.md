# Workflows

This directory contains multi-agent workflow scripts that orchestrate complex analysis tasks.

## What Are Workflows?

Workflows are JavaScript scripts that:
- **Fan out work** across many parallel agents
- **Pipeline data** through sequential stages
- **Loop until convergence** (e.g., find bugs until no new ones appear)
- **Aggregate results** from independent analyses

Think of workflows as the "control plane" that coordinates agents.

## Available Workflows

### `backtest-strategy.js`

**Purpose**: Test the portfolio rebalancing algorithm across multiple historical market scenarios

**Phases**:
1. **Backtest** — Spawn 3 parallel `backtest-analyst` agents (2008 crisis, 2020 COVID, 2022 rates)
2. **Compare** — Aggregate results and rank by risk-adjusted return (Sharpe ratio)

**Output**: Summary statistics + scenario-by-scenario results

**Invocation**:
```bash
/backtest                                    # Via skill
Workflow({ name: 'backtest-strategy' })      # Direct call
```

**Cost**: ~100-120k tokens (3 agents × 30-40k tokens each)

## Workflow Anatomy

Every workflow must start with a `meta` export:

```javascript
export const meta = {
  name: 'my-workflow',
  description: 'One-line description for permission dialog',
  phases: [
    { title: 'Phase1', detail: 'What happens in phase 1' },
    { title: 'Phase2', detail: 'What happens in phase 2', model: 'opus' },
  ],
}
```

Then use these hooks in the script body:

### Core Functions

- **`agent(prompt, opts)`** — Spawn a subagent
  ```javascript
  const result = await agent(
    "Find all bugs in auth.js",
    {
      label: 'bug-hunt',           // Display name
      phase: 'Phase1',             // Progress group
      schema: BUG_SCHEMA,          // Force JSON output
      agentType: 'backtest-analyst', // Use custom agent
      model: 'opus',               // Override model
    }
  )
  ```

- **`parallel(thunks)`** — Run tasks concurrently (BARRIER)
  ```javascript
  const results = await parallel([
    () => agent("Task 1"),
    () => agent("Task 2"),
    () => agent("Task 3"),
  ])
  ```

- **`pipeline(items, stage1, stage2, ...)`** — No barriers between stages
  ```javascript
  const results = await pipeline(
    files,
    file => agent(`Analyze ${file}`),
    analysis => agent(`Verify: ${analysis.claim}`)
  )
  // File A can be in stage 2 while File B is still in stage 1
  ```

- **`phase(title)`** — Start a new phase (groups subsequent agents in progress UI)
  ```javascript
  phase('Find')
  // ... spawn finder agents
  phase('Verify')
  // ... spawn verifier agents
  ```

- **`log(message)`** — Emit progress updates to user
  ```javascript
  log(`Found ${bugs.length} bugs, starting verification...`)
  ```

- **`args`** — Input passed from caller
  ```javascript
  // Called as: Workflow({ name: 'my-workflow', args: { depth: 5 } })
  // Access as:
  const depth = args.depth || 3
  ```

- **`budget`** — Token budget management
  ```javascript
  while (budget.remaining() > 50_000) {
    const result = await agent("Find more bugs")
    // ...
  }
  ```

## Patterns

### Fan-Out (Parallel)

Use when you need ALL results before proceeding:

```javascript
const scenarios = ['2008-crisis', '2020-covid', '2022-rates']
const results = await parallel(
  scenarios.map(s => () => agent(`Backtest ${s}`))
)
// Wait for all 3 to complete before aggregating
```

### Pipeline (Streaming)

Use when stage N doesn't need cross-item context:

```javascript
await pipeline(
  files,
  f => agent(`Review ${f}`),        // Stage 1: Review
  r => agent(`Verify ${r.finding}`), // Stage 2: Verify
)
// file1 can be verifying while file2 is still reviewing
```

### Loop Until Dry

Use for unknown-size discovery:

```javascript
const bugs = []
let dry = 0
while (dry < 2) {
  const found = await agent("Find bugs")
  if (!found.length) { dry++; continue }
  dry = 0
  bugs.push(...found)
}
```

### Adversarial Verify

Use to kill plausible-but-wrong findings:

```javascript
const votes = await parallel(
  Array.from({length: 3}, () => () =>
    agent(`Try to refute: ${claim}`, { schema: VERDICT })
  )
)
const survives = votes.filter(v => !v.refuted).length >= 2
```

## Creating New Workflows

1. Create `.claude/workflows/<name>.js`

2. Start with `export const meta = {...}`

3. Use `agent()`, `parallel()`, `pipeline()` to orchestrate

4. Return structured results (not just logs)

5. Test with: `Workflow({ scriptPath: '.claude/workflows/<name>.js' })`

6. Optionally wrap in a skill (`.claude/skills/<name>/SKILL.md`) for easy invocation

## Best Practices

- **Default to pipeline()** — only use `parallel()` barriers when you genuinely need ALL prior results at once
- **Schema everything** — Pass `schema` to `agent()` to get JSON, not prose
- **Label agents** — Use `label` option so you can distinguish them in `/workflows` UI
- **Log sparingly** — One sentence per major milestone, not every sub-step
- **Fail gracefully** — `.filter(Boolean)` after `parallel()` to handle agent failures
- **Document token cost** — Note expected cost in workflow description
- **Resume support** — Avoid `Date.now()` / `Math.random()` (breaks caching)

## Example: Comprehensive Code Review

```javascript
export const meta = {
  name: 'comprehensive-review',
  description: 'Multi-lens code review with adversarial verification',
  phases: [
    { title: 'Find', detail: 'Parallel bug hunters across dimensions' },
    { title: 'Verify', detail: 'Adversarially verify each finding' },
  ],
}

const DIMENSIONS = [
  { key: 'bugs', prompt: 'Find correctness bugs...' },
  { key: 'security', prompt: 'Find security vulnerabilities...' },
  { key: 'perf', prompt: 'Find performance issues...' },
]

phase('Find')
const findings = await parallel(
  DIMENSIONS.map(d => () =>
    agent(d.prompt, { label: `find:${d.key}`, schema: FINDINGS_SCHEMA })
  )
)

phase('Verify')
const verified = await pipeline(
  findings.flatMap(f => f.issues),
  issue => parallel(
    Array.from({length: 3}, () => () =>
      agent(`Refute: ${issue.claim}`, { schema: VERDICT_SCHEMA })
    )
  ).then(votes => ({ issue, confirmed: votes.filter(v => !v.refuted).length >= 2 }))
)

return verified.filter(v => v.confirmed).map(v => v.issue)
```

## Debugging

- **`/workflows`** — See live progress of running workflows
- **Read transcript** — Workflow runs save to session directory with full agent outputs
- **Resume from run ID** — `Workflow({ scriptPath: '...', resumeFromRunId: 'wf_abc123' })` for iterative development
