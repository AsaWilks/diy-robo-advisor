# Functions for buy-only rebalancing of the taxable brokerage account.
#
# The flow is: read a Schwab positions export, map each holding to a sleeve,
# measure drift against targets, allocate investable cash to the most
# underweight sleeves, then convert dollars to whole-share orders in each
# sleeve's buy fund. Nothing here places trades.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(purrr)
  library(stringr)
  library(tibble)
  library(cli)
})

# Inputs -----------------------------------------------------------------------

#' Convert Schwab currency strings to numbers
#'
#' Handles "$1,234.56", "-$1.23", "($1.23)", and placeholders such as "--",
#' which become `NA`.
#'
#' @param x A character or numeric vector.
#' @return A numeric vector.
parse_currency <- function(x) {
  if (is.numeric(x)) {
    return(x)
  }
  x <- str_trim(as.character(x))
  negative <- str_detect(x, "^-|^\\(")
  cleaned <- str_remove_all(x, "[$,()%-]")
  cleaned[cleaned %in% c("", "N/A", "NA")] <- NA_character_
  value <- suppressWarnings(as.numeric(cleaned))
  if_else(negative & !is.na(value), -value, value)
}

#' Find the most recent positions export in a directory
#'
#' @param dir Directory holding Schwab position exports.
#' @return The path of the newest file whose name contains "Positions".
find_latest_positions <- function(dir = "data") {
  files <- list.files(dir, pattern = "Positions.*\\.csv$", full.names = TRUE)
  if (length(files) == 0) {
    cli_abort(c(
      "Can't find a positions export.",
      "i" = "Looked for files matching {.val Positions*.csv} in {.path {dir}}."
    ))
  }
  files[which.max(file.mtime(files))]
}

#' Read a Schwab positions export
#'
#' @param path Path to the CSV exported from the Schwab positions page.
#' @return A list with `holdings` (one row per security) and `cash` (the
#'   brokerage cash balance).
read_positions <- function(path) {
  raw <- read_csv(
    path,
    skip = 2,
    col_types = cols(.default = col_character()),
    show_col_types = FALSE
  )

  pick_col <- function(prefix) {
    hit <- names(raw)[str_starts(names(raw), fixed(prefix))]
    if (length(hit) == 0) {
      cli_abort("Can't find a column starting with {.val {prefix}} in {.path {path}}.")
    }
    hit[[1]]
  }

  security_type <- raw[[pick_col("Security Type")]]
  is_cash <- security_type %in% "Cash and Money Market"
  is_total <- security_type %in% "--" | raw[[pick_col("Symbol")]] %in% "Positions Total"

  cash <- sum(parse_currency(raw[[pick_col("Mkt Val")]][is_cash]), na.rm = TRUE)

  holdings <- tibble(
    symbol = raw[[pick_col("Symbol")]],
    quantity = parse_currency(raw[[pick_col("Qty")]]),
    price = parse_currency(raw[[pick_col("Price")]]),
    market_value = parse_currency(raw[[pick_col("Mkt Val")]]),
    cost_basis = parse_currency(raw[[pick_col("Cost Basis")]])
  ) |>
    filter(!is_cash, !is_total, !is.na(symbol))

  list(holdings = holdings, cash = cash)
}

#' Read wash-sale lockouts
#'
#' A lockout stops the rebalancer from buying a fund, for example for 31 days
#' after harvesting a loss in it. The file has columns `symbol` and
#' `locked_until` (YYYY-MM-DD).
#'
#' @param path Path to the lockout file. A missing file means no lockouts.
#' @param as_of Date the run is for.
#' @return A character vector of symbols that can't be bought on `as_of`.
read_lockouts <- function(path = "data/wash_sale_lockouts.csv",
                          as_of = Sys.Date()) {
  if (!file.exists(path)) {
    return(character())
  }
  read_csv(
    path,
    col_types = cols(symbol = col_character(), locked_until = col_date())
  ) |>
    filter(locked_until >= as_of) |>
    pull(symbol)
}

#' Check targets and the fund list for consistency
#'
#' @param targets Target allocation table.
#' @param assets Asset list table.
#' @return `targets`, invisibly. Errors if the inputs disagree.
validate_config <- function(targets, assets) {
  total <- sum(targets$target_percent)
  if (abs(total - 100) > 1e-6) {
    cli_abort("Target percentages must sum to 100, not {total}.")
  }
  no_buy_fund <- setdiff(
    targets$sleeve,
    assets$sleeve[!is.na(assets$buy_priority)]
  )
  if (length(no_buy_fund) > 0) {
    cli_abort("Each sleeve must have a fund with a buy priority: {.val {no_buy_fund}}.")
  }
  unknown <- setdiff(assets$sleeve, targets$sleeve)
  if (length(unknown) > 0) {
    cli_abort("Asset list refers to sleeves with no target: {.val {unknown}}.")
  }
  invisible(targets)
}

# Drift ------------------------------------------------------------------------

