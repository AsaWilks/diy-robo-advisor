# Code QA Review Memo

## Header Information

| Field | Value |
|---|---|
| **Code Reviewer** | Claude Code (AI-assisted review) |
| **Project Name** | DIY Robo-Advisor |
| **Project PI(s)** | [Repository owner] |
| **Project Code QA Contact(s)** | [Repository owner] |
| **Project RQAM** | [Not applicable — personal project] |
| **Special Code QA Instructions** | None |
| **Time Allocated for Code QA Review** | N/A |
| **How AI Tools Were Used to Create the Code** | This review was conducted by Claude Code as an AI-assisted preliminary code QA review. Per RAND policy, AI tools may not substitute for human review; human sign-off is required before this review is considered complete. |

---

## Description of Code and Data

**Location:** `C:/Users/awilks/Documents/git_repos/diy-robo-advisor/`

**Language and platform:** R (tidyverse ecosystem). No version pinning is present.

**Code organization:**
- `compute_balance.R` — Primary production script. Reads a brokerage position export CSV, compares actual holdings against target allocations, and runs a greedy algorithm to generate buy orders for a specified new investment amount.
- `import_stockdata.R` — Experimental/incomplete script. Fetches historical price data from Yahoo Finance via `quantmod`, aggregates to weekly, scales features, and constructs ML training/test arrays. No model training or output is produced.

**Data organization:**
- `data/` — Gitignored directory holding brokerage position export CSVs (Schwab format)
- `asset_list.csv` — Master list of investment instruments with asset class labels, expense ratios, and class priority rankings
- `target_allocation.csv` — Target percentage allocation by asset class

**Expected outputs:** `compute_balance.R` prints buy orders (a filtered tibble) and a total investment amount to the console. No files are written to disk.

---

## Time Spent on Code QA Review

N/A (AI-assisted review)

---

## Approval and Sign Off

**This is an AI-assisted preliminary review and does not constitute sign-off.** Per RAND Code QA policy, a formal code review must be conducted by a human reviewer who is not the original coder, who must self-attest to having sufficient expertise. The findings in this memo should be addressed by the programmer and verified by a human reviewer before sign-off is granted.

| Field | Value |
|---|---|
| **Sign off statement** | NOT SIGNED OFF — AI-assisted preliminary review only |
| **Name** | Claude Code |
| **Date** | 2026-04-22 |

---

## What Was Reviewed and Not Reviewed

**In scope:**
- Full static analysis of `compute_balance.R` and `import_stockdata.R`
- Logic, join behavior, and algorithm correctness in `compute_balance.R`
- Data flow and indexing logic in `import_stockdata.R`
- Reproducibility concerns: hardcoded paths, hardcoded parameters, undocumented data dependencies
- Dependency on `asset_list.csv` and `target_allocation.csv` (structure inferred from code)

**Out of scope:**
- Code was not executed; no runtime behavior was verified
- Input CSVs in `data/` were not reviewed (gitignored; not present)
- `asset_list.csv` and `target_allocation.csv` contents were not reviewed
- Validation of the investment strategy or target allocations (see `/investment-review`)
- `import_stockdata.R` ML modeling approach (script is incomplete)

---

## How Was the Review Conducted

The reviewer performed a full static read of both R scripts, tracing data flow from file ingestion through transformation and output. Each join, filter, aggregation, and loop was evaluated for correctness against its stated purpose. Reproducibility was assessed by identifying any dependencies on the local environment, hardcoded values, or undocumented assumptions about input data format. The review was not paired with code execution due to the absence of the required input data files.

No iterations with the code author occurred prior to this memo.

---

## Special Considerations and Challenges

- **Code could not be executed.** The `data/` directory is gitignored and the position export CSV referenced in `compute_balance.R` (`Joint_Tenant-Positions-2024-07-10-124320.csv`) was not available. All findings are based on static analysis only. Some issues may only manifest at runtime.
- **`import_stockdata.R` is visibly incomplete.** The script builds ML data arrays but contains no model, no training step, and no output. It is treated here as experimental code and evaluated only for the correctness of the operations it does perform.

---

## Overall Impression

`compute_balance.R` accomplishes its stated purpose in a readable, well-structured way. The core rebalancing logic is sound in concept. However, the script has several reproducibility-breaking issues (hardcoded file path, hardcoded `setwd()`, hardcoded investment amount) that would prevent any other user — or the same user on a different machine — from running it without manual edits. There are also two silent failure modes in the join and filtering logic that could corrupt the buy order output without producing an error.

