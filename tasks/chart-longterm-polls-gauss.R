df_rolling_average_and_gauss <- read.csv("data/data_alles_rollt.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")

# set formats
df_rolling_average_and_gauss$datum <- as.Date(df_rolling_average_and_gauss$datum, "%Y-%m-%d")
df_rolling_average_and_gauss$rolling_lower_ci <- as.numeric(df_rolling_average_and_gauss$rolling_lower_ci)
df_rolling_average_and_gauss$rolling_upper_ci <- as.numeric(df_rolling_average_and_gauss$rolling_upper_ci)

df_rolling_average_and_gauss_party <- unique(df_rolling_average_and_gauss$partei)


latest_values <- arrange(df_rolling_average_and_gauss, desc(datum)) %>% filter(datum == datum[1])
startDatum <- "2015-01-01"
df_rolling_average_and_gauss %<>% filter(datum > startDatum)

# andere Namen für die Linien als das Standardlabel
get_label_value <- function (partei){
  index = match(partei, latest_values$partei)
  label = paste0("~",round(latest_values$rolling_average[index]*100, digits = 0),"%")
  label = as.character(label)
}

# Diagramm zusammen bauen
basechart <- df_rolling_average_and_gauss %>% 
  ggplot() +
  geom_ribbon( aes( x= datum, ymin = rolling_lower_ci, ymax = rolling_upper_ci, fill = partei, group = partei, color = partei), alpha = .6, size = .1) +
  geom_line(aes(x = datum, y = rolling_average, color = partei), size = .2) +
  # add labels at the end of the line
  geom_dl(aes(x = datum, y = rolling_average, label = as.character(get_label_value(partei))), color = farben[df_rolling_average_and_gauss$partei], method = list(dl.trans(x = x + .2, cex = 1.5, fontfamily="SZoSansCond-Light"),"calc.boxes", "last.bumpup"))


#basechart <- basechart + 
basechart <- basechart + 
  # add SZ colors
  scale_colour_manual(values = farben[plabels], labels = NULL, breaks = NULL) +
  # does what?
  scale_fill_manual(values = farben_ci[plabels], labels = plabels) + guides(fill = guide_legend(override.aes = list(alpha = 1, fill = farben), nrow = 1)) +
  scale_y_continuous(labels = scales::percent)

article_chart <- basechart + sztheme_lines +
  scale_x_date(date_labels = "%B %y", limits = as.Date(c(startDatum, NA)), expand = c(0, 0))
mobile_chart <- basechart + sztheme_lines + sztheme_lines_mobile  +
  scale_x_date(date_labels = "%m.%y", limits = as.Date(c(startDatum, NA)), expand = c(0, 0))

article_chart <- ggplotGrob(article_chart)
article_chart$layout$clip[article_chart$layout$name == "panel"] <- "off"
mobile_chart <- ggplotGrob(mobile_chart)
mobile_chart$layout$clip[mobile_chart$layout$name == "panel"] <- "off"

# ggsave(file="data/assets/plot-rolling.png", plot=gt, dpi = 144, units = "in", width = 8.89, height = 5)
ggsave(file="data/assets/longterm-poll-article.png", plot=article_chart, dpi = 144, units = "in", width = 8.89, height = 5)
# ggsave(file="data/assets/longterm-poll-hp.png", plot=article_chart, dpi = 144, units = "in", width = 7.78, height = 4.38)
ggsave(file="data/assets/longterm-poll-mobile.png", plot=mobile_chart, dpi = 144, units = "in", width = 4.45, height = 3.33)

article_chart

