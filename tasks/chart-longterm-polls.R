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
df_se$datum <- as.Date(df_se$datum)
df_se <- filter(df_se, datum > "2013-09-22")
df_cipolys <- select(df_se, datum, partei, ci_lower, ci_higher)
df_cipolys <- gather(df_cipolys, x, y, ci_lower:ci_higher)

df_cipolys_lower <- subset(df_cipolys, df_cipolys$x == "ci_lower")
df_cipolys_lower <- df_cipolys_lower[order(df_cipolys_lower$datum),]
df_cipolys_higher <- subset(df_cipolys, df_cipolys$x == "ci_higher")
df_cipolys_higher <- df_cipolys_higher[order(df_cipolys_higher$datum, decreasing = T),]

df_cipolys <- rbind(df_cipolys_lower, df_cipolys_higher)

df_cipolys <- rbind(df_cipolys, df_cipolys[1,])
# str(df_cipolys)
# 
# ci_polygons <- ggplot(df_cipolys, aes(x = datum, y = y, group = partei))+
#   geom_polygon()



bigchart <-  ggplot() +
  # geom_polygon(data = df_cipolys, aes(x = datum, y = y, group = partei, fill = partei, alpha = 0.4)) +
  geom_ribbon(data = df_se, aes(x = datum, ymin = ci_lower, ymax = ci_higher, fill=partei, group=partei), alpha = .4) +
  geom_line(data = df_se, aes(x = datum, y = rolling_average, color = partei, label = partei), size = 0.5) +
  geom_label() +
  sztheme_lines +
  scale_colour_manual(values = farben) +
  scale_fill_manual(values = farben) +
  # ggtitle("In 95 von 100 Fällen liegt der Wert in diesem Intervall") +
  scale_y_continuous(labels = scales::percent)

# bigchart <- bigchart + geom_polygon(df_cipolys, aes(x = datum, y = y, group = partei))
# bigchart <- bigchart + geom_line(df_se, aes(x = datum, y = rolling_average, color = partei), size = 0.5) +
#   geom_dl(aes(label = partei), method = list(dl.trans(x = x + .2),"last.bumpup"))
# bigchart <- bigchart + geom_linerange(aes(ymax = ci_higher, ymin = ci_lower), alpha = 0.2)

bigchart
gt <- ggplotGrob(bigchart)
gt$layout$clip[gt$layout$name == "panel"] <- "off"
grid.draw(gt)

ggsave(file="data/assets/plot-rolling.png", plot=gt, units = "in", width=7, height= 4, limitsize = FALSE)