`import_stockdata.R` contains a significant indexing bug (`nrow(VTI)` used where `nrow(VTI_weekly)` is needed; `length(VTI_weekly)` used where `nrow(VTI_weekly)` is needed) that would produce incorrect or NA-filled training and test sets. The script is experimental and does not produce any output, limiting its current usefulness and making it difficult to verify.

Neither script is reproducible in its current form for a programmer unfamiliar with the project. Adding a `README` with run instructions and data requirements would significantly improve reproducibility.

---

## Areas for Improvement

### Required Modifications

| # | Required Modification | Programmer Comments | Reviewer Approval |
|---|---|---|---|
| 1 | **`compute_balance.R` line 7: Remove hardcoded `setwd()`**. `setwd("C:/Users/awilks/...")` is machine-specific and will error for any other user or machine. Replace with a relative path strategy (e.g., use `here::here()` or instruct users to set working directory externally) and remove the `setwd()` call. | | |
| 2 | **`compute_balance.R` line 90: `slice_min(..., with_ties = TRUE)` may produce duplicate buy orders**. `slice_min(class_priority, n = 1)` keeps all tied rows by default. If two assets share the same `class_priority` within an asset class, both appear in `buy_orders` with the same dollar buy amount, overstating the output. Add `with_ties = FALSE` or document explicitly how ties are expected to be handled. | | |
| 3 | **`import_stockdata.R` line 21: `trainsize` computed from wrong object**. `trainsize <- nrow(VTI) * 0.8` uses the daily-frequency raw XTS object, but the downstream indexing operates on `VTI_weekly` (weekly frequency, ~1/5 as many rows). `trainsize` will be approximately 5× too large, causing the training set index to run past the end of `VTI_weekly` and producing NA-filled rows silently. Change to `train_size <- nrow(VTI_weekly) * 0.8`. | | |
| 4 | **`import_stockdata.R` line 28: `length(VTI_weekly)` returns column count, not row count**. `length()` on a data frame returns the number of columns (6), not rows. `seq(length(VTI_weekly) - trainsize + datalags)` will compute a sequence over a very small or negative number, producing an empty or incorrect test set. Change to `nrow(VTI_weekly)`. | | |
| 5 | **`compute_balance.R` lines 42–49: Unhandled NA asset classes corrupt the rebalancing algorithm**. `full_join(asset_list, by = 'symbol')` retains holdings not present in `asset_list.csv` with NA `asset_class_detail`. These propagate to `balance_comparison` as an NA group with no `target_percent`. On line 71, `max(new_imbalance)` returns NA if any `new_imbalance` values are NA (default `na.rm = FALSE`), causing `if_else(new_imbalance == NA, ...)` to always be NA, which silently prevents any allocation. Use an inner join (or add explicit validation) and stop with an informative error if holdings are missing from `asset_list.csv`. | | |

### Recommended Modifications

| # | Recommended Modification | Programmer Comments | Reviewer Approval |
|---|---|---|---|
| 1 | **`compute_balance.R` line 22: Parameterize the position file name and investment amount**. Both `posit_sum_fn <- "Joint_Tenant-Positions-2024-07-10-124320.csv"` and `new_investment <- 1128` are values that change every rebalancing run and currently require manual edits inside the script. Consider placing these at the top of the script in a clearly labeled "User Parameters" section, or accepting them as command-line arguments. | | |
| 2 | **`compute_balance.R`: Add validation after data import**. There is no check that `posit_sum`, `tgt_alloc`, or `asset_list` loaded successfully or contain expected columns. A `stopifnot()` or `assertthat` check after each `read_csv()` — verifying that required columns (`Symbol`, `Security Type`, `Mkt Val (Market Value)`) exist — would surface data format changes immediately rather than producing cryptic downstream errors. | | |
| 3 | **`compute_balance.R` line 5: Remove unused `library(stringr)`**. `stringr` is loaded but no `stringr` functions are called. This creates a false dependency that may confuse future maintainers. | | |
| 4 | **`compute_balance.R`: Write buy orders to a file rather than printing to console**. The final output (`buy_orders`) is printed to the console with no timestamp or record. Writing to `reviews/` or a `output/` directory with a datestamped filename would preserve a run history and make the output reproducible and auditable. | | |
| 5 | **`import_stockdata.R`: Document the script's status and intended purpose**. The script produces no output and appears incomplete. A comment at the top indicating it is experimental/work-in-progress, what its intended final output is, and whether it is safe to run in the current state would help future maintainers assess it. | | |
| 6 | **Both files: Pin R and package versions**. Neither script documents which version of R or the tidyverse/quantmod packages it was developed with. A `sessionInfo()` snapshot in a comment block, or a `renv.lock` file, would significantly improve long-term reproducibility. | | |
