# Custom Agents

This directory contains custom agent definitions for specialized tasks.

## What Are Agents?

Agents are reusable AI subagents with:
- **Specific system prompts** defining their role and expertise
- **Constrained tool access** for safety (e.g., read-only for analysts)
- **Structured output schemas** to return data, not prose

Unlike skills (which you invoke directly), agents are *building blocks* that workflows compose together.

## Available Agents

### `backtest-analyst`

**Purpose**: Quantitative analyst for testing portfolio strategies against historical market scenarios

**Model**: Sonnet

**Tools**: Read, Bash, Grep, Glob, WebFetch (read-only)

**Input**: A historical scenario (e.g., "2008 financial crisis") and instructions to test the rebalancing algorithm

**Output**: Structured JSON with performance metrics:
- Total return, annualized return
- Sharpe ratio (risk-adjusted return)
- Max drawdown (worst peak-to-trough decline)
- Volatility
- Benchmark comparison (vs 60/40 portfolio)

**Safety**: Cannot modify code or allocation files. Read-only by design.

**Used By**: `backtest-strategy` workflow

## Creating New Agents

To add a custom agent:

1. Create `.claude/agents/<name>.md` with frontmatter:

```yaml
---
name: my-agent
description: One-line description of what this agent does
model: sonnet  # or opus, haiku
tools:
  - Read
  - Grep
  # ... list allowed tools
---

# System Prompt

Your detailed instructions for the agent's role, constraints, and output format...
```

2. Invoke from a workflow:

```javascript
const result = await agent(
  "Task description...",
  {
    agentType: 'my-agent',
    schema: OUTPUT_SCHEMA,  // Optional: force structured JSON
  }
)
```

3. Or invoke via the Agent tool:

```
Agent({
  description: "One-line task summary",
  prompt: "Detailed instructions...",
  subagent_type: "my-agent"
})
```

## Agent vs Skill vs Workflow

| Concept | What It Is | When to Use |
|---|---|---|
| **Skill** | Slash command (`/backtest`) | User-facing workflows |
| **Agent** | Specialized subagent definition | Reusable building blocks for workflows |
| **Workflow** | Orchestration script (`backtest-strategy.js`) | Multi-step, parallel, or looping logic |

**Example hierarchy**:
```
/backtest (skill)
  └─ invokes backtest-strategy.js (workflow)
      └─ spawns 3x backtest-analyst agents (agent type)
          └─ each agent uses Read, Grep, WebFetch (tools)
```

## Best Practices

- **Constrain tools**: Only grant access to tools the agent needs. Read-only agents shouldn't have Write/Edit.
- **Structured output**: Use `schema` parameter to enforce JSON responses. Avoids parsing prose.
- **Domain expertise**: Write system prompts like you're briefing a specialist colleague.
- **Reusability**: Design agents to be called with *varying inputs*, not hardcoded to one scenario.
- **Safety**: For agents that modify code, consider `isolation: 'worktree'` in workflows.
