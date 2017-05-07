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

dirichlet_pooled <- function(df_in, date_in) {
  ##Restrict to last poll before or at date_in by every institute
  last_poll <- df_in %>%
    tbl_df %>%
    filter(datum <= date_in) %>%
    group_by(institut) %>%
    filter(datum == max(datum))

  ##Aggregate by party. Compute prior/posterior of the Dirichlet
  ##distribution. See
  ##https://en.wikipedia.org/wiki/Dirichlet_distribution#Marginal_distributions
  ##We use non-proper prior assuming no prior information at all.
  pooled_polls <- last_poll %>% group_by(partei) %>%
    summarise(anzahl_befragte=sum(anteil*befragte),datum=date_in, mean_datum=mean(datum)) %>%
    mutate(prior_count=0, posterior_count = prior_count + anzahl_befragte)

  ##Compute parameters of the marginal beta distribution -
  ##https://en.wikipedia.org/wiki/Beta_distribution
  pooled_polls %<>% mutate(marginal_a = posterior_count,
                          marginal_b = sum(posterior_count) - marginal_a,
                          post_mean = marginal_a / (marginal_a + marginal_b),
                          rolling_average = post_mean,
                          sz_err = sqrt((marginal_a * marginal_b) / ((marginal_a + marginal_b + 1) * (marginal_a + marginal_b)^2)),
                          ##equi-tailed 95% posterior credibility interval
                          ci_lower = qbeta(0.025, marginal_a, marginal_b),
                          ci_higher =qbeta(0.975, marginal_a, marginal_b))

  ##Return interesting columns as result
  pooled_polls %>% select(datum,partei,rolling_average,sz_err,ci_higher,ci_lower)
}

##Run over all unique poll dates instead of doing the computation per
##line (and hence for each party and date) as done by
##
## df_sz_average <- df_base %>%
##  rowwise %>%
##  mutate(sz_avr = rolling_average(df_base,partei,datum)) %>%
##  select(datum,partei,sz_avr)
##
##[C]: Could be that I've got something wrong about the update frequency of the polls?

df_sz_pooled <- df_base %>% distinct(datum) %>% group_by(datum) %>% do({
  dirichlet_pooled(df_base, .$datum)
})

##Store to file
write.csv(df_sz_pooled, file="data/data-rolling-dirichlet-pooling.csv", row.names = FALSE, quote = FALSE)
