library(purrr)
library(rvest)
library(dplyr)
library(magrittr)
library(tidyr)

# scrape data
institute <- c("allensbach", "emnid", "forsa", "politbarometer", "gms", "dimap", "insa")
parteien <- c("cdu/csu", "spd", "grüne", "fdp", "linke", "afd", "sonstige", "nw_un", "fw")
header <- c("CDU/CSU", "SPD", "GRÜNE", "FDP", "LINKE", "AfD", "Sonstige", "Nichtwähler/Unentschl.", "FW", "Befragte", "Zeitraum")

df <-
  map_df(institute, function(i) {
    # keep calm! Fortschrittsbalken
    cat(".")
    path <- paste0("http://www.wahlrecht.de/umfragen/", i, ".htm")
    page <- read_html(path, encoding = "utf-8")
    
    rdf <- list()
    table <- html_node(page, ".wilko")
    table_head <- html_nodes(table, xpath = "//thead//th") %>% html_text()

    rdf[["datum"]] <- html_nodes(page, xpath = "//table//tbody//tr//td[1]") %>% html_text()
    rdf[["institut"]] <- rep(i, length = length(rdf[["datum"]]))

    for(head_el in seq_along(header)){
      vec <- vector()
      hindex <- match(header[head_el], table_head)
      # fuck up, extra loop because table of politbarometer is strange structured (td-element instead of th-element)
      if(i == "politbarometer" && (header[head_el] == "Befragte" || header[head_el] =="Zeitraum")){
        hindex = hindex + 1
      }
      checkvec <- html_nodes(page, xpath = paste0("//table//tbody//tr//td[", hindex,"]")) %>% html_text()

      if (length(checkvec) > 0){
        vec <- checkvec
        rdf[[header[head_el]]] <- vec
      }
    }
    as.data.frame(do.call(cbind, as.list(rdf)), stringsAsFactor = F)
  })

# clean data
names(df) %<>% tolower()

df %<>%
  # filter(grepl("%", `cdu/csu`)) %>%
  filter(!grepl("Bundestagswahl", befragte)) %>%
  rename(nw_un = `nichtwähler/unentschl.`) %>%
    select(institut, datum, befragte, zeitraum, `cdu/csu`, spd, `grüne`, fdp, linke, afd, sonstige, nw_un,fw) %>%
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
df <- filter(df, !is.na(df$befragte))

# write.csv(df, file="data/data-input.csv", row.names = F, quote = F)

refine_party <- function (p){
  switch (p, cdu.csu = "CDU/CSU", spd = "SPD",afd = "AfD", `grüne` = "Grüne", fdp = "FDP", linke = "Linke", sonstige = "sonstige", nw_un = "nw_un", fw = "fw", p)
}
# `cdu/csu`, spd, `grüne`, fdp, linke, afd,
# transform data set to longform
df_l <- df %>% gather(partei, anteil, -institut, -datum, -befragte, -zeitraum, -typ)
df_l$anteil <- df_l$anteil/100
unique(df_l$partei)
df_l$partei <- apply(df_l["partei"],1, refine_party)

write.csv(df_l, file="data/data-input-longform.csv", row.names = F, quote = F)

