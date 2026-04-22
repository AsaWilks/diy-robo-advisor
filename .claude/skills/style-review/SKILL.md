---
description: Tidyverse style compliance check for all R code, producing a per-file graded report
---

Review all R code in this repository for compliance with the tidyverse style guide.

## Reference

This skill bundles a style checklist in `checklist.md`. The full style guide is loaded automatically via `.claude/rules/r-style.md` when R files are in scope.

## Process

1. Read the style checklist bundled with this skill at `.claude/skills/style-review/checklist.md`.
2. Read every R script in the repository.
3. Evaluate each script against every item in the checklist.

## Output

Produce a style compliance report in this format:

### Style Compliance Report

For each R file, list:

**[filename.R]**
- **Compliant**: List style rules the code follows well
- **Violations**: List each violation with the line number, the rule violated, the current code, and the suggested fix
- **Overall**: A letter grade (A through F) for style compliance

End with a **Summary** section that lists the top 3 most impactful style improvements across the whole codebase.
