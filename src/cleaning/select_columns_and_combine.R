# Pulls out selected columns `all_cols` from each year of data, and
# combines them into one file at:
# data/clean/MERGED_2010-15_selected_columns.csv"

library(dplyr)
library(data.table)

rel_cols <- c("UNITID", "INSTNM", "STABBR", "CONTROL",
              "LOCALE", "LOCALE2", "SCH_DEG", "ADM_RATE", "ACTCMMID",
              "SATVRMID", "SATMTMID", "SATWRMID",
              "UGDS", "CURROPER", "TUITIONFEE_IN", "TUITIONFEE_OUT",
              "PCTPELL", "C150_4", "RET_FT4", "PCTFLOAN",
              "LO_INC_DEATH_YR4_RT", "MD_INC_DEATH_YR4_RT", "HI_INC_DEATH_YR4_RT",
              "LO_INC_RPY_1YR_RT", "MD_INC_RPY_1YR_RT", "HI_INC_RPY_1YR_RT",
              "LO_INC_RPY_3YR_RT", "MD_INC_RPY_3YR_RT", "HI_INC_RPY_3YR_RT",
              "LO_INC_RPY_5YR_RT", "MD_INC_RPY_5YR_RT", "HI_INC_RPY_5YR_RT",
              "LO_INC_RPY_7YR_RT", "MD_INC_RPY_7YR_RT", "HI_INC_RPY_7YR_RT",
              "LO_INC_DEBT_MDN", "MD_INC_DEBT_MDN", "HI_INC_DEBT_MDN",
              "MD_EARN_WNE_P6", "MD_EARN_WNE_P8", "MD_EARN_WNE_P10",
              "PCT25_EARN_WNE_P6", "PCT75_EARN_WNE_P6",
              "PCT25_EARN_WNE_P8", "PCT75_EARN_WNE_P8",
              "PCT25_EARN_WNE_P10", "PCT75_EARN_WNE_P10",
              "COUNT_WNE_INC1_P6", "COUNT_WNE_INC2_P6", "COUNT_WNE_INC3_P6")

pcip_cols <- c("PCIP01", "PCIP03", "PCIP04", "PCIP05", "PCIP09")
pcip_cols <- c(pcip_cols, paste("PCIP", 10:16, sep=""), "PCIP19", paste("PCIP", 22:27, sep=""),
               paste("PCIP", 29:31, sep=""), paste("PCIP", 38:52, sep=""), "PCIP54")

npt_prog_cols <- paste("NPT", 41:45, "_PROG", sep="")
num_prog_cols <- paste("NUM", 41:45, "_PROG", sep="")

all_cols <- c(rel_cols, pcip_cols, npt_prog_cols, num_prog_cols)

dfs <- c()

for(i in 10:14){
    yr <- i + 2000
    yr_str <- paste(yr, "_", i+1, sep="")
    file_path <- paste("../../data/raw/MERGED", yr_str, "_PP.csv", sep="")

    df <- fread(file=file_path, header=TRUE, na.strings=c("", "NA", "NULL", "PrivacySuppressed"))

    df <- df %>%
        select(one_of(all_cols)) %>%
        mutate(YEAR=yr)

    dfs <- bind_rows(dfs, df)
}

fwrite(dfs, "../../data/clean/MERGED_2010-15_selected_columns.csv")
