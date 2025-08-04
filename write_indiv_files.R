library(dplyr)
library(janitor)
library(purrr)

# output directory
output_dir <- "round1_indiv_responses"

# read data in
data0 <- read.csv("docs/Steelhead STARS Elicitation Round 1_transpose.csv", header = TRUE, stringsAsFactors = F) %>%
  clean_names() 

colnames(data0)[1] <- "Participant"

# Get the column names that represent the "Names" (excluding the first column)
# Assuming the first column is the identifier and all subsequent columns are individual responses.
name_columns <- names(data0)[-1]

# Create a new row with "Round" in the first column and 1s in others
new_row_data <- data.frame(matrix(ncol = ncol(data0), nrow = 1))
colnames(new_row_data) <- colnames(data0)
new_row_data[1, 1] <- "Round"
new_row_data[1, other_cols] <- 1

data <- rbind(data0, new_row_data)

# Use purrr::walk to iterate through each name column and create a new file
walk(name_columns, function(name) {
  # Select the first column (identifier/question) and the current name's response column
  # Using `select(1, all_of(name))` ensures we select the first column by its position
  # and the specific 'name' column by its name.
  output_data <- data %>%
    select(1, all_of(name)) 
    
  # Define the output file name
  # We replace any non-alphanumeric characters in the name with underscores to ensure valid filenames
  # and append ".csv"
  output_file_name <- file.path(output_dir, paste0(name, ".csv"))
  
  # Write the subset data to a new CSV file
  # row.names = FALSE prevents R from writing row numbers as the first column
  write.csv(output_data, output_file_name, row.names = FALSE)
  
  cat(paste0("Created file: ", output_file_name, "\n"))
})
