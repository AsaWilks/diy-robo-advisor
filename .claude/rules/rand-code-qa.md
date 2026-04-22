# Policies for Code Quality Assurance of RAND Research Products

*Version 1.2*

These policies refer to three types of research products as defined in the Policy for Quality Assurance of RAND Research Products: widespread release final products (e.g., RAND Research Reports or RRs), sponsor-only products (e.g., RAND Project Reports or PRs, Draft Research Reports or DRRs), and widespread release preliminary products (e.g., working papers).

These policies apply to all products in which coding errors in the analysis could negatively impact RAND's reputation.

## 1. Statistical and Analytic Code QA

Statistical and analytic code includes instructions or scripts executed by a computer to produce quantitative outputs, including code written in programming languages such as R, Python, Stata, SAS, and MATLAB, as well as analyses performed using spreadsheets and other interactive software. This includes:

- Code or interactive software used for **data cleaning, wrangling, combining** (merging different data sets), and processing steps to create analytic data sets
- Code or interactive software used on data sets to **conduct analyses**
- Code or interactive software used to **generate outputs** such as tables, figures, dashboards, or other displays of data

### Focus Areas

The policy for this review type is focused on:

- **Verification**: Assessing if the code executes what the documentation and specifications say it should execute
- **Reproducibility**: Assessing if the same results are produced each time the same code is executed

This review type does **not** include validation (assessing if the documentation and specifications meet the needs of the research product) of the statistical/analytic approach, which is assessed as part of other types of QA review (e.g., peer review).

### Division Responsibilities

For projects that involve any substantive statistical and analytic code, divisions should include a **code QA plan** as a component within all projects' QA plans, which ensures that the code is of high quality and the results are reproducible.

### QA Requirements by Product Type

| Product Type | Requirement |
|---|---|
| **Widespread release final products** | Formal code review required as minimum. More intensive methods may be used (independent reviewer, dual reviewers, dual independent coders). |
| **Sponsor-only products** | Appropriate level of code review, which may involve no code review, formal code review, or more intensive QA. |
| **Widespread release preliminary products** | Formal code QA not required, but may be used at division discretion. |

### Formal Code Review Requirements

In formal code review, a code reviewer who is **not the original coder** reviews all the code to verify it is accurate and error-free, and provides signoff documentation. The signoff documentation will include, at minimum:

1. The version and/or location of the code, data, and documentation used by the coder
2. A description of the review, including attempts at reproducing results
3. Self-attestation that the reviewer has sufficient expertise to conduct the code review

### AI Considerations

- Research teams **may use AI-based tools** to help generate code but they **must understand all code** used to generate outputs in research products
- Code reviewers **may use AI-based tools** to generate suggestions and aid in code QA review but **cannot use them as a substitute** for their own review

## 2. Application Code QA

Application code performs specific tasks or functions for end-users, such as interactive toolkits, cooperative tools, or research gaming software. An appropriate level of code review or other QA methods should be informed by the QA Plan Checklist.

## 3. Modeling and Simulation Code QA

Modeling and simulation code creates representations of real-world systems or processes using mathematical and computational models. An appropriate level of code review or other QA methods should be used informed by the QA Plan Checklist.

---

## QA Plan Checklist Considerations

When customizing QA plans, consider:

- Complexity and scope of the codebase
- Visibility and impact of the research product
- Whether code itself is the product (or a component)
- Available expertise for review
- Timeline and resource constraints
