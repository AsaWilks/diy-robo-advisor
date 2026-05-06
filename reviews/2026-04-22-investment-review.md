# Investment Allocation Review — 2026-04-22

---

## 1. Portfolio Summary

This is a globally diversified, buy-only rebalancing portfolio with a deliberate value/size factor tilt and a meaningful municipal bond allocation. The equity/bond split is approximately **67% equities / 33% fixed income**. Within equities, roughly 58% is US and 42% is international. Within US equities, roughly 40% of the exposure is in explicit value-tilted funds rather than the broad market. Fixed income is dominated by municipal bonds (11.9% of total portfolio), suggesting optimization for a high marginal tax bracket.

**Target allocation totals exactly 100%.** No rounding error.

| Broad Class | Allocation |
|---|---|
| US Stocks | 38.7% |
| International Stocks | 28.3% |
| US Bonds | 17.4% |
| International Bonds | 15.6% |
| **Total** | **100.0%** |

---

## 2. Strengths

- **Factor-aware construction.** The portfolio doesn't just hold VTI and call it done. It explicitly adds large, mid, and small-cap value tilts (VTV, VOE, VBR), which reflects a deliberate attempt to capture the Fama-French value (HML) and size (SMB) premia. This is intellectually well-grounded.

- **Strong international diversification.** At 28.3% international equity, the portfolio is more internationally diversified than a strict market-cap-weighted portfolio (~63% US as of 2025). This reduces US-specific concentration risk.

- **Excellent expense ratios on most holdings.** The primary instruments (VTI 0.03%, VTV 0.04%, VBR 0.07%, VEA 0.05%, VWO 0.08%) are among the cheapest available ETFs in their categories.

- **Inflation and emerging market bond exposure.** TIPS (STIP/VTIP) and emerging market bonds (VWOB) are often overlooked in personal portfolios. Including them adds real return protection and a meaningful yield premium.

- **Tax-conscious bond selection.** The heavy muni bond weighting (11.9% of portfolio) suggests intentional tax optimization, which can meaningfully improve after-tax returns in high tax brackets.

- **Fallback instruments per asset class.** The `asset_list.csv` includes 2–4 alternatives per class, enabling the rebalancer to use a lower-priority fund if the preferred one isn't held. This is practical and well-structured.

---

## 3. Theoretical Assessment (CAPM / MPT / Fama-French)

### Efficient Frontier Position

At 67% equities, the portfolio sits in the moderate-to-aggressive range of the Capital Market Line — roughly consistent with a 2030–2035 Vanguard target-date fund. Expected return is meaningfully higher than a bond-heavy portfolio, with proportionally higher volatility. The equity/bond split is defensible for an investor with a medium-to-long horizon.

The broad international diversification (US + Developed + Emerging across both equities and bonds) approximates the global market portfolio, which MPT identifies as the theoretically optimal risky portfolio before layering in risk tolerance. This is a significant mark in the portfolio's favor.

### Factor Loadings (Fama-French Three-Factor and Five-Factor)

**Market factor (beta):** Full exposure through diversified equities. ✓

**Size factor (SMB):** Positive tilt. VOE (mid-cap value) and VBR (small-cap value) provide deliberate small-cap exposure. VBR in particular has well-documented small-cap and value exposure. These represent 9.3% of the total portfolio and ~24% of US equity. This is a meaningful tilt, though VBR is cap-weighted within small-cap so the pure size factor loading is moderate rather than strong (compare to AVUV, which is more aggressively factor-weighted).

**Value factor (HML):** Positive tilt. VTV (large-cap value), VOE, and VBR all load on HML. The combined value-tilted exposure is 15.5% of the total portfolio. The value tilt is intentional and meaningful but not extreme.

**Profitability / Investment factors (RMW/CMA):** Not explicitly targeted. VTI and the value funds have incidental exposure, but no quality screen or profitability tilt is built in. This is a reasonable omission for a simple personal portfolio.

**International factors:** VEA and VWO are broad cap-weighted funds — they capture international market beta but not international value or size premia. The Fama-French international factors (particularly international small-cap value) are left on the table. Adding something like AVDV (developed ex-US small-cap value) or similar would improve factor diversification internationally.

**Fixed income factors:** Not applicable in the Fama-French framework, but the inclusion of TIPS, muni bonds, international bonds, and emerging market bonds provides meaningful yield curve and credit spread diversification beyond simple duration exposure.

### Summary Assessment

