library(dplyr)
library(purrr)
library(readr)
library(here)
library(data.table)

# Combine individual csv files into one file (same as original spreadsheet)

input_dir <- "round2_indiv_responses/"

# list files
filenames <- list.files(input_dir, pattern="*.csv", full.names=TRUE)

# read file 1
df1 <- read_csv(filenames[1])
# read remaining files after removing column 1
other_dfs <- filenames[-1] %>%
  map(~read_csv(.x) %>% select(-1)) %>%
  bind_cols()
# combine files 
round2 <- cbind(df1, other_dfs) %>%
  filter(row_number() <= n()-1)
colnames(round2) <- gsub("_", " ", colnames(round2))
colnames(round2) <- tools::toTitleCase(colnames(round2))

# transpose 
df_t <- transpose(round2, make.names = "Participant", keep.names = "Participant") 

# write
write_csv(df_t, here("docs/elicitation_round2.csv"))

