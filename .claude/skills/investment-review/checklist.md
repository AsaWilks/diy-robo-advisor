# Investment Review Checklist

## Asset Allocation
- Do the target allocations sum to 100%? Are there rounding issues?
- Is the asset class diversification reasonable (stocks vs bonds, domestic vs international)?
- Are any major asset classes missing that are commonly recommended (e.g., REITs, TIPS, commodities)?
- How does the allocation compare to common benchmarks (e.g., a target-date fund, the Bogleheads three-fund portfolio, endowment-style allocation)?

## Instrument Selection
- Are the selected ETFs/funds appropriate for their asset classes?
- Are expense ratios competitive? Flag any funds with expense ratios above 0.20%
- Are there redundant holdings (multiple funds covering the same market segment)?
- Is the priority system for selecting instruments within an asset class reasonable?

## Rebalancing Algorithm
- Does the greedy allocation algorithm (allocate to highest-imbalance class) produce reasonable results?
- Are there edge cases where the algorithm could behave poorly (e.g., ties in imbalance, very small or very large investment amounts)?
- Does the algorithm handle the case where an asset class has no valid instruments?
- Is the 1% increment approach sufficiently granular, or could it leave significant residual imbalance?

## Theoretical Framework

### Capital Markets Theory (CAPM / Modern Portfolio Theory)
- Is the portfolio on or near the efficient frontier given its asset classes?
- Does the allocation reflect a rational risk-return tradeoff (higher expected return only through higher systematic risk)?
- Is the portfolio adequately diversified to minimize unsystematic risk?
- Does the equity/bond split imply a reasonable position on the Capital Market Line for a personal investor?
- Are there assets that add risk without commensurate expected return?

### Fama-French Factor Exposure
- Does the portfolio tilt toward known return-generating factors (market, size, value)?
- Evaluate small-cap exposure: is there a deliberate size factor tilt, or is it market-cap weighted?
- Evaluate value exposure: do any holdings specifically target value stocks (e.g., VTV, VTWO, AVUV)? Is the value tilt intentional or incidental?
- Consider the international value/size dimensions: do international holdings capture these factors or just broad market beta?
- How does the portfolio's expected factor loading compare to a simple total-market portfolio?
- Are there asset classes or funds that would improve factor diversification?

## Performance Estimation

### Trailing 12-Month Return vs S&P 500
- Using the target allocation weights and each fund's actual trailing 12-month return (look up current data), estimate the weighted portfolio return over the last 12 months.
- Compare to the S&P 500 (SPY) trailing 12-month return over the same period.
- Break down the return attribution: which asset classes contributed positively and which dragged on performance?
- Note any limitations of this estimate (e.g., rebalancing effects, actual vs target weights, timing).

## Risk Considerations
- Is the overall portfolio risk level appropriate for a typical investor? Note any assumptions.
- Are there concentration risks in any single fund or asset class?
- How would this portfolio have performed in recent downturns (qualitative assessment)?