This portfolio is **above average in theoretical rigor for a personal investor**. Most individual investors hold broad market index funds without any factor awareness. The explicit value and size tilts, combined with global diversification, place this portfolio in the "factor investing / passive plus" category. The efficient frontier position depends on whether the factor premia materialize over the investor's horizon — academically, they are expected to, but realized outcomes vary over medium-term windows.

---

## 4. Performance Estimate (Trailing 12 Months vs S&P 500)

> **Important caveat:** My knowledge extends through approximately August 2025. I cannot provide verified data through April 2026. The figures below are estimates based on approximate fund performance through mid-2025 and should be validated against current data before acting on them. US equities significantly outperformed international and bond markets through early 2025; actual trailing returns to April 2026 may differ substantially.

| Asset Class | Fund | Weight | Est. TTM Return* | Weighted Contribution |
|---|---|---|---|---|
| US Total Stock Market | VTI | 23.2% | ~22% | ~5.1% |
| US Large Cap Value | VTV | 6.2% | ~16% | ~1.0% |
| US Mid Cap Value | VOE | 5.0% | ~13% | ~0.7% |
| US Small Cap Value | VBR | 4.3% | ~12% | ~0.5% |
| Developed Stock Market | VEA | 16.8% | ~10% | ~1.7% |
| Emerging Stock Market | VWO | 11.5% | ~12% | ~1.4% |
| Inflation Protected Bonds | STIP | 2.3% | ~6% | ~0.1% |
| High Quality Bonds | AGG | 3.2% | ~6% | ~0.2% |
| Muni Bonds | VTEC/MUB | 11.9% | ~4% | ~0.5% |
| Developed Bond Market | BNDX | 9.8% | ~6% | ~0.6% |
| Emerging Bond Market | VWOB | 5.8% | ~9% | ~0.5% |
| **Portfolio (est.)** | | **100%** | | **~11–13%** |
| **S&P 500 (SPY, est.)** | | | **~20–22%** | |

*Estimated based on market conditions through mid-2025. Returns are pre-tax; after-tax advantage of muni bonds is not reflected here.

**Attribution summary:**
- US equities (~+7.3%) were the dominant return driver.
- International equities (~+3.1%) contributed meaningfully but lagged the US.
- Fixed income (~+1.9%) was a drag relative to equities, as expected in a risk-on environment.
- The portfolio likely underperformed SPY by approximately 8–10 percentage points on a trailing basis — consistent with its lower equity concentration and international diversification. This is expected and not a structural flaw; it reflects the deliberate tradeoff of lower volatility and broader diversification.

---

## 5. Concerns

**Ranked by importance:**

### 1. Priority ordering is not consistently based on expense ratio

The most important criterion for selecting among equivalent instruments should be expense ratio. Several asset classes deviate from this:

- **Muni Bonds:** MUB (0.07%) is listed at priority 3, but VTEC (0.08%, priority 1) and CMF (0.25%, priority 2) are both higher priority. VTEC and CMF appear to be California-specific funds. If the investor is a California resident, the state tax exemption may justify preferring CA munis — but this logic is not documented anywhere in the code or data files. A non-CA user cloning this repo would get suboptimal instrument selection with no explanation.

- **Small Cap Value:** IWN (0.24%, priority 2) is higher priority than SLYV (0.15%, priority 3). SLYV is cheaper with no obvious qualitative reason to prefer IWN.

- **Mid Cap Value:** IWS (0.23%, priority 2) is higher priority than IJJ (0.18%, priority 3). IJJ is cheaper.

- **Emerging Stock Market:** SPEM (0.07%, priority 3) is cheaper than IEMG (0.09%, priority 2), but has lower priority.

**Recommendation:** Either re-sort by expense ratio where no other criterion applies, or add a `priority_rationale` column to `asset_list.csv` explaining non-expense-ratio rankings (e.g., "CA state tax exempt").

### 2. High muni bond concentration with no documented rationale

Muni bonds are 11.9% of the portfolio — the third-largest single allocation after US Total Market and Developed Stocks, and larger than any individual bond category including investment-grade or TIPS. Municipal bond advantages (tax exemption) are only meaningful in taxable accounts for investors in the 24%+ federal bracket. If any portion of this portfolio is held in tax-advantaged accounts (IRA, 401k), muni bonds provide no benefit there and underperform equivalent taxable bonds on a yield basis.

Additionally, 3 of the 4 muni instruments (VTEC, CMF, TFI) appear to be California-specific, creating geographic concentration within the muni allocation.

### 3. No REIT exposure

