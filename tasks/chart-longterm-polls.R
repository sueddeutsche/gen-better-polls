library(dplyr)
library(magrittr)
library(tidyr)
library(ggplot2)
library(directlabels)
library(grid)
source("tasks/config.R")


df_se <- read.csv("data/data-transformed.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")

df_se <- df_se %>% filter(partei %in% c("cdu.csu", "spd", "grüne", "linke", "afd", "fdp"))
df_se$datum <- as.Date(df_se$datum)
bigchart <- df_se %>% filter(datum > "2013-09-22") %>%
  ggplot( aes(x = datum, y = rolling_average, color = partei)) +
  sztheme_lines +
  scale_colour_manual(values = farben) +
  # ggtitle("In 95 von 100 Fällen liegt der Wert in diesem Intervall") +
  scale_y_continuous(labels = scales::percent)

bigchart <- bigchart + geom_line(aes(x = datum, y = rolling_average, color = partei), size = 0.5) +
  geom_dl(aes(label = partei), method = list(dl.trans(x = x + .2),"last.bumpup"))
bigchart <- bigchart + geom_linerange(aes(ymax = ci_higher, ymin = ci_lower), alpha = 0.2)
bigchart
gt <- ggplotGrob(bigchart)
gt$layout$clip[gt$layout$name == "panel"] <- "off"
grid.draw(gt)

ggsave(file="data/assets/plot-rolling.png", plot=gt, units = "in", width=7, height= 4, limitsize = FALSE)

