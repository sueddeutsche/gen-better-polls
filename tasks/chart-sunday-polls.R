df_rolling_average_and_error <- read.csv("data/data-rolling-average-and-error.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")

sunday_data <- df_rolling_average_and_error %>% arrange(desc(datum)) %>% filter(datum == datum[1]) %>% select(datum, partei, rolling_average, ci_higher, ci_lower)
sunday_data <- unique(sunday_data)
# Werte für higher und lower runden, damit gezeichnete Fläche den Labels entspricht,
# Werte für rolling_avarage werden nicht gerunden, weil er sonst zu weit aus der Mitte des Intervalls rutscht und außerdem kein Label bekommt
sunday_data$ci_higher <- round(sunday_data$ci_higher, digits = 2)
sunday_data$ci_lower <- round(sunday_data$ci_lower, digits = 2)
# sunday_data$rolling_average <- round(sunday_data$rolling_average, digits = 2)

sunday_data <- sunday_data[order(sunday_data$rolling_average),]
sunday_data <- mutate(sunday_data, y = as.numeric(order(sunday_data$rolling_average, decreasing = T )))

# sunday_data

do_basic_table_chart <- function(){
  sundaychart <-  ggplot(data = sunday_data, aes(x = rolling_average, y = -y, xmin = (ci_lower), xmax = (ci_higher) , ymax = -y + 0.3, ymin = -y -0.3, color = partei)) +
    geom_rect(aes(xmin = 0, xmax= (ci_lower), fill = partei, color = NA), alpha = .9) +
    geom_rect(aes(fill = partei, color = NA), alpha = .5) + scale_fill_manual(values = farben) +
    scale_colour_manual(values = farben) +
    coord_cartesian(xlim = c(0, 0.5) ) +
    sztheme_points +
    scale_y_continuous(breaks = - sunday_data$y, labels = sunday_data$partei) +
    scale_x_continuous(labels = scales::percent, position = "top")
  
  article_chart <- sundaychart +
    geom_label(aes(x = ci_higher,label = paste0(round(sunday_data$ci_lower*100, digits = 0), "-", round(sunday_data$ci_higher*100, digits = 0), "%")), fill = NA, label.size = 0, hjust = - 0.2, family="SZoSansCond-Light", size = 6.35)
  mobile_chart <- sundaychart + 
    geom_label(aes(x = ci_higher,label = paste0(round(sunday_data$ci_lower*100, digits = 0), "-", round(sunday_data$ci_higher*100, digits = 0), "%")), fill = NA, label.size = 0, hjust = - 0.1, family="SZoSansCond-Light", size = 6.35)
  teaser_chart <- sundaychart + sztheme_teaser + theme(panel.grid.major.y = element_blank())
  
  # plot(article_chart)
  ggsave(file="data/assets/sunday-polls-mobile.png", plot = mobile_chart, units = "in", dpi = 144, width = 4.45, height = 3.0)
  ggsave(file="data/assets/sunday-polls-article.png", plot= article_chart, units = "in", dpi = 144, width = 8.89, height = 3.0)
  ggsave(file="data/assets/sunday-polls-teaser.png", plot=teaser_chart, dpi = 72, units = "in", width = 8.89, height = 5.01)
}

do_basic_table_chart()