Real estate investment trusts are a common component of well-diversified portfolios, recommended by many asset allocation frameworks (Bogleheads, endowment models). REITs have historically provided diversification versus equities, an inflation hedge, and returns driven partly by the illiquidity premium. VNQ (0.12% expense) would be a natural addition. Their absence is not disqualifying but is worth a deliberate decision.

### 4. International equities are broad market only — factor premia not captured

VEA and VWO provide broad cap-weighted international exposure. This captures the international market beta but leaves the international value and small-cap premia uncaptured. Research suggests these premia have been meaningful historically. Options like AVDV (Avantis Developed Markets Small Cap Value, 0.36%) or DGS/FNDE for developed/emerging value would extend the factor tilt globally. This is an enhancement, not a flaw.

### 5. Fixed income duration not documented

The fixed income holdings span a wide duration range — STIP is short-duration TIPS (1–5 years), while BNDX and VWOB hold intermediate-duration bonds. The portfolio's effective duration and interest rate sensitivity are not documented anywhere. For a personal investor managing a specific liability (e.g., retirement in X years), duration matching can be important.

### 6. Expense ratio flags

Per the checklist criterion of flagging funds above 0.20%:

| Fund | Class | Expense Ratio |
|---|---|---|
| CMF | Muni Bonds | 0.25% |
| IWS | US Mid Cap Value | 0.23% |
| TFI | Muni Bonds | 0.23% |
| IWN | US Small Cap Value | 0.24% |
| VWOB | Emerging Bond Market | 0.20% (borderline) |
| EMB | Emerging Bond Market | 0.39% |
| PCY | Emerging Bond Market | 0.50% |

These are all lower-priority fallback instruments, so the investor would only hold them if the preferred fund isn't available. The risk is low in practice, but it's worth confirming the high-priority instruments are actually held.

---

## 6. Algorithm Assessment

The greedy 1%-increment algorithm is **sound in concept and correct for its intended purpose**, with two edge-case issues to address (both flagged in the code review).

**What it does well:**
- Correctly identifies the most underweight asset class at each step and allocates to it, approximating an optimal buy-only rebalancing toward target.
- The 1% increment granularity is sufficient for the investment amounts used. Residual imbalance after 100 steps will be at most ~1% per class (and in practice much less), which is well within normal tracking error for passive index funds.
- The buy-only constraint is appropriate for a taxable account to avoid triggering capital gains.

**Edge case: Ties in imbalance.** If two asset classes have identical `new_imbalance` values, `if_else(new_imbalance == max(new_imbalance), ...)` adds `increment_onepct` to **both** simultaneously. This means the total invested in that iteration is `2 × increment_onepct` instead of one, and the final total invested may exceed `new_investment`. In the common case where ties don't occur or are rare, this is a minor issue. But it should be handled explicitly (e.g., `slice_max` to select one class per iteration).

**Edge case: `slice_min(class_priority, with_ties = TRUE)`.** As noted in the code review, tied priorities produce multiple rows in `buy_orders`, duplicating the dollar amount for that asset class. See Required Modification #2 in the code review memo.

**What it doesn't do (by design, but worth noting):**
- It doesn't account for tax lot selection or wash sales.
- It doesn't convert dollar buy orders to share quantities (requires current prices).
- It doesn't handle the case where a class's buy order is smaller than a single share price (particularly relevant for BNDX at ~$57/share — a $10 buy order can't be fulfilled at full shares).

---

## 7. Recommendations

1. **Document the muni bond geographic concentration.** Add a comment in `compute_balance.R` and/or `asset_list.csv` explaining whether the California-specific muni preference is intentional (CA resident, state tax exemption) and whether any holdings are in tax-advantaged accounts where munis are suboptimal.

2. **Fix the priority ordering inconsistencies** in `asset_list.csv` for Small Cap Value, Mid Cap Value, and Emerging Stock Market where cheaper funds have lower priority than more expensive ones without a documented reason.

3. **Consider adding a REIT allocation** (~5% carved from US Total Market) to improve diversification and capture the real estate/illiquidity premium. VNQ or SCHH are natural candidates.

4. **Extend value/size factor tilt to international equities.** The domestic side is well-constructed with deliberate factor tilts; the international side captures only market beta. AVDV (developed) and a small-cap value EM fund would complete the factor picture globally.

5. **Parameterize and document the new investment amount** (currently hardcoded as `new_investment <- 1128`). Placing it at the top of the script with a comment explaining it is the single most likely manual edit per rebalancing run.

6. **Save the buy orders output to a file.** The current output prints to console and is lost. Saving a datestamped CSV to `reviews/` or an `output/` directory would provide a run history and make it possible to verify that executed trades matched the computed orders.
