library(dplyr)
library(magrittr)
library(tidyr)
library(ggplot2)
library(directlabels)
library(grid)
library(tidyr)
source("tasks/config.R")

df_se <- read.csv("data/data-transformed.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
df_se <- df_se %>% filter(partei %in% c("cdu.csu", "spd", "grüne", "linke", "afd", "fdp"))
df_se$datum <- as.Date(df_se$datum, "%Y-%m-%d")

latest_values <- arrange(df_se, desc(datum)) %>% filter(datum == datum[1])
df_se <- filter(df_se, datum > "2013-09-22")

get_label_value <- function (partei){
  index = match(partei, latest_values$partei)
  label = paste0(round(latest_values$rolling_average[index]*100, digits = 1),"%")
}

bigchart <-  ggplot(data = df_se, aes(x = datum)) +
  geom_ribbon(aes( ymin = ci_lower, ymax = ci_higher, fill=partei, group=partei), alpha = .5) +
  geom_line(aes(y = rolling_average, color = partei), size = 1, linetype = 3) +
  geom_dl(aes(x = datum, y = rolling_average, label = get_label_value(partei)), color = farben[df_se$partei], method = list(dl.trans(x = x + .2, cex = 1.5, fontfamily="SZoSansCond-Light"),"calc.boxes", "last.bumpup")) #+
bigchart <- bigchart + sztheme_lines +
  scale_colour_manual(values = farben) +
  scale_fill_manual(values = farben) + 
  scale_x_date(date_labels = "%Y", limits = as.Date(c("2013-09-22", NA)), expand = c(0, 0))+#, breaks = as.Date(c("2014","2015","2016","2017"), "%Y")) +
  scale_y_continuous(labels = scales::percent)

gt <- ggplotGrob(bigchart)
gt$layout$clip[gt$layout$name == "panel"] <- "off"
bigchart 

# ggsave(file="data/assets/plot-rolling.png", plot=gt, dpi = 144, units = "in", width = 8.89, height = 5)
ggsave(file="data/assets/longterm-poll-article.png", plot=gt, dpi = 144, units = "in", width = 8.89, height = 5)
ggsave(file="data/assets/longterm-poll-hp.png", plot=gt, dpi = 144, units = "in", width = 7.78, height = 4.38)
ggsave(file="data/assets/longterm-poll-mobile.png", plot=gt, dpi = 144, units = "in", width = 4.44, height = 3.33)

