## Reads in the 2015-16 data and generates correlations for a given
## column name. Writes the R^2, abbreviated column names, and full
## names for each numeric column and the column of interest to
## out_path="../../results/clean/exploratory/<col_name>_correlations.csv"
##
## Run with
## Rscript generate_cors.R <column_abbr>
##
## Defaults to COSTT4_A = Average cost of attendance

library(tidyverse)

args <- commandArgs(TRUE)
if(length(args) > 0){
    col_name <- args[1]
    } else {
        col_name <- "COSTT4_A"
    }

in_path <- "../../data/raw/MERGED2015_16_PP.csv"
out_path <- paste("../../results/exploratory/", col_name, "_correlations.csv", sep="")

df <- read_csv(in_path, na=c("NULL","NA","PrivacySuppressed",""))

print(paste("Successfully read in", in_path))

print("Mathy stuff...")
cors <- df %>%
    select(contains(col_name)) %>%
    cor(df[, sapply(df, is.numeric)], use="pair") %>%
    t() %>%
    data.frame(abbr=rownames(.), r=unname(.)) %>%
    mutate(r2=r^2) %>%
    arrange(desc(r2))

name_map <- read_csv("../../results/utility/column_names_translations.csv")

renamed_cors <- cors %>%
    inner_join(name_map) %>%
    select(c(abbr, r2, r))

## Only writes the abbreviated name, just join it with the
## translations if you need the full name.

print(paste("Writing to", out_path, "..."))
write_csv(renamed_cors, out_path)
print("Complete.")
