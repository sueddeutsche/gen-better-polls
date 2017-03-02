library(dplyr)
library(rvest)
library(purrr)
library(magrittr)
library(tidyr)
library(ggplot2)
library(zoo)
library(XML)
source("tasks/config.R")


df_se <- read.csv("data/data-rolling-average-fake.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
df_ci <- read.csv("data/data-ci-values.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")

# set formats
df_se$datum <- as.Date(df_se$datum, "%Y-%m-%d")

df_ci$datum <- as.Date(df_ci$datum, "%Y-%m-%d")
df_ci$ci_lower <- as.numeric(df_ci$ci_lower)
df_ci$ci_higher <- as.numeric(df_ci$ci_higher)

df_ci$rolling_lower <- as.numeric(df_ci$rolling_lower)
df_ci$rolling_higher <- as.numeric(df_ci$rolling_higher)

ci_party <- unique(df_ci$partei)
se_party <- unique(df_se$partei)

latest_values <- arrange(df_se, desc(datum)) %>% filter(datum == datum[1])
startDatum <- "2015-03-01"
df_se <- filter(df_se, datum > startDatum)

# andere Namen für die Linien als das Standardlabel
get_label_value <- function (partei){
  index = match(partei, latest_values$partei)
  label = paste0("ca. ",round(latest_values$rolling_average[index]*100, digits = 0),"%")
  label = as.character(label)
}

# Diagramm zusammen bauen
basechart <- ggplot() +
  geom_ribbon(data = df_ci, aes( x= datum, ymin = rolling_lower, ymax = rolling_higher, fill=partei, group=partei), alpha = .6) +
  geom_line(data = df_se,aes(x = datum, y = rolling_average, color = partei), size = 1, linetype = 3) +
  geom_dl(data = df_se,aes(x = datum, y = rolling_average, label = as.character(get_label_value(partei))), color = farben[df_se$partei], method = list(dl.trans(x = x + .2, cex = 1.5, fontfamily="SZoSansCond-Light"),"calc.boxes", "last.bumpup"))
basechart <- basechart + 
  scale_colour_manual(values = farben[plabels], labels = NULL, breaks = NULL) +
  scale_fill_manual(values = farben_ci[plabels ], labels = plabels) + guides(fill = guide_legend(override.aes = list(alpha = 1), nrow = 1)) +
  scale_x_date(date_labels = "%m.%Y", limits = as.Date(c(startDatum, NA)), expand = c(0, 0)) +
  scale_y_continuous(labels = scales::percent)

article_chart <- basechart + sztheme_lines 
mobile_chart <- basechart + sztheme_lines + sztheme_lines_mobile  
  
article_chart <- ggplotGrob(article_chart)
article_chart$layout$clip[article_chart$layout$name == "panel"] <- "off"
mobile_chart <- ggplotGrob(mobile_chart)
mobile_chart$layout$clip[mobile_chart$layout$name == "panel"] <- "off"

# ggsave(file="data/assets/plot-rolling.png", plot=gt, dpi = 144, units = "in", width = 8.89, height = 5)
ggsave(file="data/assets/longterm-poll-article.png", plot=article_chart, dpi = 144, units = "in", width = 8.89, height = 5)
# ggsave(file="data/assets/longterm-poll-hp.png", plot=article_chart, dpi = 144, units = "in", width = 7.78, height = 4.38)
ggsave(file="data/assets/longterm-poll-mobile.png", plot=mobile_chart, dpi = 144, units = "in", width = 4.45, height = 3.33)

