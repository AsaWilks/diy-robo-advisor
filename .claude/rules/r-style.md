---
paths:
  - "**/*.R"
---

# Files {#sec-files}

## Names

1.  File names should be **machine readable**: avoid spaces, symbols, and special characters. Prefer file names that are all lower case, and never
have names that differ only in their capitalization. Delimit words with `-` or `_`. Use `.R` as the extension of R files.

    ```
    # Good
    fit_models.R
    utility_functions.R
    exploratory-data-analysis.R

    # Bad
    fit models.R
    foo.r
    ExploratoryDataAnalysis.r
    ```

2.  File names should be **human readable**: use file names to describe what's in the file.

    ```
    # good
    report-draft-notes.txt

    # bad
    temp.r
    ```

    Use the same structure for closely related files:

    ```
    # good
    fig-eda.png
    fig-model-3.png

    # bad
    figure eda.PNG
    fig model three.png
    ```

3.  File names should play well with default ordering. If your file names contain dates, use yyyy-mm-dd (ISO8601) format so they sort in chronological order. If your file names include numbers, make sure to pad them with the appropriate number of zeros so that (e.g.) 11 doesn't get sorted before 2. If files should be used in a specific order, put the number at the start, not the end.

    ```
    # good
    01-load-data.R
    02-exploratory-analysis.R
    03-model-approach-1.R
    04-model-approach-2.R
    2025-01-01-report.Rmd
    2025-02-01.report.Rmd

    # bad
    alternative model.R
    code for exploratory analysis.r
    feb 01 report.Rmd
    jan 01 report.Rmd
    model_first_try.R
    run-first.r
    ```

    If you later realise that you've missed some steps, it's tempting to use `02a`,
`02b`, etc. However, I think it's generally better to bite the bullet and
rename all files.

4.  Don't [tempt fate](https://phdcomics.com/comics.php?f=1531) by using "final" or similar words in file names. Instead either rely on Git to track changes over time, or failing that, put the date in the file name.

    ```
    # good
    report-2022-03-20.qmd
    report-2022-04-02.qmd

    # bad
    finalreport.qmd
    FinalReport-2.qmd
    ```

## Organisation

It's hard to describe exactly how you should organise your code across multiple files. I think the best rule of thumb is that if you can give a file a concise name that still evokes its contents, you've arrived at a good organisation. But getting to that point is hard.

## Internal structure

Use commented lines of `-` and `=` to break up your file into easily readable
chunks.

```{r}
# Load data ---------------------------

# Plot data ---------------------------
```

If your script uses add-on packages, load them all at once at the very
beginning of the file. This is more transparent than sprinkling `library()`
calls throughout your code or having hidden dependencies that are loaded in a
startup file, such as `.Rprofile`.
# Syntax

## Object names {#sec-objectnames}

> "There are only two hard things in Computer Science: cache invalidation and
> naming things."
>
> --- Phil Karlton

Variable and function names should use only lowercase letters, numbers, and `_`.
Use underscores (`_`) (so called snake case) to separate words within a name.

```{r}
# Good
day_one
day_1

# Bad
DayOne
dayone
```

Base R uses dots in function names (`contrib.url()`) and class names
(`data.frame`), but it's better to reserve dots exclusively for the S3 object
system. In S3, methods are given the name `function.class`; if you also use
`.` in function and class names, you end up with confusing methods like
`as.data.frame.data.frame()`.

If you find yourself attempting to cram data into variable names (e.g. `model_2018`, `model_2019`, `model_2020`), consider using a list or data frame instead.

Generally, variable names should be nouns and function names should be verbs.
Strive for names that are concise and meaningful (this is not easy!).

```{r}
# Good
day_one

# Bad
first_day_of_the_month
djm1
```

Where possible, avoid re-using names of common functions and variables. This
will cause confusion for the readers of your code.

```{r}
# Bad
T <- FALSE
c <- 10
mean <- function(x) sum(x)
```

## Spacing

### Commas

Always put a space after a comma, never before, just like in regular English.

```{r}
# Good
x[, 1]

# Bad
x[,1]
x[ ,1]
x[ , 1]
```

### Parentheses

Do not put spaces inside or outside parentheses for regular function calls.

```{r}
# Good
mean(x, na.rm = TRUE)

# Bad
mean (x, na.rm = TRUE)
mean( x, na.rm = TRUE )
```

Place a space before and after `()` when used with `if`, `for`, or `while`.

```{r}
# Good
if (debug) {
  show(x)
}

# Bad
if(debug){
  show(x)
}
```

Place a space after `()` used for function arguments:

```{r}
# Good
function(x) {}

# Bad
function (x) {}
function(x){}
```

### Embracing

The embracing operator, `{{ }}`, should always have inner spaces to help emphasise its special behaviour:

```{r}
# Good
max_by <- function(data, var, by) {
  data |>
    group_by({{ by }}) |>
    summarise(maximum = max({{ var }}, na.rm = TRUE))
}

# Bad
max_by <- function(data, var, by) {
  data |>
    group_by({{by}}) |>
    summarise(maximum = max({{var}}, na.rm = TRUE))
}
```


### Infix operators

Most infix operators (`==`, `+`, `-`, `<-`, etc.) should always be surrounded by
spaces:

```{r}
# Good
height <- (feet * 12) + inches
mean(x, na.rm = TRUE)

# Bad
height<-feet*12+inches
mean(x, na.rm=TRUE)
```

There are a few exceptions, which should never be surrounded by spaces:

