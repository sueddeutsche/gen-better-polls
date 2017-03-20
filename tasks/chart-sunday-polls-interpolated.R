
df_ld <- read.csv("data/data-rolling-average.csv", stringsAsFactors = F, sep = ",", encoding = "utf-8")
df_ci <- read.csv("data/data-ci-values.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")

sunday_data <- df_ld %>% arrange(desc(datum)) %>% filter(datum == datum[1])
sunday_data
sunday_data_ci <- df_ci %>% arrange(desc(datum)) %>% filter(datum == datum[1])
sunday_data_ci <- select(sunday_data_ci, ci_lower, ci_higher)
sunday_data <- cbind(sunday_data, sunday_data_ci)

sunday_data <- sunday_data[order(sunday_data$rolling_average),]

sunday_data <- mutate(sunday_data, y = as.numeric(order(sunday_data$rolling_average, decreasing = T )))

do_basic_table_chart <- function(){
  sundaychart <-  ggplot(data = sunday_data, aes(x = rolling_average, y = -y, xmin = ci_lower, xmax = ci_higher , ymax = -y + 0.3, ymin = -y -0.3, color = partei)) +
    geom_rect(aes(xmin = 0, xmax= ci_lower, fill = partei, color = NA), alpha = .9) +
    geom_rect(aes(fill = partei, color = NA), alpha = .5) + scale_fill_manual(values = farben) +
    geom_point(size = 3)+
    scale_colour_manual(values = farben) +
    coord_cartesian(xlim = c(0, 0.5) ) +
    sztheme_points +
    scale_y_continuous(breaks = - sunday_data$y, labels = sunday_data$partei) +
    scale_x_continuous(labels = scales::percent, position = "top")
  
  article_chart <- sundaychart + geom_label(aes(x = ci_higher,
                                                label = paste0(round(sunday_data$ci_lower*100, digits = 0), "-", round(sunday_data$ci_higher*100, digits = 0), "%")), fill = NA, label.size = 0, hjust = - 0.2, family="SZoSansCond-Light", size = 6.35)
  mobile_chart <- sundaychart + geom_label(aes(x = ci_higher,
                                               label = paste0(round(sunday_data$ci_lower*100, digits = 0), "-", round(sunday_data$ci_higher*100, digits = 0), "%")), fill = NA, label.size = 0, hjust = - 0.1, family="SZoSansCond-Light", size = 6.35)
  plot(article_chart)
  ggsave(file="data/assets/sunday-polls-mobile.png", plot = mobile_chart, units = "in", dpi = 144, width = 4.45, height = 3.0)
  ggsave(file="data/assets/sunday-polls-article.png", plot= article_chart, units = "in", dpi = 144, width = 8.89, height = 3.0)
}

do_basic_table_chart()