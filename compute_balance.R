# compute_balance.R
# Payday run: read the latest Schwab positions export, compare sleeves with
# targets, and print whole-share buy orders for the brokerage cash. Run from
# the repository root (open the RStudio project, or `Rscript compute_balance.R`).

source("R/rebalance.R")

# Settings ---------------------------------------------------------------------

# Cash on its way to the brokerage but not yet in the export
extra_cash <- 0

# Brokerage cash to leave uninvested
cash_floor <- 0

# Prices for buy funds you don't hold yet (held funds use the export's price)
prices <- c(VWO = NA_real_)

# Read inputs ------------------------------------------------------------------

if (!file.exists("target_allocation.csv")) {
  cli_abort("Run this script from the repository root.")
}

positions_path <- find_latest_positions("data")
positions <- read_positions(positions_path)
targets <- read_csv("target_allocation.csv", show_col_types = FALSE)
assets <- read_csv("asset_list.csv", show_col_types = FALSE)
lockouts <- read_lockouts("data/wash_sale_lockouts.csv")

# Build and report the plan ----------------------------------------------------

plan <- build_buy_plan(
  positions,
  targets,
  assets,
  extra_cash = extra_cash,
  cash_floor = cash_floor,
  lockouts = lockouts,
  prices = prices[!is.na(prices)]
)

cli_h1("Buy plan from {.file {basename(positions_path)}}")
cli_text("Investable cash: {.val {round(plan$investable, 2)}}")
if (length(lockouts) > 0) {
  cli_text("Locked out today: {.val {lockouts}}")
}
print(plan$orders)
cli_text("Left uninvested: {.val {round(plan$leftover, 2)}}")

cli_h2("Sleeves before and after")
print(plan$sleeves)

if (plan$bond_check$triggered) {
  cli_alert_warning(c(
    "Equities are {round(plan$bond_check$equity_shortfall_points, 1)} points ",
    "below target. Consider selling ",
    "{.val {round(plan$bond_check$suggested_bond_sale)}} of munis into equities."
  ))
}

orders_path <- write_buy_plan(plan)
cli_alert_success("Saved orders to {.path {orders_path}}")
