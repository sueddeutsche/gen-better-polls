library(xml2)
library(purrr)


datum <- vector()
institut <- vector()
befragte <- vector()
partei <- vector()
anteil <- vector()

# call api
path <- "http://www.wahlrecht.de/umfragen/bundesweite.xml"
page <- read_xml(path, encoding = "utf-8")

# save data
wahlrecht_data <- xml_children(xml_root(page))

getParties <- function(xml){
  party <- as.data.frame(matrix(nrow = 6, ncol = 2))
  party$names <- c("CDU/CSU","SPD","Grüne","FDP", "Linke", "AfD")
  party$values <- c(xml_text(xml_child(one_poll,"cxu")),xml_text(xml_child(one_poll,"spd")),xml_text(xml_child(one_poll,"grn")),xml_text(xml_child(one_poll,"fpd")),xml_text(xml_child(one_poll,"lnk")),xml_text(xml_child(one_poll,"afd")))
  return(party)
}
  

for (row in seq_along(wahlrecht_data)){
  one_poll <- wahlrecht_data[row]
  parties <- getParties(one_poll)
  for (party in seq_along(parties$names))
  {
    datum <- rbind(datum, xml_text(xml_child(one_poll,"datum")))
    institut <- rbind(institut, xml_text(xml_child(one_poll,"institut")))
    befragte <- rbind(befragte,  xml_text(xml_child(one_poll,"befragte")))
    partei <- rbind(partei, parties$names[party])
    anteil <- rbind(anteil, parties$values[party])
  }
}
api_data <- data.frame(datum, institut, befragte, partei, anteil, stringsAsFactors = F)
# 
# refine data
api_data$befragte <- as.numeric(api_data$befragte)

refine_institut <- function (p){
  switch (p, Emnid = "emnid", 'Forschungsgruppe Wahlen' = "fgw", 'Infratest dimap' = "infdim", Allensbach = "allens", INSA = "insa", GMS = "gms", Forsa = "forsa", p)
}
refine_date <- function (rawDate){
  t <- substr(rawDate, 1,2)
  m <- substr(rawDate, 4,5)
  j <- substr(rawDate, 7,10)
  date <- as.character(paste0(j,"-",m,"-",t))
  return(date)
}
api_data$anteil <- gsub(',', '.', api_data$anteil)
api_data$anteil <- as.double(api_data$anteil)
api_data$institut <- apply(api_data["institut"],1, refine_institut)
api_data$anteil <- apply(api_data["anteil"],1, function(x) x/100)
api_data$datum <- apply(api_data["datum"],1, refine_date)
# api_data <- as.data.frame(api_data)
# api_data <- filter(api_data, !is.na(api_data$befragte))

df_all <- read.csv("data/data-input-longform-2013-16.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
df_all <- df_all[,-1]
df_all <- rbind(df_all, api_data)

write.csv(df_all, file="data/data-input-longform.csv", quote = F)

