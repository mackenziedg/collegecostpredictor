library(dplyr)
df1<-read.csv(file='C:/Users/susmani/Documents/Year 5/Courses/Data Munging/GroupProject1/CollegeScorecard_Raw_Data_2017/CollegeScorecard_Raw_Data/MERGED_2010-15_selected_columns.csv', sep = ',')
df<-df1%>%
  group_by(UNITID, INSTNM, STABBR) %>%   
  summarise_all(funs(mean(.,na.rm=TRUE)))
write.csv(df, 'MERGED_2010-15_AVG.csv', row.names = FALSE)