*   The operators with [high precedence][syntax]: `::`, `:::`, `$`, `@`, `[`,
    `[[`, `^`, unary `-`, unary `+`, and `:`.

    ```{r}
    # Good
    sqrt(x^2 + y^2)
    df$z
    x <- 1:10

    # Bad
    sqrt(x ^ 2 + y ^ 2)
    df $ z
    x <- 1 : 10
    ```

*   Single-sided formulas when the right-hand side is a single identifier.

    ```{r}
    # Good
    ~foo
    tribble(
      ~col1, ~col2,
      "a",   "b"
    )

    # Bad
    ~ foo
    tribble(
      ~ col1, ~ col2,
      "a", "b"
    )
    ```

    Note that single-sided formulas with a complex right-hand side do need a space.

    ```{r}
    # Good
    ~ .x + .y

    # Bad
    ~.x + .y
    ```

*   When used in tidy evaluation `!!` (bang-bang) and `!!!` (bang-bang-bang)
    (because they have precedence equivalent to unary `-`/`+`).

    ```{r}
    # Good
    call(!!xyz)

    # Bad
    call(!! xyz)
    call( !! xyz)
    call(! !xyz)
    ```

*   The help operator.

    ```{r}
    # Good
    package?stats
    ?mean

    # Bad
    package ? stats
    ? mean
    ```

### Extra spaces

Adding extra spaces is ok if it improves alignment of `=` or `<-`.

```{r}
# Good
list(
  total = a + b + c,
  mean  = (a + b + c) / n
)

# Also fine
list(
  total = a + b + c,
  mean = (a + b + c) / n
)
```

Do not add extra spaces to places where space is not usually allowed.

## Vertical space

Use vertical whitespace sparingly, and primarily to separate your "thoughts" in code, much like paragraph breaks in prose.

* Avoid empty lines at the start or end of functions.
* Only use a single empty line when needed to separate functions or pipes.
* It often makes sense to put an empty line before a comment block, to help visually connect the explanation with the code that it applies to.

## Function calls

### Named arguments {#argument-names}

A function's arguments typically fall into two broad categories: one supplies
the __data__ to compute on; the other controls the __details__ of computation.
When you call a function, you typically omit the names of data arguments,
because they are used so commonly. If you override the default value of an
argument, use the full name:

```{r}
# Good
mean(1:10, na.rm = TRUE)

# Bad
mean(x = 1:10, , FALSE)
mean(, TRUE, x = c(1:10, NA))
```

Avoid partial matching, where you supply a unique prefix of a function argument.

```{r}
# Good
rep(1:2, times = 3)
cut(1:10, breaks = c(0, 4, 11))

# Bad
rep(1:2, t = 3)
cut(1:10, br = c(0, 4, 11))
```

### Assignment

Avoid assignment in function calls:

```{r}
# Good
x <- complicated_function()
if (nzchar(x) < 1) {
  # do something
}

# Bad
if (nzchar(x <- complicated_function()) < 1) {
  # do something
}
```

The only exception is in functions that capture side-effects:

```{r}
output <- capture.output(x <- f())
```

### Long function calls

Strive to limit your code to 80 characters per line. This fits comfortably on a
printed page with a reasonably sized font. If you find yourself running out of
room, this is a good indication that you should encapsulate some of the work in
a separate function or use early returns to reduce the nesting in your code.

If a function call is too long to fit on a single line, use one line each for
the function name, each argument, and the closing `)`.
This makes the code easier to read and to change later.

```{r}
# Good
do_something_very_complicated(
  something = "that",
  requires = many,
  arguments = "some of which may be long"
)

# Bad
do_something_very_complicated("that", requires, many, arguments,
                              "some of which may be long"
                              )
```

