interpolate_ci_values <- function(pollster, party, min) {
  if (min == TRUE){
    df_ci_working <-
      df_ci_lower %>%  arrange(partei, datum) %>% filter(institut == pollster, partei == party) %>% select(datum, partei, institut, ci_lower)
    names(df_ci_working) <- c("datum", "partei", "institut","ci_value")
    
    }
  else {
    df_ci_working <-
      df_ci_higher %>%  arrange(partei, datum) %>% filter(institut == pollster, partei == party) %>% select(datum, partei, institut, ci_higher)
    names(df_ci_working) <- c("datum", "partei", "institut","ci_value")
      # print(head(df_ci_working))
  }
  df_ci_working <-
    merge(df_datum, df_ci_working, by = "datum", all.x = TRUE)
  
  
  # df mit partei, datum, ein institut
  d <- df_ci_working %>% filter(!is.na(institut))
  d$datum <- as.Date(d$datum)
  
  get_missing_point <-
    function(date_young, date_older, date_missing, ci_younger, ci_older) {
      adjacent_side_current <- as.numeric(difftime(as.Date(date_young), as.Date(date_older), units = c("days")))
      adjacent_side_new <- as.numeric(difftime(as.Date(date_missing), as.Date(date_older), units = c("days")))
      
      ci_missing <-
        ci_older + ((ci_younger - ci_older) / adjacent_side_current) * adjacent_side_new
      return(ci_missing)
    }
  
  find_prev_date <- function (currentDate) {
    index <- findInterval(as.Date(currentDate), d$datum)
    prevDate <- ifelse(index == 0, NA, as.character(d$datum[index]))
    as.character(prevDate)
  }
  
  find_next_date <- function (prevDate) {
    index <- match(as.Date(prevDate), d$datum)
    nextDate <- d$datum[index + 1]
    as.character(nextDate)
  }
  
  find_ci <- function (date) {
    index <- match(as.Date(date), d$datum)
    ci <- ifelse(!is.na(index), d$ci_value[index], NA)
  }
  
  prev_date <- apply(df_ci_working["datum"], 1, find_prev_date)
  df_ci_working$prev_date <- unlist(prev_date)
  
  next_date <- apply(df_ci_working["prev_date"], 1, find_next_date)
  df_ci_working$next_date <- unlist(next_date)
  
  prev_ci <- apply(df_ci_working["prev_date"], 1, find_ci)
  df_ci_working$prev_ci <- unlist(prev_ci)
  
  next_ci <- apply(df_ci_working["next_date"], 1, find_ci)
  df_ci_working$next_ci <- unlist(next_ci)
  
  df_interpolate <- df_ci_working
  
  for (ci in seq_along(df_interpolate$ci_value)) {
    if (is.na(df_interpolate$ci_value[ci])) {
      df_interpolate$ci_value[ci] <-
        get_missing_point(
          df_interpolate$next_date[ci],
          df_interpolate$prev_date[ci],
          df_interpolate$datum[ci],
          df_interpolate$next_ci[ci],
          df_interpolate$prev_ci[ci]
        )
    }
  }
  df_interpolate <- select(df_interpolate, datum, ci_value)
  names(df_interpolate) <- c("datum", pollster)
  return(df_interpolate)
}

combine_institutes <- function(party, min) {
  pollsters <- unique(df_standard_error$institut)
  print(pollsters)
  all_institutes <- df_datum
  for (pollster in seq_along(pollsters)) {
    p <- interpolate_ci_values(pollsters[pollster], party, min)
    all_institutes <-
      merge(all_institutes, p, by.x = "datum", all.x = TRUE)
  }
  return(all_institutes)
}

min_helper <- function(v){
  return(min(v, na.rm = T))
}
max_helper <- function(v)
{
  return(max(v, na.rm = T))
}

get_interpolate_ci <- function(party){
  df_comb_min <- as.data.frame(combine_institutes(party, min=TRUE))
  df_comb_max <- as.data.frame(combine_institutes(party, min=FALSE))
  
  min_ci <- as.data.frame(apply(df_comb_min[,2:ncol(df_comb_min)], 1, min_helper))
  max_ci <- as.data.frame(apply(df_comb_max[,2:ncol(df_comb_max)], 1, max_helper))
  
  df_comb <- cbind(df_comb_min$datum, party, min_ci, max_ci)
  names(df_comb) <- c("datum", "partei", "ci_lower", "ci_higher")
  return(df_comb)
}

get_all_parties <- function(){
  parties <- unique(df_ci_lower$partei)
  df_comb <-c("datum", "partei", "ci_lower", "ci_higher")
  for(party in seq_along(parties)){
    p <- get_interpolate_ci(parties[party])
    df_comb <-rbind(df_comb, p)  
    df_comb <- df_comb[-1,]
  }
  return(df_comb)
}
# all_parties <- get_all_parties()