df_rolling_average_and_error <- read.csv("data/data-rolling-average-and-error.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")

# set formats
df_rolling_average_and_error$datum <- as.Date(df_rolling_average_and_error$datum, "%Y-%m-%d")
df_rolling_average_and_error$datum <- as.Date(df_rolling_average_and_error$datum, "%Y-%m-%d")
df_rolling_average_and_error$ci_lower <- as.numeric(df_rolling_average_and_error$ci_lower)
df_rolling_average_and_error$ci_higher <- as.numeric(df_rolling_average_and_error$ci_higher)

df_rolling_average_and_error_party <- unique(df_rolling_average_and_error$partei)


latest_values <- arrange(df_rolling_average_and_error, desc(datum)) %>% filter(datum == datum[1])
startDatum <- "2015-06-01"
df_rolling_average_and_error <- filter(df_rolling_average_and_error, datum > startDatum)

# andere Namen für die Linien als das Standardlabel
get_label_value <- function (partei){
  index = match(partei, latest_values$partei)
  label = paste0(round(latest_values$ci_lower[index]*100, digits = 0), "-", round(latest_values$ci_higher[index]*100, digits = 0), "%")
  label = as.character(label)
}

do_special_party <- function(party){
  special_party <- filter(df_rolling_average_and_error, partei == party)
# Diagramm zusammen bauen
  basechart <- ggplot() +
    geom_ribbon(data = df_rolling_average_and_error, aes( x= datum, ymin = ci_lower, ymax = ci_higher, fill = partei, group = partei, color = partei), alpha = .3, size = .1) +
    geom_line(data = df_rolling_average_and_error,aes(x = datum, y = rolling_average, color = partei), alpha = .6, size = .2) +
    geom_dl(data = df_rolling_average_and_error,aes(x = datum, y = rolling_average, label = as.character(get_label_value(partei))), color = farben[df_rolling_average_and_error$partei], method = list(dl.trans(x = x + .1, cex = 1.5, fontfamily="SZoSansCond-Light"),"calc.boxes", "last.bumpup")) +
    geom_ribbon(data = special_party, aes( x= datum, ymin = ci_lower, ymax = ci_higher, fill = partei, color = partei), alpha = .7, size = .1) 
  basechart <- basechart + 
    scale_colour_manual(values = farben[mlabels], labels = NULL, breaks = NULL) +
    scale_fill_manual(values = farben_ci[mlabels], labels = plabels) + guides(fill = guide_legend(override.aes = list(alpha = 1, fill = farben), nrow = 1)) +
    scale_y_continuous(labels = scales::percent, limits = c(0, NA))
  
  article_chart <- basechart + sztheme_lines +
    scale_x_date(date_labels = "%B %y", limits = as.Date(c(startDatum, NA)), expand = c(0, 0))
  mobile_chart <- basechart + sztheme_lines + sztheme_lines_mobile  +
    scale_x_date(date_labels = "%m.%y", limits = as.Date(c(startDatum, NA)), expand = c(0, 0))
  
  article_chart <- ggplotGrob(article_chart)
  article_chart$layout$clip[article_chart$layout$name == "panel"] <- "off"
  mobile_chart <- ggplotGrob(mobile_chart)
  mobile_chart$layout$clip[mobile_chart$layout$name == "panel"] <- "off"
  
  ggsave(file=paste0("data/assets/longterm-poll-article-",party,".png"), plot=article_chart, dpi = 144, units = "in", width = 8.89, height = 5)
  # ggsave(file="data/assets/longterm-poll-hp.png", plot=article_chart, dpi = 144, units = "in", width = 7.78, height = 4.38)
  ggsave(file=paste0("data/assets/longterm-poll-mobile-", party,".png"), plot=mobile_chart, dpi = 144, units = "in", width = 4.45, height = 3.33)
}

do_special_party("Grüne")
