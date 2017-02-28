library(xml2)

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
for (row in seq_along(wahlrecht_data)){
  one_poll <- wahlrecht_data[row]
  parties <- xml_children(xml_child(one_poll,5))
  for (party in seq_along(parties))
  {
    datum <- rbind(datum, xml_text(xml_child(one_poll,3)))
    institut <- rbind(institut, xml_text(xml_child(one_poll,4)))
    befragte <- rbind(befragte,  xml_text(xml_child(one_poll,6)))
    partei <- rbind(partei, xml_name(parties[party]))
    anteil <- rbind(anteil, xml_text(parties[party]))
  }
}
api_data <- data.frame(datum, institut, befragte, partei, anteil, stringsAsFactors = F)

# refine data
api_data$befragte <- as.numeric(api_data$befragte)
api_data$anteil <- as.numeric(api_data$anteil)

refine_party <- function (p){
  switch (p, cxu = "CDU/CSU", spd = "SPD",afd = "AfD", grn = "Grüne", fpd = "FDP", lnk = "Linke", son = "Sonstige", p)
}
api_data$partei <- apply(api_data["partei"],1, refine_party)
api_data$anteil <- apply(api_data["anteil"],1, function(x) x/100)
api_data <- as.data.frame(api_data)
# api_data <- filter(api_data, !is.na(api_data$befragte))

df_all <- read.csv("data/data-input-longform-2013-16.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
df_all <- cbind(df_all, api_data)

# write.csv(df_all, file="data/data-input-longform.csv", quote = F)

