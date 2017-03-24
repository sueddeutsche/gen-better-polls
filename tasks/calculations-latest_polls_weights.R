# df_raw_data: input with raw data from wahlrecht.de
df_raw_data <- read.csv("data/data-input-longform.csv", stringsAsFactors = FALSE)
df_raw_data <- df_raw_data %>% 
  filter(partei %in% c("CDU/CSU", "SPD", "Grüne", "Linke", "AfD", "FDP"), !is.na(anteil)) %>% 
  mutate(datum = as.Date(datum))

# df_raw_data$datum = as.Date(df_raw_data$datum)
# str(df_raw_data)

df_base <- df_raw_data %>%
  select(institut, datum, partei, anteil, befragte) %>%
  unique()

weighted_average <- function(df_in,party_in,date_in){
  df_roll <- df_in %>%
    tbl_df %>%
    filter(datum <= date_in) %>%
    filter(partei == party_in) %>%
    group_by(institut) %>%
    filter(datum == max(datum)) %>%
    ungroup() %>%
    mutate(roll_avr = sum(befragte * anteil) / sum(befragte))
  sz_avr <- df_roll[1,]$roll_avr
  sz_avr
}

df_sz_average <- df_base %>% 
  rowwise %>% 
  mutate(rolling_average = weighted_average(df_base,partei,datum)) %>% 
  select(datum,partei,rolling_average)

# se = standard error
# delta = standart error times 1.96
# ci_higher = upper limit of confidence intervall
# ci_lower = lower limit of confidence intervall

df_standard_error <- df_raw_data %>% 
  select(institut,datum,partei,anteil,befragte) %>%
  unique() %>%
  mutate(
    se = sqrt(anteil * (1-anteil) / befragte),
    delta = round(1.96 * se,5)) %>% 
  select(institut, datum, partei, befragte, delta) 

#weighted error v1: lineare fehlerfortpflanzung (annahme, dass die Umfragen *nicht* statistisch unabhängig sind)
weighted_error <- function(df_in,party_in,date_in){
  df_roll <- df_in %>%
    tbl_df %>%
    filter(datum <= date_in) %>%
    filter(partei == party_in) %>%
    group_by(institut) %>%
    filter(datum == max(datum)) %>%
    ungroup() %>%
    mutate(roll_err = sum(befragte * delta) / sum(befragte))
  sz_err <- df_roll[1,]$roll_err
  sz_err
}

# weighted error v2: fehlerfortpflanzung nach gauss (annahme, dass die Umfragen statistisch unabhängig sind)
# weighted_error <- function(df_in,party_in,date_in){
#   df_roll <- df_in %>%
#     tbl_df %>%
#     filter(datum <= date_in) %>%
#     filter(partei == party_in) %>%
#     group_by(institut) %>%
#     filter(datum == max(datum)) %>%
#     ungroup() %>%
#     mutate(roll_err = sqrt(sum(befragte * befragte * delta * delta)) / sum(befragte))
#   sz_err <- df_roll[1,]$roll_err
#   sz_err
# }

df_sz_error <- df_base %>% 
  rowwise %>% 
  mutate(sz_err = weighted_error(df_standard_error,partei,datum)) %>% 
  select(datum,partei,sz_err)

df_rolling_average_and_error <- left_join(df_sz_average, df_sz_error, by = c("datum", "partei")) %>%
  ungroup() %>%
  arrange(datum) %>% 
  mutate(ci_higher = rolling_average + sz_err) %>%
  mutate(ci_lower = rolling_average - sz_err)

write.csv(df_rolling_average_and_error, file="data/data-rolling-average-and-error.csv", row.names = FALSE, quote = FALSE)