#' Attach a sleeve to every holding
#'
#' @param holdings Holdings table from [read_positions()].
#' @param assets Asset list table.
#' @return `holdings` with a `sleeve` column. Errors if any holding has no
#'   sleeve, so a new fund can't silently drop out of the drift calculation.
map_holdings <- function(holdings, assets) {
  mapped <- left_join(
    holdings,
    select(assets, symbol, sleeve),
    by = "symbol"
  )
  unmapped <- mapped$symbol[is.na(mapped$sleeve)]
  if (length(unmapped) > 0) {
    cli_abort(c(
      "Every holding must belong to a sleeve.",
      "x" = "Not in {.file asset_list.csv}: {.val {unmapped}}.",
      "i" = "Add them with a sleeve and a blank buy priority to hold without buying."
    ))
  }
  mapped
}

#' Summarise current value and drift by sleeve
#'
#' @param mapped Holdings with a `sleeve` column.
#' @param targets Target allocation table.
#' @return One row per sleeve with current value and percentage, target
#'   percentage, and `gap_percent` (target minus actual).
summarise_sleeves <- function(mapped, targets) {
  values <- mapped |>
    summarise(current_value = sum(market_value, na.rm = TRUE), .by = sleeve)

  targets |>
    left_join(values, by = "sleeve") |>
    mutate(
      current_value = coalesce(current_value, 0),
      current_percent = percent_of_total(current_value),
      gap_percent = target_percent - current_percent
    )
}

# Allocation -------------------------------------------------------------------

#' Express values as percentages of their total
#'
#' @param x A numeric vector.
#' @return Percentages summing to 100, or zeros when the total is zero.
percent_of_total <- function(x) {
  total <- sum(x)
  if (total <= 0) {
    return(rep(0, length(x)))
  }
  x / total * 100
}

#' Allocate cash to the most underweight sleeves
#'
#' Greedy buy-only allocation (hat tip Dad): split the cash into equal steps
#' and give each step to the sleeve furthest below target, recomputing after
#' every step. Ties go to the first sleeve, so exactly one step is spent per
#' iteration and the total never exceeds `amount`.
#'
#' @param current_value Current value of each sleeve.
#' @param target_percent Target percentage of each sleeve, summing to 100.
#' @param amount Cash to allocate.
#' @param n_steps Number of equal steps.
#' @param eligible Logical vector; sleeves that can't be bought get nothing.
#' @return Dollars to add to each sleeve, summing to `amount`.
allocate_greedy <- function(current_value, target_percent, amount,
                            n_steps = 200,
                            eligible = rep(TRUE, length(current_value))) {
  added <- rep(0, length(current_value))
  if (amount <= 0 || !any(eligible)) {
    return(added)
  }
  step <- amount / n_steps
  for (i in seq_len(n_steps)) {
    gap <- target_percent - percent_of_total(current_value + added)
    gap[!eligible] <- -Inf
    pick <- which.max(gap)
    added[pick] <- added[pick] + step
  }
  added
}

#' Choose the fund to buy in each sleeve
#'
#' Takes the highest-priority fund that isn't locked out. Legacy holdings
#' (blank priority) are never chosen.
#'
#' @param assets Asset list table.
#' @param lockouts Symbols that can't be bought today.
#' @return One row per sleeve with `buy_symbol`.
choose_buy_funds <- function(assets, lockouts = character()) {
  choices <- assets |>
    filter(!is.na(buy_priority), !symbol %in% lockouts) |>
    slice_min(buy_priority, n = 1, with_ties = FALSE, by = sleeve) |>
    select(sleeve, buy_symbol = symbol)

  blocked <- setdiff(unique(assets$sleeve), choices$sleeve)
  if (length(blocked) > 0) {
    cli_warn("Every buy fund is locked out for {.val {blocked}}; nothing will be bought there.")
  }
  choices
}

#' Convert dollar allocations to whole shares
#'
#' Rounds each sleeve down to whole shares, then spends leftover cash one
#' share at a time on the most underweight sleeve it can afford, stopping when
#' no underweight sleeve fits in what's left. Sleeves
#' without a known price keep their dollar amount and get `NA` shares.
#'
#' @param plan Sleeve table with `current_value`, `target_percent`,
#'   `buy_dollars`, and `price`.
#' @param budget Total cash available.
#' @return `plan` with `shares` and `order_value`.
round_to_shares <- function(plan, budget) {
  plan <- plan |>
    mutate(
      shares = if_else(!is.na(price) & price > 0, floor(buy_dollars / price), NA_real_),
      order_value = shares * price
    )

  priced <- !is.na(plan$shares)
  unpriced_spend <- sum(plan$buy_dollars[!priced])
  leftover <- budget - unpriced_spend - sum(plan$order_value[priced])

  repeat {
    new_value <- plan$current_value + coalesce(plan$order_value, plan$buy_dollars)
    gap <- plan$target_percent - percent_of_total(new_value)
    # Leftover cash only tops up underweight sleeves; otherwise it waits for
    # the next run rather than adding to a sleeve that is already over target
    affordable <- priced & gap > 0 & plan$price <= leftover + 1e-9
    if (!any(affordable)) {
      break
    }
    gap[!affordable] <- -Inf
    pick <- which.max(gap)
    plan$shares[pick] <- plan$shares[pick] + 1
    plan$order_value[pick] <- plan$shares[pick] * plan$price[pick]
    leftover <- leftover - plan$price[pick]
  }
  plan
}

