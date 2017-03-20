source("tasks/ci-interpolation.R")

######
# dataframes
# df_raw_data: input with raw data from wahlrecht.de
# df_test_rolling_average: df with rolling average, party and date
# df_test_standard_error: df with higher and lower confidence intervall limits, in order to show the standard error (alpha = 0.05)

# read raw data 
df_raw_data <- read.csv("data/data-input-longform.csv", stringsAsFactors = FALSE)
df_raw_data <- df_raw_data %>% filter(partei %in% c("CDU/CSU", "SPD", "Grüne", "Linke", "AfD", "FDP"))


###### calculate rolling average

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

df_ci <- df_standard_error %>% 
  group_by(datum, partei) %>%
  unique()

df_ci_higher <- df_ci %>% 
  select(datum, partei, institut, ci_higher)

df_ci_lower <- df_ci %>%
  select(datum, partei, institut, ci_lower)

df_datum <- df_standard_error$datum %>% unique()
df_datum <- as.data.frame(df_datum)
names(df_datum) <- c("datum")

df_ci_interpolated <- get_all_parties()

write.csv(df_ci_interpolated, file="data/data-ci-values.csv", row.names = F, quote = F)
