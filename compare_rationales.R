# Code to compare rationales to see which comments have changed

library(tidyverse)

# 1. Read data
elicit1 <- read_csv("elicit1.csv", show_col_types = FALSE)
elicit2 <- read_csv("elicit2.csv", show_col_types = FALSE)

# 2. Normalize participant names
elicit1 <- elicit1 %>% mutate(Name = tolower(str_trim(Name)))
elicit2 <- elicit2 %>% mutate(Name = tolower(str_trim(Name)))

# 3. Identify rationale columns
rat_cols <- elicit1 %>% select(starts_with("rat")) %>% names()

# 4. Select relevant columns and join
merged <- full_join(
  elicit1 %>% select(Name, all_of(rat_cols)),
  elicit2 %>% select(Name, all_of(rat_cols)),
  by = "Name",
  suffix = c("_1", "_2")
)

# 5. Compare rationales (including NA/blank to non-blank changes)
changed_rationales <- map_dfr(rat_cols, function(col) {
  col1 <- paste0(col, "_1")
  col2 <- paste0(col, "_2")
  
  merged %>%
    filter(
      # Compare values including NA / blank cases
      (is.na(.data[[col1]]) & !is.na(.data[[col2]])) |
        (!is.na(.data[[col1]]) & is.na(.data[[col2]])) |
        (replace_na(.data[[col1]], "") != replace_na(.data[[col2]], ""))
    ) %>%
    transmute(
      Name,
      Rationale_Field = col,
      Old_Value = .data[[col1]],
      New_Value = .data[[col2]]
    )
})

# Write file
write_csv(changed_rationales, "changed_rationales_r2.csv")
