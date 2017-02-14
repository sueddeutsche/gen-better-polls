
df_se <- read.csv("data/data-transformed.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
df_se <- df_se %>% filter(partei %in% c("cdu.csu", "spd", "grüne", "linke", "afd", "fdp"))
df_se$datum <- as.Date(df_se$datum, "%Y-%m-%d")

latest_values <- arrange(df_se, desc(datum)) %>% filter(datum == datum[1])
df_se <- filter(df_se, datum > "2013-09-22")

get_label_value <- function (partei){
  index = match(partei, latest_values$partei)
  label = paste0("~",round(latest_values$rolling_average[index]*100, digits = 0),"%")
}

basechart <-  ggplot(data = df_se, aes(x = datum)) +
  geom_ribbon(aes( ymin = ci_lower, ymax = ci_higher, fill=partei, group=partei), alpha = .5) +
  geom_line(aes(y = rolling_average, color = partei), size = 1, linetype = 3) +
  geom_dl(aes(x = datum, y = rolling_average, label = get_label_value(partei)), color = farben[df_se$partei], method = list(dl.trans(x = x + .2, cex = 1.5, fontfamily="SZoSansCond-Light"),"calc.boxes", "last.bumpup")) #+
basechart <- basechart + 
  scale_colour_manual(values = farben, labels = NULL, breaks = NULL) +
  scale_fill_manual(values = farben, labels = plabels) + guides(fill = guide_legend(override.aes = list(alpha = 1), nrow = 1)) +
  scale_x_date(date_labels = "%Y", limits = as.Date(c("2013-09-22", NA)), expand = c(0, 0)) +
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

