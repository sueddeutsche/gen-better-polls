df_raw_data <- read.csv("data/data-input-longform.csv", stringsAsFactors = FALSE)


# exclude all rows with NA in anteil, problem e.g. 2017-02-02 with INSA
df_raw_data <- df_raw_data %>% 
filter(partei %in% c("CDU/CSU", "SPD", "Grüne", "Linke", "AfD", "FDP"), !is.na(anteil))
# filter(partei %in% c("CDU/CSU", "SPD"), )

  

# get rolling average over last 10 entries
df_rolling_average <- df_raw_data %>%
  arrange(datum) %>%
  select(datum, partei, anteil, befragte) %>% 
  unique() %>% 
  arrange(datum) %>%
  group_by(partei) %>%
  mutate('rolling_average' = round(rollapply(anteil, 10, mean, align="right", fill = NA),5)) %>% 
  arrange(desc(datum)) %>% 
  select(datum, partei, rolling_average)


# get standard error, delta and confidence intervall limits from raw input data
df_standard_error <- df_raw_data %>% 
  arrange(datum) %>%
  select(datum,partei,anteil,befragte) %>%
  unique() %>%
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(
    se = sqrt(anteil * (1-anteil) / befragte),
    delta = 1.96 * se, #NEU
    ci_lower = round(anteil - 1.96 * se, 5),
    ci_higher = round(anteil + 1.96 * se, 5)) %>%
  arrange(desc(datum)) %>% 
  select(datum, partei, delta) #NEU: delta wird exportiert


gauss <- function(x, na.rm = T){
  i <- 1
  l <- length(x)
  qs <- 0 #quadratsumme
  for (i in 1:l){
    qs <- qs + x[i]*x[i]  
  }
  gaussfehler <- sqrt(1/l) * sqrt(qs)
  gaussfehler
}

df_rolling_gauss <- df_standard_error %>%
  select(datum, partei, delta) %>%
  unique() %>%
  arrange(datum) %>%
  group_by(partei) %>%
  mutate(rolling_gauss = rollapply(delta, 10, gauss, align = "right", fill = NA)) %>%
  arrange(desc(datum))





  
# join rolling_average and rolling_gauss_error
df_rolling_average_and_gauss <- left_join(df_rolling_average, df_rolling_gauss, by = c("datum", "partei")) %>%
  ungroup() %>%
  arrange(datum) %>% 
  mutate(rolling_upper_ci = rolling_average + rolling_gauss) %>%
  mutate(rolling_lower_ci = rolling_average - rolling_gauss) %>% 
  arrange(desc(datum))

write.csv(df_rolling_average_and_gauss, file="data/data-rolling-average-gauss.csv", row.names = F, quote = F)