#' Check whether a drawdown calls for selling bonds into equities
#'
#' Buy-only rebalancing can't fix a large equity shortfall. When equities are
#' more than `threshold_points` below target, suggest selling bonds down to
#' `bond_floor` dollars, which stays in place as a buffer.
#'
#' @param sleeves Sleeve summary from [summarise_sleeves()].
#' @param threshold_points Equity shortfall, in percentage points, that
#'   triggers the alert.
#' @param bond_floor Minimum bond value to keep.
#' @return A one-row tibble describing the check, including the suggested
#'   bond sale (zero when not triggered).
check_bond_trigger <- function(sleeves, threshold_points = 10,
                               bond_floor = 30000) {
  total <- sum(sleeves$current_value)
  equity <- filter(sleeves, asset_type == "equity")
  bond <- filter(sleeves, asset_type == "bond")

  shortfall_points <- sum(equity$target_percent) - sum(equity$current_percent)
  needed <- total * sum(equity$target_percent) / 100 - sum(equity$current_value)
  available <- max(sum(bond$current_value) - bond_floor, 0)
  triggered <- shortfall_points > threshold_points

  tibble(
    equity_shortfall_points = shortfall_points,
    triggered = triggered,
    suggested_bond_sale = if (triggered) min(needed, available) else 0
  )
}

# Plan -------------------------------------------------------------------------

#' Build a buy plan for one run
#'
#' @param positions Output of [read_positions()].
#' @param targets Target allocation table.
#' @param assets Asset list table.
#' @param extra_cash Cash not yet in the brokerage export but available to
#'   invest, for example a deposit still in transit.
#' @param cash_floor Brokerage cash to leave uninvested.
#' @param lockouts Symbols that can't be bought today.
#' @param prices Named numeric vector of prices for funds not currently held.
#' @param n_steps Steps for [allocate_greedy()].
#' @return A list with `orders`, `sleeves` (drift before and after),
#'   `investable`, `leftover`, and `bond_check`.
build_buy_plan <- function(positions, targets, assets,
                           extra_cash = 0,
                           cash_floor = 0,
                           lockouts = character(),
                           prices = numeric(),
                           n_steps = 200) {
  validate_config(targets, assets)

  mapped <- map_holdings(positions$holdings, assets)
  sleeves <- summarise_sleeves(mapped, targets)
  investable <- max(positions$cash + extra_cash - cash_floor, 0)

  held_prices <- set_names(positions$holdings$price, positions$holdings$symbol)
  all_prices <- c(prices, held_prices[!names(held_prices) %in% names(prices)])

  plan <- sleeves |>
    left_join(choose_buy_funds(assets, lockouts), by = "sleeve") |>
    mutate(
      buy_dollars = allocate_greedy(
        current_value,
        target_percent,
        investable,
        n_steps = n_steps,
        eligible = !is.na(buy_symbol)
      ),
      price = unname(all_prices[buy_symbol])
    ) |>
    round_to_shares(budget = investable)

  orders <- plan |>
    filter(
      !is.na(buy_symbol),
      (!is.na(shares) & shares > 0) | (is.na(shares) & buy_dollars > 0)
    ) |>
    select(sleeve, symbol = buy_symbol, shares, price, order_value, buy_dollars)

  spent <- sum(coalesce(plan$order_value, plan$buy_dollars))
  after <- plan |>
    mutate(
      after_value = current_value + coalesce(order_value, buy_dollars),
      after_percent = percent_of_total(after_value)
    ) |>
    select(
      sleeve,
      sleeve_label,
      target_percent,
      current_value,
      current_percent,
      after_value,
      after_percent
    )

  missing_price <- plan$buy_symbol[plan$buy_dollars > 0 & is.na(plan$price)]
  if (length(missing_price) > 0) {
    cli_warn(c(
      "No price for {.val {missing_price}}; those orders are in dollars only.",
      "i" = "Pass prices with {.code prices = c({missing_price[[1]]} = ...)}."
    ))
  }

  list(
    orders = orders,
    sleeves = after,
    investable = investable,
    leftover = investable - spent,
    bond_check = check_bond_trigger(sleeves)
  )
}

#' Save buy orders to a dated CSV
#'
#' @param plan Output of [build_buy_plan()].
#' @param dir Directory to write into.
#' @param as_of Date used in the file name.
#' @return The file path, invisibly.
write_buy_plan <- function(plan, dir = "output/orders", as_of = Sys.Date()) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(dir, paste0(format(as_of, "%Y-%m-%d"), "-buy-orders.csv"))
  write_csv(plan$orders, path)
  invisible(path)
}
