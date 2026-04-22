---
description: Substantive review of investment allocation strategy, instrument selection, and rebalancing algorithm
---

Review the investment allocation logic and portfolio construction in this repository for substantive correctness.

You are acting as a knowledgeable reviewer of personal investment portfolio management. Review the code and data files for soundness of the investment approach.

## Reference Data

This skill bundles a checklist of review criteria in `checklist.md`. Use it to structure your evaluation.

## Process

1. Read the review checklist bundled with this skill at `.claude/skills/investment-review/checklist.md`.
2. Read `target_allocation.csv` to understand the desired portfolio allocation.
3. Read `asset_list.csv` to understand the available investment instruments.
4. Read `compute_balance.R` to understand the rebalancing algorithm.
5. Evaluate every item in the checklist.

## Output

Produce an **Investment Allocation Review** with these sections:

1. **Portfolio Summary**: Brief description of the allocation strategy
2. **Strengths**: What the portfolio does well
3. **Theoretical Assessment**: Evaluate the portfolio through the lens of Capital Markets Theory (CAPM/MPT) and Fama-French factor exposure. Where does it sit on the efficient frontier? What factor tilts does it have?
4. **Performance Estimate**: Estimate the weighted trailing 12-month return using each fund's actual returns vs the S&P 500. Show a table with per-asset-class attribution.
5. **Concerns**: Substantive issues ranked by importance
6. **Algorithm Assessment**: Whether the rebalancing logic is sound
7. **Recommendations**: Specific, actionable suggestions

Use a professional but accessible tone. This is a personal investment tool, not an institutional product.
