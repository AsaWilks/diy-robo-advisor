fixture <- test_path("fixtures", "Sample-Positions-2026-01-02.csv")
root <- test_path("..", "..")
targets <- read_csv(file.path(root, "target_allocation.csv"), show_col_types = FALSE)
assets <- read_csv(file.path(root, "asset_list.csv"), show_col_types = FALSE)

test_that("parse_currency handles Schwab formats", {
  expect_equal(
    parse_currency(c("$1,234.56", "-$1.23", "($200.00)", "--", "N/A", "0.5%")),
    c(1234.56, -1.23, -200, NA, NA, 0.5)
  )
})

test_that("read_positions separates holdings from cash and totals", {
  positions <- read_positions(fixture)
  expect_equal(positions$cash, 8000)
  expect_setequal(positions$holdings$symbol, c("VTI", "IVE", "IQLT", "CMF"))
  expect_equal(sum(positions$holdings$market_value), 92000)
  expect_equal(positions$holdings$cost_basis[positions$holdings$symbol == "CMF"], 10200)
})

test_that("config files are consistent", {
  expect_silent(validate_config(targets, assets))
})

test_that("legacy funds count toward their sleeve", {
  mapped <- map_holdings(read_positions(fixture)$holdings, assets)
  sleeves <- summarise_sleeves(mapped, targets)
  us <- sleeves$current_value[sleeves$sleeve == "us_stock"]
  developed <- sleeves$current_value[sleeves$sleeve == "intl_developed"]
  expect_equal(us, 62000)
  expect_equal(developed, 20000)
})

test_that("unmapped holdings stop the run", {
  holdings <- tibble(symbol = "XYZ", market_value = 1, price = 1)
  expect_error(map_holdings(holdings, assets), "XYZ")
})

test_that("greedy allocation spends exactly the amount, even with ties", {
  # Two sleeves tied for most underweight used to both receive each step
  added <- allocate_greedy(c(50, 0, 0), c(50, 25, 25), 100, n_steps = 100)
  expect_equal(sum(added), 100)
  expect_lte(abs(added[[2]] - added[[3]]), 1)
})

test_that("greedy allocation levels the gaps", {
  # On a $100k total: emerging is 6.5 points short, munis 5 points short.
  # Levelling $8k leaves both about 1.75 points short.
  added <- allocate_greedy(
    current_value = c(62000, 20000, 0, 10000),
    target_percent = c(59.5, 19, 6.5, 15),
    amount = 8000,
    n_steps = 800
  )
  expect_equal(added[1:2], c(0, 0))
  expect_equal(added[[3]], 4750, tolerance = 50, scale = 1)
  expect_equal(added[[4]], 3250, tolerance = 50, scale = 1)
})

test_that("ineligible sleeves get nothing", {
  added <- allocate_greedy(
    c(0, 0), c(50, 50), 100,
    n_steps = 10,
    eligible = c(FALSE, TRUE)
  )
  expect_equal(added, c(0, 100))
})

test_that("lockouts switch the buy fund to the harvest partner", {
  funds <- choose_buy_funds(assets, lockouts = "VWO")
  expect_equal(funds$buy_symbol[funds$sleeve == "intl_emerging"], "SCHE")
  expect_equal(funds$buy_symbol[funds$sleeve == "us_stock"], "VTI")
  expect_false(any(c("IVE", "IQLT") %in% funds$buy_symbol))
})

test_that("buy plan uses whole shares and stays within the cash", {
  plan <- build_buy_plan(
    read_positions(fixture),
    targets,
    assets,
    prices = c(VWO = 50)
  )
  expect_true(all(plan$orders$shares == round(plan$orders$shares)))
  expect_lte(sum(plan$orders$order_value), 8000)
  expect_gte(plan$leftover, 0)
  expect_lt(plan$leftover, 50)
  expect_setequal(plan$orders$symbol, c("VWO", "CMF"))
})

test_that("missing prices fall back to dollar orders with a warning", {
  expect_warning(
    plan <- build_buy_plan(read_positions(fixture), targets, assets),
    "VWO"
  )
  vwo <- plan$orders[plan$orders$symbol == "VWO", ]
  expect_true(is.na(vwo$shares))
  expect_gt(vwo$buy_dollars, 0)
})

test_that("cash floor and extra cash change the investable amount", {
  positions <- read_positions(fixture)
  plan <- build_buy_plan(
    positions, targets, assets,
    extra_cash = 1000, cash_floor = 3000, prices = c(VWO = 50)
  )
  expect_equal(plan$investable, 6000)
})

test_that("bond trigger fires only past the threshold", {
  sleeves <- tibble(
    asset_type = c("equity", "bond"),
    target_percent = c(85, 15),
    current_value = c(70000, 30000),
    current_percent = c(70, 30)
  )
  quiet <- check_bond_trigger(sleeves, threshold_points = 20, bond_floor = 10000)
  expect_false(quiet$triggered)

  loud <- check_bond_trigger(sleeves, threshold_points = 10, bond_floor = 25000)
  expect_true(loud$triggered)
  # Needs $15k to restore equities but only $5k is above the floor
  expect_equal(loud$suggested_bond_sale, 5000)
})
