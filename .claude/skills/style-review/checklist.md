# Style Review Checklist

## File Names
- Machine readable: no spaces, symbols, or special characters
- Human readable: descriptive names
- Proper ordering: ISO8601 dates, zero-padded numbers

## File Organization
- Library calls at top of file
- Section headers with `##` comments
- Logical flow from setup to output

## Object Naming
- snake_case for variables and functions
- Meaningful, descriptive names
- No single-letter names except in short loops

## Spacing
- Spaces around operators (`<-`, `+`, `-`, `==`, etc.)
- Space after commas, not before
- No spaces inside parentheses
- Space before `(`  in function calls is optional but be consistent

## Indentation
- 2 spaces (not tabs)
- Consistent indentation within blocks

## Pipes
- Line break after `%>%`
- Indented continuation lines
- One operation per line in chained pipes

## Line Length
- Lines under 80 characters where feasible
- Break long function calls across multiple lines

## Assignment
- Use `<-` not `=` for assignment

## Strings
- Consistent quote style (single or double, pick one)

## Comments
- `#` followed by a space
- Section headers with `##`
- Comments explain "why" not "what"
