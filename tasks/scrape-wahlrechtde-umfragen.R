library("purrr")
library("rvest")
library("XML")
library("magrittr")
library("dplyr")
library("tidyr")
library("zoo")


# scrape data
institute <- c("allensbach", "emnid", "forsa", "politbarometer", "gms", "dimap", "insa")
parteien <- c("cdu.csu", "spd", "grüne", "fdp", "linke", "afd", "sonstige", "nw_un", "piraten", "fw")


df <-
  map_df(institute, function(i) {
    
    # keep calm! Fortschrittsbalken
    cat(".")
    
    page <- paste0("http://www.wahlrecht.de/umfragen/", i, ".htm") %>% read_html()
    data.frame(page %>% html_table(fill = TRUE), stringsAsFactors=FALSE)
  })


# clean data
names(df) %<>% tolower()

df %<>%
  filter(grepl("%", cdu.csu)) %>%
  filter(!grepl("Bundestagswahl", befragte)) %>%
  rename(institut = x1, datum2 = datum, nw_un = nichtwähler.unentschl.) %>%
  mutate(datum = ifelse(is.na(x.), datum2, x.)) %>%
  select(institut, datum, befragte, zeitraum, cdu.csu, spd, grüne, fdp, linke, afd, sonstige, nw_un,piraten,fw) %>%
  mutate(typ = ifelse(
    grepl("O • ", befragte), "online",
    ifelse(grepl("T • ", befragte), "telefon", "keineangabe")))

# gsub
df %<>% map(gsub, pattern = " %|≈|O • |T • |[?]", replacement = "")
df %<>% map(gsub, pattern = ",", replacement = ".")
df %<>% map_at("befragte", gsub, pattern = "[.]", replacement = "")

# classes
df %<>% map_at(parteien, as.numeric)
df %<>% map_at("befragte", as.numeric)
df$datum <- as.Date(df$datum, "%d.%m.%Y")
df %<>% as.data.frame()

write.csv(df, file="data/data-input.csv", row.names = F, quote = F)


# transform data set to longform
df_l <- df %>% gather(partei, anteil, -institut, -datum, -befragte, -zeitraum, -typ)
df_l$anteil <- df_l$anteil/100

write.csv(df_l, file="data/data-input-longform.csv", row.names = F, quote = F)


