
source("tasks/config.R")

df_ld <- read.csv("data/data-lastest-average.csv", stringsAsFactors = F, sep = ",", encoding = "utf-8")

sunday_data <- df_ld %>% arrange(desc(datum)) %>% filter(datum == datum[1])
sunday_data <- sunday_data %>% filter(partei %in% c("cdu.csu", "spd", "grüne", "linke", "afd", "fdp"))
sunday_data <- sunday_data[order(sunday_data$rolling_average),]

sunday_data <- mutate(sunday_data, y = as.numeric(order(sunday_data$rolling_average, decreasing = T )))
sunday_data <- mutate(sunday_data, radius = ci_higher-ci_lower)

do_basic_table_chart <- function(){
  sundaychart <-  ggplot(data = sunday_data, aes(x = rolling_average, y = -y, xmin = ci_lower, xmax = ci_higher , ymax = -y + 0.3, ymin = -y -0.3, color = partei)) +
    scale_colour_manual(values = farben) +
    coord_cartesian(xlim = c(0, 0.5) ) +
    sztheme_points +
    scale_y_continuous(breaks = - sunday_data$y, labels = plabels[sunday_data$partei]) +
    scale_x_continuous(labels = scales::percent, position = "top")
  sundaychart <- sundaychart + geom_rect(aes(fill = partei, color = NA), alpha = 0.5) + scale_fill_manual(values = farben)
  # direct.label(sundaychart, first.polygons)
  sundaychart <- sundaychart + geom_point (size = 2)
  article_chart <- sundaychart + geom_label(aes(
    label = paste0("~",round(sunday_data$rolling_average*100, digits = 0), "%")), fill = NA, label.size = 0, hjust = - (sunday_data$ci_higher + 0.3), family="SZoSansCond-Light", size = 6.35)
  mobile_chart <- sundaychart + geom_label(aes(
    label = paste0("~",round(sunday_data$rolling_average*100, digits = 0), "%")), fill = NA, label.size = 0, hjust = - sunday_data$ci_higher, family="SZoSansCond-Light", size = 6.35)
  plot(sundaychart)
  ggsave(file="data/assets/sunday-polls-mobile.png", plot = mobile_chart, units = "in", dpi = 144, width = 4.45, height = 3.0)
  ggsave(file="data/assets/sunday-polls-article.png", plot= article_chart, units = "in", dpi = 144, width = 8.89, height = 3.0)
}

do_basic_table_chart()