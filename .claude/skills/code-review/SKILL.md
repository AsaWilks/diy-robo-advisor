---
description: Formal RAND Code QA review — produces a structured review memo with required and recommended modifications
---

Conduct a formal RAND Code QA review of all R code in this repository.

## Process

1. Read the RAND Code QA policy in `.claude/rules/rand-code-qa.md` to understand the review framework.
2. Read the memo template bundled with this skill at `.claude/skills/code-review/memo_template.md` for the output format.
3. Read every R script in the repository.
4. For each script, evaluate against the RAND QA focus areas:
   - **Verification**: Does the code do what the comments and structure say it does? Are there logic errors, off-by-one mistakes, incorrect joins, or silent failures?
   - **Reproducibility**: Can someone else run this code and get the same results? Are there hardcoded paths, missing dependencies, undocumented data requirements, or environment assumptions?
5. Check for common issues:
   - Data files referenced but not present or not documented
   - Hardcoded values that should be parameters
   - Missing error handling for data import steps
   - Unclear variable names or undocumented transformations
   - Code that produces outputs not matching its stated purpose

## Output

Produce a complete Code QA Review Memo following the bundled template. Fill in all sections with specific findings. For the header, use:
- **Code Reviewer**: Claude Code (AI-assisted review)
- **Project Name**: DIY Robo-Advisor
- **How AI Tools Were Used**: This review was conducted by Claude Code as an AI-assisted code QA review

Classify every finding as either a **Required Modification** (must fix) or **Recommended Modification** (good practice). Be specific — reference file names, line numbers, and the exact issue.

Do NOT sign off on the code. Instead, note in the sign-off section that this is an AI-assisted preliminary review and human sign-off is required per RAND policy.
