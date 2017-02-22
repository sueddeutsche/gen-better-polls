library(dplyr)
library(rvest)
library(purrr)
library(magrittr)
library(tidyr)
library(ggplot2)
library(zoo)
library(XML)
source("tasks/config.R")


df_se <- read.csv("data/data-transformed.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
df_ci <- read.csv("data/data-ci-values.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
df_ci <- df_ci[-1,]
df_se <- df_se %>% filter(partei %in% c("CDU/CSU", "SPD", "Grüne", "Linke", "AfD", "FDP"))
df_se$datum <- as.Date(df_se$datum, "%Y-%m-%d")
df_ci$datum <- as.Date(df_ci$datum, "%Y-%m-%d")
df_ci$ci_lower <- as.numeric(df_ci$ci_lower)
df_ci$ci_higher <- as.numeric(df_ci$ci_higher)
str(df_ci)

latest_values <- arrange(df_se, desc(datum)) %>% filter(datum == datum[1])
df_se <- filter(df_se, datum > "2013-09-22")

get_label_value <- function (partei){
  index = match(partei, latest_values$partei)
  label = paste0("~",round(latest_values$rolling_average[index]*100, digits = 0),"%")
}

basechart <-  ggplot() +
  geom_ribbon(data = df_ci, aes( x= datum, ymin = ci_lower, ymax = ci_higher, fill=partei, group=partei), alpha = .5) +
  geom_line(data = df_se,aes(x = datum, y = rolling_average, color = partei), size = 1, linetype = 3) +
  geom_dl(data = df_se,aes(x = datum, y = rolling_average, label = get_label_value(partei)), color = farben[df_se$partei], method = list(dl.trans(x = x + .2, cex = 1.5, fontfamily="SZoSansCond-Light"),"calc.boxes", "last.bumpup")) #+
basechart <- basechart + 
  scale_colour_manual(values = farben, labels = NULL, breaks = NULL) +
  scale_fill_manual(values = farben, labels = df_se$partei) + guides(fill = guide_legend(override.aes = list(alpha = 1), nrow = 1)) +
  scale_x_date(date_labels = "%m/%Y", limits = as.Date(c("2015-01-01", NA)), expand = c(0, 0)) +
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

