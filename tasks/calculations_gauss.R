######
# dataframes
# df_raw_data: input with raw data from wahlrecht.de
# df_test_rolling_average: df with rolling average, party and date
# df_test_standard_error: df with higher and lower confidence intervall limits, in order to show the standard error (alpha = 0.05)

# read raw data 
df_raw_data <- read.csv("data/data-input-longform.csv", stringsAsFactors = FALSE)


df_raw_data <- df_raw_data %>% 
  filter(partei %in% c("CDU/CSU", "SPD", "Grüne", "Linke", "AfD", "FDP"), !is.na(anteil))

df_rolling_average <- df_raw_data %>%
  arrange(datum) %>%
  select(datum, partei, anteil, befragte) %>% 
  unique() %>% 
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(rolling_average = round(rollapply(anteil, 10, mean, align="right", fill=NA, na.rm = TRUE),5)) %>% 
  arrange(desc(datum)) %>% 
  select(datum, partei, rolling_average)

# save
write.csv(df_rolling_average, file="data/data-rolling-average.csv", row.names = F, quote = F)


#### calculate limits to show standard error

# se = standard error
# delta = standart error times 1.96
# ci_higher = upper limit of confidence intervall
# ci_lower = lower limit of confidence intervall


number_of_averages <- 10

df_standard_error <- df_raw_data %>% 
  arrange(datum) %>%
  select(datum,partei,anteil,befragte) %>%
  unique() %>%
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(
    se = sqrt(anteil * (1-anteil) / befragte),
    delta = round(1.96 * se,5), #NEU
    ci_lower = round(anteil - 1.96 * se, 5),
    ci_higher = round(anteil + 1.96 * se, 5)) %>%
  arrange(desc(datum)) %>% 
  select(datum, partei, delta) #NEU: delta wird exportiert

write.csv(df_standard_error, file="data/data-standarderror.csv", row.names = F, quote = F)

df_datum <- df_standard_error$datum %>% unique()
df_datum <- as.data.frame(df_datum)
names(df_datum) <- c("datum")




### Fehlerfortpflanzung

error_gauss <- function(x){
  i <- 1
  l <- length(x)
  qs <- 0 #quadratsumme
  for (i in 1:l){
    qs <- qs + x[i]*x[i]  
  }
  gaussfehler <- sqrt(1/l) * sqrt(qs)
  #  gaussfehler <- 1/l * sqrt(qs)
  gaussfehler
}

error_linear <- function(x){
  i <- 1
  l <- length(x)
  sum <- 0
  for (i in 1:l){
    sum <- sum + x[i]
  }
  fehlersumme <- 1 / l * sum
  fehlersumme
}

df_rolling_error <- df_standard_error %>%
  select(datum, partei, delta) %>%
  unique() %>%
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(rolling_error = round(rollapply(delta,10,error_linear, align = "right", fill= NA),5)) %>%
  arrange(desc(datum))

write.csv(df_rolling_error, file="data/data-rolling_error.csv", row.names = FALSE, quote = FALSE)

df_rolling_average_and_error <- left_join(df_rolling_average, df_rolling_error, by = c("datum", "partei"))
df_rolling_average_and_error %>% names
df_alles_rollt <- 
  df_rolling_average_and_error %>%
  ungroup() %>%
  arrange(datum) %>% 
  mutate(rolling_upper_ci = rolling_average + rolling_error) %>%
  mutate(rolling_lower_ci = rolling_average - rolling_error)

write.csv(df_rolling_average_and_error, file="data/data-rolling_average_and_error.csv", row.names = FALSE, quote = FALSE)