As described under [Named arguments](#argument-names), you can omit the argument names
for very common arguments (i.e. for arguments that are used in almost every
invocation of the function). If this introduces a large disparity between the line lengths, you may want to supply names anyway:

```{r}
# Good
my_function(
  x,
  long_argument_name,
  extra_argument_a = 10,
  extra_argument_b = c(1, 43, 390, 210209)
)

# Also good
my_function(
  x = x,
  y = long_argument_name,
  extra_argument_a = 10,
  extra_argument_b = c(1, 43, 390, 210209)
)
```

You may place multiple unnamed arguments on the same line if they are closely
related to each other. A common example of this is creating strings
with `paste()`. In such cases, it's often beneficial to match one line of code
to one line of output.

```{r}
# Good
paste0(
  "Requirement: ", requires, "\n",
  "Result: ", result, "\n"
)

# Bad
paste0(
  "Requirement: ", requires,
  "\n", "Result: ",
  result, "\n")
```

## Braced expressions {#braced-expressions}

Braced expressions, `{}`, define the most important hierarchy of R code, allowing you to group multiple R expressions together into a single expression. The most common places to use braced expressions are in function definitions, control flow, and in certain function calls (e.g. `tryCatch()` and `test_that()`).

To make this hierarchy easy to see:

* `{` should be the last character on the line.
  Related code (e.g., an `if` clause, a function declaration, a trailing comma, ...) must be on the same line as the opening brace.

* The contents should be indented by two spaces.

* `}` should be the first character on the line.

```{r}
# Good
if (y < 0 && debug) {
  message("y is negative")
}

if (y == 0) {
  if (x > 0) {
    log(x)
  } else {
    message("x is negative or zero")
  }
} else {
  y^x
}

test_that("call1 returns an ordered factor", {
  expect_s3_class(call1(x, y), c("factor", "ordered"))
})

tryCatch(
  {
    x <- scan()
    cat("Total: ", sum(x), "\n", sep = "")
  },
  interrupt = function(e) {
    message("Aborted by user")
  }
)

# Bad
if (y < 0 && debug) {
message("Y is negative")
}

if (y == 0)
{
    if (x > 0) {
      log(x)
    } else {
  message("x is negative or zero")
    }
} else { y ^ x }
```

It is occasionally useful to have empty braced expressions, in which case it should be written `{}`, with no intervening space.

```{r}
# Good
function(...) {}

# Bad
function(...) { }
function(...) {

}
```

## Control flow

### Loops

R defines three types of looping constructs: `for`, `while`, and `repeat` loops.

* The body of a loop must be a braced expression.

  ```{r}
  # Good
  for (i in seq) {
    x[i] <- x[i] + 1
  }

  while (waiting_for_something()) {
    cat("Still waiting...")
  }

  # Bad
  for (i in seq) x[i] <- x[i] + 1

  while (waiting_for_something()) cat("Still waiting...")
  ```

* It is occasionally useful to use a `while` loop with an empty braced expression body to wait. As mentioned in [Braced expressions](#braced-expressions), there should be no space within the `{}`.

### If statements

* A single line if statement must never contain braced expressions. You can use
  single line if statements for very simple statements that don't have
  side-effects and don't modify the control flow.

  ```{r}
  # Good
  message <- if (x > 10) "big" else "small"

  # Bad
  message <- if (x > 10) { "big" } else { "small" }

  if (x > 0) message <- "big" else message <- "small"

  if (x > 0) return(x)
  ```

* A multiline if statement must contain braced expressions.

  ```{r}
  # Good
  if (x > 10) {
    x * 2
  }

  if (x > 10) {
    x * 2
  } else {
    x * 3
  }

  # Bad
  if (x > 10)
    x * 2

  # In particular, this if statement will only parse when wrapped in a braced
  # expression or call
  {
    if (x > 10)
      x * 2
    else
      x * 3
  }
  ```

* When present, `else` should be on the same line as `}`.

* Avoid implicit type coercion (e.g. from numeric to logical) in the condition of an if statement:

  ```{r}
  # Good
  if (length(x) > 0) {
    # do something
  }

  # Bad
  if (length(x)) {
    # do something
  }
  ```

::: {.callout-note}
`&` and `|` should never be used inside of an `if` clause because they can return vectors. Always use `&&` and `||` instead.
:::

::: {.callout-note}
`ifelse(x, a, b)` is not a drop-in replacement for `if (x) a else b`. `ifelse()` is vectorised (i.e. if `length(x) > 1`, then `a` and `b`  will be recycled to match) and it is eager (i.e. both `a` and `b` will always be evaluated).
:::

### Control flow modifiers {#control-flow-modifiers}

Syntax that affects control flow (like `return()`, `stop()`, `break`, or `next`) should always go in their own `{}` block:

```{r}
# Good
if (y < 0) {
  stop("Y is negative")
}

find_abs <- function(x) {
  if (x > 0) {
    return(x)
  }
  x * -1
}

for (x in xs) {
  if (is_done(x)) {
    break
  }
}

# Bad
if (y < 0) stop("Y is negative")

find_abs <- function(x) {
  if (x > 0) return(x)
  x * -1
}

for (x in xs) {
  if (is_done(x)) break
}
```

### Switch statements

* Avoid position-based `switch()` statements (i.e. prefer names).
* Each element should go on its own line unless all element can fit on one line.
* Elements that fall through to the following element should have a space after `=`.
* Provide a fall-through error unless you have previously validated the input.

```{r}
# Good
switch(x,
  a = ,
  b = 1,
  c = 2,
  stop("Unknown `x`", call. = FALSE)
)

# Bad
switch(x,
  a =,
  b = 1,
  c = 2
)
switch(x,
  a = long_function_name1(), b = long_function_name2(),
  c = long_function_name2()
)
switch(y, 1, 2, 3)
```

## Semicolons

Semicolons are never recommended.
In particular, don't put `;` at the end of a line, and don't use `;` to put multiple commands on one line.

```{r}
# Good
my_helper()
my_other_helper()

# Bad
my_helper();
my_other_helper();

{ my_helper(); my_other_helper() }
```

## Assignment

Use `<-`, not `=`, for assignment.

```{r}
# Good
x <- 5

# Bad
x = 5
```

## Data

### Character vectors

Use `"`, not `'`, for quoting text. The only exception is when the text already
contains double quotes and no single quotes.

```{r}
# Good
"Text"
'Text with "quotes"'
'<a href="http://style.tidyverse.org">A link</a>'

# Bad
'Text'
'Text with "double" and \'single\' quotes'
```

### Logical vectors

Prefer `TRUE` and `FALSE` over `T` and `F`.

## Comments

Each line of a comment should begin with the comment symbol and a single
space: `# `

In data analysis code, use comments to record important findings and analysis
decisions. If you need comments to explain what your code is doing, consider
rewriting your code to be clearer. If you discover that you have more comments
than code, consider switching to [R Markdown][rmd].

[syntax]: https://rdrr.io/r/base/Syntax.html
[rmd]:    https://rmarkdown.rstudio.com/
# Functions

## Naming

As well as following the general advice for object names in @sec-objectnames, strive to use verbs for function names:

```{r}
# Good
add_row()
permute()

# Bad
row_adder()
permutation()
```

## Anonymous functions

Use the new lambda syntax: `\(x) x + 1` when writing short anonymous functions (i.e. when you define a function in an argument without giving it an explicit name).

```R
# Good
map(xs, \(x) mean((x + 5)^2))
map(xs, function(x) mean((x + 5)^2))

# Bad
map(xs, ~ mean((.x + 5)^2))
```

Don't use `\()` for multi-line functions:

```R
# Good
map(xs, function(x) {
  mean((x + 5)^2)
})

# Bad
map(xs, \(x) {
  mean((x + 5)^2)
})
```

Or when creating named functions:

```R
# Good
cv <- function(x) {
  sd(x) / mean(x)
}

# Bad
cv <- \(x) sd(x) / mean(x)
```

Avoid using `\()` in a pipe, and remember to use informative argument names.

## Multi-line function definitions

There are two options if the function name and definition can't fit on a single line. In both cases, each argument goes on its own line; the difference is how deep you indent it and where you put `)` and `{`:

*   **Single-indent**: indent the argument name with a single indent (i.e. two spaces).
    The trailing `)` and leading `{` go on a new line.

    ```{r}
    # Good
    long_function_name <- function(
      a = "a long argument",
      b = "another argument",
      c = "another long argument"
    ) {
      # As usual code is indented by two spaces.
    }
    ```

*   **Hanging-indent**: indent the argument name to match the opening `(` of `function`.
    The trailing `)` and leading `{` go on the same line as the last argument.

    ```{r}
    # Good
    long_function_name <- function(a = "a long argument",
                                   b = "another argument",
                                   c = "another long argument") {
      # As usual code is indented by two spaces.
    }
    ```

These styles are designed to clearly separate the function definition from its body.

```{r}
# Bad
long_function_name <- function(a = "a long argument",
  b = "another argument",
  c = "another long argument") {
  # Here it's hard to spot where the definition ends and the
  # code begins, and to see all three function arguments
}
```

If a function argument can't fit on a single line, this is a sign you should rework the argument to keep it [short and sweet](https://design.tidyverse.org/defaults-short-and-sweet.html).

## S7

In S7, the method definition can be long because the function name is replaced by a method call that specifies the generic and dispatch classes. In this case we recommend the single-indent style.

```{r}
method(from_provider, list(openai_provider, class_any)) <- function(
  provider,
  x,
  ...,
  error_call = caller_env()
) {
  ...
}
```

If the method definition is too long to fit on one line, use the usual rules to
spread the method arguments across multiple lines:

```{r}
method(
  from_provider,
  list(openai_provider, class_any, a_very_long_class_name)
) <- function(
  provider,
  x,
  ...,
  error_call = caller_env()
) {
  ...
}
```

## `return()`

Only use `return()` for early returns. Otherwise, rely on R to return the result
of the last evaluated expression.

```{r}
# Good
find_abs <- function(x) {
  if (x > 0) {
    return(x)
  }
  x * -1
}
add_two <- function(x, y) {
  x + y
}

# Bad
add_two <- function(x, y) {
  return(x + y)
}
```

Return statements should always be on their own line because they have important effects on the control flow. See also [control flow modifiers](#control-flow-modifiers).

```{r}
# Good
find_abs <- function(x) {
  if (x > 0) {
    return(x)
  }
  x * -1
}

# Bad
find_abs <- function(x) {
  if (x > 0) return(x)
  x * -1
}
```

If your function is called primarily for its side-effects (like printing,
plotting, or saving to disk), it should return the first argument invisibly.
This makes it possible to use the function as part of a pipe. `print` methods
should usually do this, like this example from [httr](http://httr.r-lib.org/):

```{r}
print.url <- function(x, ...) {
  cat("Url: ", build_url(x), "\n", sep = "")
  invisible(x)
}
```

## Comments

In code, use comments to explain the "why" not the "what" or "how". Each line
of a comment should begin with the comment symbol and a single space: `# `.

```{r}
# Good

# Objects like data frames are treated as leaves
x <- map_if(x, is_bare_list, recurse)


# Bad

# Recurse only with bare lists
x <- map_if(x, is_bare_list, recurse)
```

Comments should be in sentence case, and only end with a full stop if they
contain at least two sentences:

```{r}
# Good

# Objects like data frames are treated as leaves
x <- map_if(x, is_bare_list, recurse)

# Do not use `is.list()`. Objects like data frames must be treated
# as leaves.
x <- map_if(x, is_bare_list, recurse)


# Bad

# objects like data frames are treated as leaves
x <- map_if(x, is_bare_list, recurse)

# Objects like data frames are treated as leaves.
x <- map_if(x, is_bare_list, recurse)
```
# Pipes

## Introduction

Use `|>` to emphasise a sequence of actions, rather than the object that the actions are being performed on.

The tidyverse has been designed to work particularly well with the pipe, but you can use it with any code, particularly in conjunction with the `_` placeholder.

```{r}
strings |>
  str_replace("a", "b") |>
  str_replace("x", "y")

strings |>
  gsub("a", "b", x = _) |>
  gsub("x", "y", x = _)
```

Avoid using the pipe when:

* You need to manipulate more than one object at a time. Reserve pipes for a
  sequence of steps applied to one primary object.

* There are meaningful intermediate objects that could be given
  informative names.

## Whitespace

`|>` should always have a space before it, and should usually be followed by a new line. After the first step, each line should be indented by two spaces. This structure makes it easier to add new steps (or rearrange existing steps) and harder to overlook a step.

```{r}
# Good
iris |>
  summarize(across(where(is.numeric), mean), .by = Species) |>
  pivot_longer(!Species, names_to = "measure", values_to = "value") |>
  arrange(value)

# Bad
iris |> summarize(across(where(is.numeric), mean), .by = Species) |>
pivot_longer(!Species, names_to = "measure", values_to = "value") |>
arrange(value)
```

## Long lines

If the arguments to a function don't all fit on one line, put each argument on
its own line and indent:

```{r}
# Good
iris |>
  summarise(
    Sepal.Length = mean(Sepal.Length),
    Sepal.Width = mean(Sepal.Width),
    .by = Species
  )

# Bad
iris |>
  summarise(Sepal.Length = mean(Sepal.Length), Sepal.Width = mean(Sepal.Width), .by = Species)
```

For data analysis, we recommend using the pipe whenever a function needs to span multiple lines, even if it's only a single step.

```{r}
# Bad
summarise(
  iris,
  Sepal.Length = mean(Sepal.Length),
  Sepal.Width = mean(Sepal.Width),
  .by = Species
)
```

## Short pipes

It's ok to write a short pipe on a single line:

```{r}
# Ok
iris |> subset(Species == "virginica") |> _$Sepal.Length
iris |> summarise(width = Sepal.Width, .by = Species) |> arrange(width)
```

But because short pipes often become longer pipes, we recommend that you generally stick to one function per line:

```{r}
# Better
iris |>
  subset(Species == "virginica") |>
  _$Sepal.Length

iris |>
  summarise(width = Sepal.Width, .by = Species) |>
  arrange(width)
```

Sometimes it's useful to include a short pipe as an argument to a function in a
longer pipe. Carefully consider whether the code is more readable with a short
inline pipe (which doesn't require a lookup elsewhere) or if it's better to move
the code outside the pipe and give it an evocative name.

```{r}
# Good
x |>
  semi_join(y |> filter(is_valid))

# Ok
x |>
  select(a, b, w) |>
  left_join(y |> select(a, b, v), join_by(a, b))

# Better
x_join <- x |> select(a, b, w)
y_join <- y |> select(a, b, v)
left_join(x_join, y_join, join_by(a, b))
```

## Assignment

There are three acceptable forms of assignment:

*   Variable name and assignment on separate lines:

    ```{r}
    iris_long <-
      iris |>
      gather(measure, value, -Species) |>
      arrange(-value)
    ```

*   Variable name and assignment on the same line:

    ```{r}
    iris_long <- iris |>
      gather(measure, value, -Species) |>
      arrange(-value)
    ```

*   Assignment at the end of the pipe with `->`:

    ```{r}
    iris |>
      gather(measure, value, -Species) |>
      arrange(-value) ->
      iris_long
    ```

I think that the third is the most natural to write, but makes reading a little
harder: when the name comes first, it can act as a heading to remind
you of the purpose of the pipe.

## magrittr

We recommend you use the base `|>` pipe instead of magrittr's `%>%`.

```{r}
# Good
iris |>
  summarise(width = Sepal.Width, .by = Species) |>
  arrange(width)

# Bad
iris %>%
  summarise(width = Sepal.Width, .by = Species) %>%
  arrange(width)
```

As of R 4.3.0, the base pipe provides all the features from magrittr that we recommend using.
# ggplot2


## Introduction

Styling suggestions for `+` used to separate ggplot2 layers are very similar to those for `|>` in pipelines.


## Whitespace

`+` should always have a space before it, and should be followed by a new line. This is true even if your plot has only two layers. After the first step, each line should be indented by two spaces.

If you are creating a ggplot off of a dplyr pipeline, there should only be one level of indentation.

```{r}
# Good
iris |>
  filter(Species == "setosa") |>
  ggplot(aes(x = Sepal.Width, y = Sepal.Length)) +
  geom_point()

# Bad
iris |>
  filter(Species == "setosa") |>
  ggplot(aes(x = Sepal.Width, y = Sepal.Length)) +
    geom_point()

# Bad
iris |>
  filter(Species == "setosa") |>
  ggplot(aes(x = Sepal.Width, y = Sepal.Length)) + geom_point()
```


## Long lines

If the arguments to a ggplot2 layer don't all fit on one line, put each argument on its own line and indent:

```{r}
# Good
iris |>
  ggplot(aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_point() +
  labs(
    x = "Sepal width, in cm",
    y = "Sepal length, in cm",
    title = "Sepal length vs. width of irises"
  )

# Bad
iris |>
  ggplot(aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_point() +
  labs(x = "Sepal width, in cm", y = "Sepal length, in cm", title = "Sepal length vs. width of irises")
```

ggplot2 allows you to do data manipulation, such as filtering or slicing, within the `data` argument. Avoid this, and instead do the data manipulation in a pipeline before starting plotting.

```{r}
# Good
iris |>
  filter(Species == "setosa") |>
  ggplot(aes(x = Sepal.Width, y = Sepal.Length)) +
  geom_point()

# Bad
ggplot(filter(iris, Species == "setosa"), aes(x = Sepal.Width, y = Sepal.Length)) +
  geom_point()
```
# Files {#package-files}

The majority of advice in @sec-files also applies to files in packages. Important differences are described below.

## Names

* If a file contains a single function, give the file the same name as the
  function.

* If a file contains multiple related functions, give it a concise,
  but evocative name.

* Deprecated functions should live in a file with `deprec-` prefix.

## Organisation

In a file that contains multiple functions, public functions and their
documentation should appear first, with private functions appearing after all
documented functions. If multiple public functions share the same documentation,
they should all immediately follow the documentation block.

See @sec-documentation for more thorough guidance on documenting functions
in packages.

```{r}
# Bad
help_compute <- function() {
  # ... Lots of code ...
}

#' My public function
#'
#' This is where the documentation of my function begins.
#' ...
#' @export
do_something_cool <- function() {
  # ... even more code ...
  help_compute()
}
```

```{r}
# Good
#' Lots of functions for doing something cool
#'
#' ... Complete documentation ...
#' @name something-cool
NULL

#' @describeIn something-cool Get the mean
#' @export
get_cool_mean <- function(x) {
  # ...
}

#' @describeIn something-cool Get the sum
#' @export
get_cool_sum <- function(x) {
  # ...
}
```
# Documentation {#sec-documentation}

## Introduction

Documentation of code is essential, even if the only person using your code
is future-you. Use [roxygen2](https://github.com/klutometis/roxygen) with
[markdown](https://github.com/klutometis/roxygen/blob/master/vignettes/markdown.Rmd)
support enabled to keep your documentation close to the code.

## Title and description

Use the first line of your function documentation to provide a concise title that describes the function, dataset, or class. Titles should use sentence case
but not end with a full stop (`.`).

```{r}
#' Combine values into a vector or list
#'
#' This is a generic function which combines its arguments.
#'
```

There is no need to use the explicit `@title` or `@description` tags, except
in the case of the description if it is multiple paragraphs or includes
more complex formatting like a bulleted list.

```{r}
#' Apply a function to each element of a vector
#'
#' @description
#' The map function transform the input, returning a vector the same length
#' as the input.
#'
#' * `map()` returns a list or a data frame
#' * `map_lgl()`, `map_int()`, `map_dbl()` and `map_chr()` return
#'    vectors of the corresponding type (or die trying);
#' * `map_dfr()` and `map_dfc()` return data frames created by row-binding
#'    and column-binding respectively. They require dplyr to be installed.
```

## Indents and line breaks

Always indent with one space after `#'`. If any description corresponding to a
`roxygen` tag spans over multiple lines, add another two spaces of extra
indentation.

```{r}
#' @param key The bare (unquoted) name of the column whose values will be used
#'   as column headings.
```

Alternatively, tags that span over multiple lines (like `@description`, `@examples` and `@section`) can have the corresponding tag on its own line and then subsequent lines don't need to be indented.

```{r}
#' @examples
#' 1 + 1
#' sin(pi)
```

Use line breaks before/after sections where needed:

```{r}
#' @section Tidy data:
#' When applied to a data frame, row names are silently dropped. To preserve,
#' convert to an explicit variable with [tibble::rownames_to_column()].
#'
#' @section Scoped filtering:
#' The three [scoped] variants ([filter_all()], [filter_if()] and
#' [filter_at()]) make it easy to apply a filtering condition to a
#' selection of variables.
```

## Documenting parameters

For most tags, like `@param`, `@seealso` and `@return`, the text should be a
sentence, starting with a capital letter and ending with a full stop.

```{r}
#' @param key The bare (unquoted) name of the column whose values will be used
#'   as column headings.
```

If some functions share parameters, you can use `@inheritParams` to avoid
duplication of content in multiple places.

```{r}
#' @inheritParams function_to_inherit_from
```

## Capitalization and full stops

For all bullets, enumerations, argument descriptions and the like, use sentence
case and put a period at the end of each text element, even if it is only a few
words. However, avoid capitalization of function names or packages since R is
case sensitive. Use a colon before enumerations or bulleted lists.

```{r}
#' @details
#' In the following, we present the bullets of the list:
#' * Four cats are few animals.
#' * forcats is a package.
```

## Cross-linking

Cross-referencing is encouraged, both within R's help file system as well as to
external resources.

List closely related functions in `@seealso`. A single related function can be written as a sentence:

```{r}
#' @seealso [fct_lump()] to automatically convert the rarest (or most common)
#'   levels to "other".
```

More recommendations should be organised in a bulleted list:

```{r}
#' @seealso
#' * [tibble()] constructs from individual columns.
#' * [enframe()] converts a named vector into a two-column tibble (names and
#'   values).
#' * [name-repair] documents the details of name repair.
```


You can link to functions in other packages by using the fully qualified function name, i.e. `[pkg::function()]`.

If you have a family of related functions, you can use the `@family` tag to
automatically add appropriate lists and interlinks to the `@seealso` section.
Family names are plural. In dplyr, the verbs `arrange()`, `filter()`,
`mutate()`, `slice()`, `summarize()` form the family of single table verbs.

```{r}
#' @family single table verbs
```

When linking to external resources either include the full url inline with `<>`,  or the surrounding prose and link text should make it extremely clear where the hyperlink goes. Avoid text like ["click here"](https://www.smashingmagazine.com/2012/06/links-should-never-say-click-here/).

## R code

Text that contains valid R code should be marked as such using backticks. This includes:

* Function arguments, e.g. `na.rm`.
* Values, e.g. `TRUE`, `FALSE`, `NA`, `NaN`, `...`, `NULL`
* Literal R code, e.g. `mean(x, na.rm = TRUE)`
* Class names, e.g. "a tibble will have class `tbl_df` ..."

You can use code syntax for function names, like `` `tibble()` ``, but consider if it would be better to use a cross-link instead, like `[tibble()]`. If you refer to a function multiple times in one topic, you only need to link the first reference.

## Package names

Don't use code font for package names. If the package name might be misinterpreted as an ordinary word, disambiguate by following it with "package" or by wrapping the package name in `{}` (but not both).

```
# Good
Use the glue package to flexibly interpolate values into strings.
Use {glue} to flexibly interpolate values into strings.

# Bad
Use glue to flexibly interpolate values into strings.
Use `glue` to flexibly interpolate values into strings.
Use the {glue} package to flexibly interpolate values into strings.
```

If a package name comes at the start of a sentence, treat it like a proper name and don't capitalize it:

```
# Good
dplyr provides a grammar of data manipulation, providing a consistent set of verbs that help you solve the most common data manipulation challenges.

# Bad
Dplyr provides a grammar of data manipulation, providing a consistent set of verbs that help you solve the most common data manipulation challenges
```

## Internal functions

Internal functions should be documented with `#'` comments as per usual.
Use the `@noRd` tag to prevent `.Rd` files from being generated.

```{r}
#' Drop last
#'
#' Drops the last element from a vector.
#'
#' @param x A vector object to be trimmed.
#'
#' @noRd
```
# Error messages

An error message should start with a general statement of the problem then give a concise description of what went wrong.
Consistent use of punctuation and formatting makes errors easier to parse.

This guide assumes that you're using `cli::cli_abort()`.
We are transitioning to use this function in the tidyverse because it:

-   Makes it easy to generate bulleted lists.
-   Uses glue style interpolation to insert data into the error.
-   Supports a wide range of [inline markup](https://cli.r-lib.org/reference/inline-markup.html).
-   Provides convenient tools to [chain errors together](https://rlang.r-lib.org/reference/topic-error-chaining.html).
-   Can control the [name of the function](https://rlang.r-lib.org/reference/topic-error-call.html) shown in the error.

Much of the advice in this guide still applies if you're using `stop()`, but it will be be much more work to generate the message.

<!--# Need a brief description of the overall structure of an error here, as a guide to the following sections -->

## Problem statement

Every error message should start with a general statement of the problem.
It should be concise, but informative (This is hard!).
The problem statement should use sentence case and end with a full stop.

-   If the cause of the problem is clear (e.g. an incorrect type or size), use "**must**":

    ```{r}
    dplyr::nth(1:10, "x")
    #> Error:
    #> ! `n` must be a numeric vector, not a character vector.

    dplyr::nth(1:10, 1:2)
    #> Error:
    #> ! `n` must have length 1, not length 2.
    ```

    Do your best to tell the user both what is expected ("a numeric vector") and what they actually provided ("a character vector").

-   If you cannot state what was expected, use "**can't**":

    ```{r}
    mtcars |> pull(b)
    #> Error:
    #> ! Can't find column `b` in `.data`.

    as_vector(environment())
    #> Error:
    #> ! Can't coerce `.x` to a vector.

    purrr::modify_depth(list(list(x = 1)), 3, ~ . + 1)
    #> Error:
    #> ! Can't find specified `.depth` in `.x`.
    ```

<!--# Are there other forms that we use? Would be good to have some examples -->

## Error location

Ideally the error message should mention the failing function call.

<!--# I think it'd be useful to include a small example here -->

See <https://rlang.r-lib.org/reference/topic-error-call.html> for more about how to pass calls through error helpers.

## Error details

After the problem statement, use a bulleted list to provide further information.
Use cross bullets (`x`) to let the user know what the problem is, then use info bullets (`i`) to provide contextual information.
These are easy to create with `cli_abort()`: <!--# Include brief example here -->

<!--# Can you reorganise to show cross bullets then info bullets -->

Try to keep the sentences short and sweet:

```{r}
# Good
vec_slice(letters, 100)
#> ! Can't subset elements past the end.
#> ℹ Location 100 doesn't exist.
#> ℹ There are only 26 elements.

# Bad
vec_slice(letters, 100)
#> ! Must index an existing element.
#> There are 26 elements and you've tried to subset element 100.
```

Do your best to reveal the location, name, and/or content of the troublesome component of the input.
The goal is to make it as easy as possible for the user to find and fix the problem.

```{r}
# Good
map_int(1:5, ~ "x")
#> Error:
#> ! Each result must be a single integer.
#> ✖ Result 1 is a character vector.

# Bad
map_int(1:5, ~ "x")
#> Error:
#> ! Each result must be a single integer
```

(It is often not easy to identify the exact problem; it may require passing around extra arguments so that error messages generated at a lower-level can know the original source. For frequently used functions, the effort is typically worth it.)

If the source of the error is unclear, avoid pointing the user in the wrong direction by giving an opinion about the source of the error:

```{r}
# Good
pull(mtcars, b)
#> Error:
#> ! Can't find column `b` in `.data`.

tibble(x = 1:2, y = 1:3, z = 1)
#> Error:
#> ! Tibble columns must have compatible sizes.
#> • Size 2: Existing data.
#> • Size 3: Column `y`.
#> ℹ Only values of size one are recycled.

# Bad: implies one argument at fault
pull(mtcars, b)
#> Error:
#> ! Column `b` must exist in `.data`.

pull(mtcars, b)
#> Error:
#> ! `.data` must contain column `b`.

tibble(x = 1:2, y = 1:3, z = 1)
#> Error:
#> ! Column `x` must be length 1 or 3, not 2.
```

If there are multiple issues, or an inconsistency revealed across several arguments or items, prefer a bulleted list:

```{r}
# Good
purrr::reduce2(1:4, 1:2, `+`)
#> Error:
#> ! `.x` and `.y` must have compatible lengths:
#> ✖ `.x` has length 4
#> ✖ `.y` has length 2

# Bad: harder to scan
purrr::reduce2(1:4, 1:2, `+`)
#> Error:
#> ! `.x` and `.y` must have compatible lengths: `.x` has length 4 and
#> `.y` has length 2
```

If the list of issues might be long, make sure to truncate to only show the first few:

```{r}
# Good
#> Error: NAs found at 1,000,000 locations: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...
```

If you want to correctly pluralise the error message, consider using `ngettext()`.
See the notes in `?ngettext()` for some challenges related to correct translation to other languages.

## Hints

If the source of the error is clear and common, you may want to provide a hint as to how to fix it.
The hint should be the last bullet, use an info bullet (`i`), and end in a question mark.

```{r}
dplyr::filter(iris, Species = "setosa")
#> Error:
#> ! Filter specifications must be named.
#> ℹ Did you mean `Species == "setosa"`?

ggplot2::ggplot(ggplot2::aes())
#> Error:
#> ! Can't plot data with class "uneval".
#> ℹ Did you accidentally provide the results of aes() to the `data` argument?

mtcars |> ggplot() |> geom_point()
#> Error in `validate_mapping()`:
#> ! `mapping` must be created by `aes()`.
#> ℹ Did you use `%>%` or `|>` instead of `+`?
```

Hints are particularly important if the source of the error is far away from the root cause:

```{r}
# Bad
mean[[1]]
#> Error:
#> ! object of type 'closure' is not subsettable

# BETTER
mean[[1]]
#> Error:
#> ! Can't subset a function.

# BEST
mean[[1]]
#> Error:
#> ! Can't subset a function.
#> ℹ Have you forgotten to define a variable named `mean`?
```

Good hints are difficult to write because you want to avoid steering users in the wrong direction.
Generally, we avoid writing a hint unless the problem is common, and you can easily find a common pattern of incorrect usage (e.g. by searching StackOverflow).

## Punctuation

<!--# This should be spread amongst the relevant sections. -->

-   Errors should be written in sentence case, and should end in a full stop.
    Bullets should be formatted similarly; make sure to capitalise the first word (unless it's an argument or column name).

-   Prefer the singular in problem statements:

    ```{r}
    # Good
    map_int(1:2, ~ "a")
    #> Error:
    #> ! Each result must be coercible to a single integer.
    #> ✖ Result 1 is a character vector.

    # Bad
    map_int(1:2, ~ "a")
    #> Error:
    #> ! Results must be coercible to single integers.
    #> ✖ Result 1 is a character vector.
    ```

-   If you can detect multiple problems, list up to five.
    This allows the user to fix multiple problems in a single pass without being overwhelmed by many errors that may have the same source.

    <!--# Mention cli helper here -->

    ```{r}
    # BETTER
    map_int(1:10, ~ "a")
    #> Error:
    #> ! Each result must be coercible to a single integer.
    #> ✖ Result 1 is a character vector
    #> ✖ Result 2 is a character vector
    #> ✖ Result 3 is a character vector
    #> ✖ Result 4 is a character vector
    #> ✖ Result 5 is a character vector
    #> ... and 5 more problems
    ```

-   Pick a natural connector between problem statement and error location: this may be ", not", ";", or ":" depending on the context.

-   Surround the names of arguments in backticks, e.g. `` `x` ``.
    Use "column" to disambiguate columns and arguments: `` Column `x` ``.
    Avoid "variable", because it is ambiguous.
    <!--# Needs to be updated to refer to cli inline formatting -->

-   Ideally, each component of the error message should be less than 80 characters wide.
    Do not add manual line breaks to long error messages; they will not look correct if the console is narrower (or much wider) than expected.
    Instead, use bullets to break up the error into shorter logical components.
    In case you do need longer sentences, let cli perform paragraph wrapping automatically.
    It inserts newlines automatically depending on the width of the console.

## Before and after

More examples gathered from around the tidyverse.

```{r}
dplyr::filter(mtcars, cyl)
#> BEFORE:
#> ! Argument 2 filter condition does not evaluate to a logical vector.

#> AFTER:
#> ! Each argument must be a logical vector.
#> * Argument 2 (`cyl`) is an integer vector.

tibble::tribble("x", "y")
#> BEFORE: ! Expected at least one column name; e.g. `~name`
#>  AFTER: ! Must supply at least one column name, e.g. `~name`.

ggplot2::ggplot(data = diamonds) + ggplot2::geom_line(ggplot2::aes(x = cut))
#> BEFORE: ! geom_line requires the following missing aesthetics: y
#>  AFTER: ! `geom_line()` must have the following aesthetics: `y`.

dplyr::rename(mtcars, cyl = xxx)
#> BEFORE: ! `xxx` contains unknown variables
#>  AFTER: ! Can't find column `xxx` in `.data`.

dplyr::arrange(mtcars, xxx)
#> BEFORE: ! Evaluation error: object 'xxx' not found.
#>  AFTER: ! Can't find column `xxx` in `.data`.
```

## Localisation

It is encouraged to be as informative as possible, but each sentence should be very simple to make localisation and translation possible.
[A Localization Horror Story: It Could Happen To You](https://metacpan.org/pod/distribution/Locale-Maketext/lib/Locale/Maketext/TPJ13.pod) is a Good summary of the challenges of localising error messages.
You might not support localised messages right now but you should make it as easy as possible to do it in the future.
# Tests

## Organisation

The organisation of test files should match the organisation of `R/` files: if a function lives in `R/foofy.R`, then its tests should live in `tests/testthat/test-foofy.R`.

Use `usethis::use_test()` to automatically create a file with the correct name.

The file name will be displayed in output in order to get context.
# Git/GitHub

## Commit messages

Follow [standard git commit message advice](https://chris.beams.io/posts/git-commit/). In brief:

* The first line is the subject, and should summarise the changes in the commit
  in under 50 characters.
  Use sentence case, but no period at the end.

* If additional details are required, add a blank line, and then provide
  explanation and context in paragraph format.

* If the commit fixes a GitHub issue include `Fixes #<issue-number>`.
  This will ensure that the issue is automatically closed when the commit
  is merged into main.

## Pull requests

The title of a pull request should briefly describe the changes made. The title should be standalone and should not include the related issue number (i.e. don't write `Fixes #10`).

For very simple changes, you can leave the description blank as there's no need to describe what will be obvious from looking at the diff. For more complex changes, you should give an overview of the changes. If the PR fixes an issue, make sure to include `Fixes #<issue-number>` in the description.
