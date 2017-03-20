###########
# Basic Version of Confidence Intervals Calculations
###########


# calculate confidence intervals bases on single poll. therefore the institutes are still saved in the dataframe
# downside: rolling average and confidence intervals aren't based on the same data


#df_raw_data: input with raw data from wahlrecht.de
df_raw_data <- read.csv("data/data-input-longform.csv", stringsAsFactors = FALSE)
df_raw_data <- df_raw_data %>% filter(partei %in% c("CDU/CSU", "SPD", "Grüne", "Linke", "AfD", "FDP"))


# 1) calculate rolling average
df_rolling_average <- df_raw_data %>%
  arrange(datum) %>%
  group_by(datum, partei) %>%
  mutate(anteil_grouped_by_date = mean(anteil)) %>% 
  select(datum, partei, anteil_grouped_by_date) %>% 
  unique() %>% 
  arrange(datum) %>%
  group_by(partei) %>%
  mutate('rolling_average' = round(rollapply(anteil_grouped_by_date, 10, mean, align="right", fill=NA, na.rm = TRUE),5)) %>% 
  arrange(desc(datum)) %>% 
  select(datum, partei, rolling_average)


# 2) calculate standard errors and confidence intervals

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


# merge dataframe with rolling average and standard errors/confidence intervals
df_rolling_average_and_error <- left_join(df_rolling_average, df_standard_error, by = c("partei", "datum"))

# save as csv
write.csv(df_rolling_average_and_error, file="data/data-rolling_average_and_error.csv", row.names = FALSE, quote = FALSE)
