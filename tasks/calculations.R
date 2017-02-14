######
# dataframes
# df_raw_data: input with raw data from wahlrecht.de
# df_test_rolling_average: df with rolling average, party and date
# df_test_standard_error: df with higher and lower confidence intervall limits, in order to show the standard error (alpha = 0.05)

# read raw data 
df_raw_data <- read.csv("data/data-input-longform.csv", stringsAsFactors = FALSE)
df_l <- read.csv("data/data-input-longform.csv", stringsAsFactors = FALSE) # old verisobn

###### calculate rolling average

df_rolling_average <- df_raw_data %>%
  arrange(datum) %>%
  group_by(datum, partei) %>%
  mutate(anteil_grouped_by_date = mean(anteil)) %>% 
  select(datum, partei, anteil_grouped_by_date) %>% 
  unique() %>% 
  arrange(datum) %>%
  group_by(partei) %>%
  mutate('rolling_average' = round(rollapply(anteil_grouped_by_date, 10, mean, align="right", na.pad = TRUE, na.rm = TRUE),5)) %>% 
  arrange(desc(datum)) %>% 
  select(datum, partei, rolling_average)

# save
write.csv(df_rolling_average, file="data/data-rolling-average.csv", row.names = F, quote = F)


#### calculate limits to show standard error

# se = standard error
# ci_higher = upper limit of confidence intervall
# ci_lower = lower limit of confidence intervall


number_of_averages <- 10

df_standard_error <- df_raw_data %>% 
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(
    se = sqrt(anteil * (1-anteil) / befragte),
    ci_lower = round(anteil - 1.96 * se, 5),
    ci_higher = round(anteil + 1.96 * se, 5)) %>%
  arrange(desc(datum)) %>% 
  select(datum, partei, institut, ci_higher, ci_lower)

write.csv(df_standard_error, file="data/data-standarderror.csv", row.names = F, quote = F)

df_ci_lower <- df_standard_error %>% 
  group_by(datum, partei) %>%
  mutate(ci_lower_grouped_by_date = mean(ci_lower)) %>%
  unique() %>% 
  spread( -institut, fill = NA) #>% 
  # select(datum, institut, ci_lower_grouped_by_date)
  # tabelle umbauen institute in spalten


###### old version: one df for everything

# calculate standard error and the confidence intervall
df_se <- df_l %>%
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(
    se = sqrt(anteil * (1-anteil) / befragte),
    ci_lower = anteil - 1.96 * se,
    ci_higher = anteil + 1.96 * se,
    'rolling_average' = rollapply(anteil, 10, mean, align="right", na.pad = TRUE, na.rm = TRUE)) %>%
  arrange(desc(datum))

df_se[8:11] <- round(df_se[8:11],5)

write.csv(df_se, file="data/data-transformed.csv", row.names = F, quote = F)




################
#### latest average poll/sunday
#### se variant: average sample sizes
################

df_ave <- df_l %>%
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(
    'rolling_average' = rollapply(anteil, 10, mean, align="right", na.pad = TRUE),
    'average_sample_size' = rollapply(befragte, 10, mean, na.pad = TRUE, align = "right", na.rm = TRUE)) %>%
  select(partei, datum, rolling_average, average_sample_size)

#df_ave[3:4] <- round(df_ave[3:4],2)

write.csv(df_ave, file="data/data-rolling-average.csv", row.names = F, quote = F)


df_ave_latest <-
  df_ave %>% 
  mutate(se = sqrt(rolling_average * (1-rolling_average) / average_sample_size),
         ci_lower = rolling_average - 1.96 * se,
         ci_higher = rolling_average + 1.96 * se)  %>%
  arrange(desc(datum)) %>% 
  filter(datum == datum[1])
#df_ave_latest[3:5] <- round(df_ave_latest[3:5],2)

write.csv(df_ave_latest, file="data/data-lastest-average.csv", row.names = F, quote = F)

