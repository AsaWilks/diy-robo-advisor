# Style Review — 2026-04-22

## compute_balance.R

**Compliant:**
- File name is snake_case and descriptive
- `library()` calls at top of file
- Snake_case for all variable and function names
- `<-` used for all assignments
- Spaces around infix operators (`<-`, `==`, `*`, `-`)
- Space after commas in tidyverse pipe chains
- Pipe chains broken across lines with indented continuations
- Comments use `# ` with a space
- Implicit return in `convert_currency()` (no unnecessary `return()`)

**Violations:**

| Line | Rule | Current Code | Suggested Fix |
|---|---|---|---|
| 11–12 | Spaces after commas; spaces around `=` in named args | `sub('$','',as.character(currency),fixed=TRUE)` | `sub("$", "", as.character(currency), fixed = TRUE)` |
| 11–12 | Double quotes preferred | `'$'`, `''`, `'\\,'` | `"$"`, `""`, `"\\,"` |
| 11–42 and throughout | Use base pipe `\|>` not `%>%` | `%>%` | `\|>` |
| 18–52 and throughout | Non-standard section header format | `##\n# file names\n##` | `# File names -------` |
| 41–42, 48, 84, 87 | Inconsistent quotes (single vs double) | `'Cash and Money Market'`, `'symbol'` | `"Cash and Money Market"`, `"symbol"` |
| 66 | Space before `(` in `for`; space before `{` | `for(i in 1:100){` | `for (i in 1:100) {` |
| 70–75 | Pipe continuation not indented relative to assignment | `balance_update <- balance_update %>%\n  mutate(...)` at same indent level | Indent `mutate(...)` 2 extra spaces |
| 87 | Typo in comment | `# subset by highest priorty wtihin asset class` | `# Subset by highest priority within asset class` |
| 97–106 | Excessive trailing blank lines | 9 blank lines at end of file | Remove trailing blank lines |

**Overall: B-** — Good structure and naming conventions, but consistent use of `%>%` over `|>`, mixed quote styles, and non-standard section headers are notable violations.

---

## import_stockdata.R

**Compliant:**
- `library()` calls at top
- Line breaks after `%>%` with indented continuations in the pipe chain
- Spaces around most infix operators in the pipe chain
- `<-` used for initial assignments (lines 8, 19, 21)

**Violations:**

| Line | Rule | Current Code | Suggested Fix |
|---|---|---|---|
| 4 | snake_case for variable names | `symbolBasket` | `symbol_basket` |
| 5 | Spaces after comma; double quotes; no space before `,` | `getSymbols(symbolBasket , src='yahoo')` | `getSymbols(symbol_basket, src = "yahoo")` |
| 8 | snake_case; no uppercase-prefixed names | `VTI_weekly` | `vti_weekly` |
| Throughout | Use base pipe `\|>` not `%>%` | `%>%` | `\|>` |
| 19 | Space after comma in `[` indexing | `VTI_weekly[,-1]` | `VTI_weekly[, -1]` |
| 21 | `trainsize` — no separator | `trainsize` | `train_size` |
| 24 | Non-standard section header | `## create training set...` | `# Create training set --------` |
| 26–35 | Use `<-` not `=` for assignment | `datalags = 52`, `train = ...`, `batch.size = 50` | `data_lags <- 52`, `train <- ...`, `batch_size <- 50` |
| 26–35 | Use `_` not `.` in names | `x.train`, `y.train`, `x.test`, `y.test`, `batch.size` | `x_train`, `y_train`, `x_test`, `y_test`, `batch_size` |
| 28 | Line exceeds 80 characters | `test = VTI_weekly[trainsize + datalags + seq(...), ]` | Break into multiple lines |
| 31–35 | Lines far exceed 80 characters | `x.train = array(data = lag(cbind(...), ...), dim = c(...))` | Multi-line with one argument per line |
| 32 | Missing space around `-` inside `c()` | `c(nrow(train)-datalags, 1)` | `c(nrow(train) - datalags, 1)` |

**Overall: D+** — Multiple fundamental violations: `=` for assignment throughout the bottom half, dot-separated names, camelCase, extremely long lines, and no section structure. The pipe chain (lines 8–17) is the only well-styled section.

---

## Summary — Top 3 Most Impactful Improvements

1. **Replace `%>%` with `|>`** — Both files use the magrittr pipe throughout. The tidyverse style guide (since R 4.3.0) recommends the base pipe `|>`. A global find-and-replace fixes both files at once.

2. **Use `<-` consistently and fix naming conventions in `import_stockdata.R`** — `import_stockdata.R` switches to `=` for assignment on lines 26–35 and uses dot-separated and camelCase names (`x.train`, `symbolBasket`). Standardizing to `<-` and snake_case is the single biggest style debt in that file.

3. **Standardize to double quotes** — Both files mix single and double quotes. The style guide specifies double quotes as default. Making both files consistently use `"..."` resolves a pervasive inconsistency, particularly in `compute_balance.R`'s function calls and `filter()` arguments.
