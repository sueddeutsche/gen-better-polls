library(dplyr)
library(magrittr)
library(tidyr)
library(ggplot2)
library(directlabels)
library(grid)
source("tasks/config.R")

df_ld <- read.csv("data/data-transformed.csv", stringsAsFactors = F, sep=",", encoding ="utf-8")
sunday_data <- df_ld %>% arrange(desc(datum)) %>% filter(datum == datum[1])
sunday_data <- sunday_data %>% filter(partei %in% c("cdu.csu", "spd", "grüne", "linke", "afd", "fdp"))
sunday_data <- sunday_data[order(sunday_data$rolling_average),]

sunday_data <- mutate(sunday_data, y = as.numeric(order(sunday_data$rolling_average, decreasing = T )))

str(sunday_data)

do_basic_one_line_chart <- function(){
  sundaychart <- sunday_data %>% ggplot(aes(x = rolling_average, y = 0, color = partei)) +
    scale_colour_manual(values = farben) +
    coord_cartesian(xlim = c(0, 0.5) , ylim = c(-.05, .05)) +
    # scale_x_continuous(breaks=c("0","0.05", "0.1", "0.2", "0.3","0.4","0.5")) +
    sztheme_points 
  
  sundaychart <- sundaychart + geom_hline(yintercept = 0, size = 0.2)
  # sundaychart <- sundaychart + geom_vline(xintercept = 0.05, size = 0.2, color = "#aaaaaa") + geom_vline(xintercept = 0.1, size = 0.2,  color = "#aaaaaa") + geom_vline(xintercept = 0.2, size = 0.2, color = "#aaaaaa")+ geom_vline(xintercept = 0.3, size = 0.2,color = "#aaaaaa") + geom_vline(xintercept = 0.4, size = 0.2, color = "#aaaaaa") + geom_vline(xintercept = 0.5, size = 0.2, color = "#aaaaaa")
  sundaychart <- sundaychart + geom_errorbarh(aes(xmax = ci_higher, xmin = ci_lower), alpha = 0.6, height = .005)
}

do_one_line_chart <- function () {
  sundaychart <- do_basic_one_line_chart()
  sundaychart <- sundaychart + geom_rect(aes(xmin = ci_lower, xmax = ci_higher , ymax = 0.01, ymin = -0.01, fill = partei, color = NA), alpha = 0.5) + scale_fill_manual(values = farben)
  sundaychart <- sundaychart + geom_point (size = 2, colour = "#000000")
  sundaychart <- sundaychart + geom_dl(aes(
    label = paste0(round(sunday_data$rolling_average*100, digits = 1), "%")),
    method = list("calc.boxes", dl.trans(y = y-1), qp.labels("x", "left", "right")))
  plot(sundaychart)
  ggsave(file="data/assets/sunday-polls-article.png", plot=sundaychart, units = "in", dpi = 144, width = 8.89, height = 2.5, limitsize = FALSE)
}

do_basic_gant_chart <- function(){
  sundaychart <- sunday_data %>% ggplot(aes(x = rolling_average, y = y, color = partei)) +
    scale_colour_manual(values = farben) +
    coord_cartesian(xlim = c(0, 0.5) , ylim = c(-2, 8)) +
    sztheme_points 
  
  sundaychart <- sundaychart + geom_hline(yintercept = 7, size = 0.2)
  sundaychart <- sundaychart + geom_errorbarh(aes(xmax = ci_higher, xmin = ci_lower), alpha = 0.6, height = .5)
}
do_mobile_gant_chart <- function () {
  sundaychart <- do_basic_gant_chart()
  sundaychart <- sundaychart + geom_point(aes(y = 7), size = 3)
  sundaychart <- sundaychart + geom_label(aes(
    label = paste0(round(sunday_data$rolling_average*100, digits = 1), "%")), fill = NA, label.size = 0, hjust = +1, family="SZoSansCond-Light", size = 6.35)
  # sundaychart <- sundaychart + geom_dl(aes(
  #   label = paste0(round(sunday_data$rolling_average*100, digits = 1), "%")),
  #   method = list("calc.boxes", dl.trans(x = (sunday_data$ci_lower*35)), qp.labels("y", "bottom", "top")))
  sundaychart <- sundaychart + geom_rect(aes(xmin = ci_lower, xmax = ci_higher , ymax = y + 0.6, ymin = y -0.6, fill = partei, color = NA), alpha = 0.5) + scale_fill_manual(values = farben)
  sundaychart <- sundaychart + geom_point (size = 2)
  # sundaychart <- sundaychart + geom_text_repel(label = paste0(round(sunday_data$rolling_average*100, digits = 1), "%"),
  #                                              size = 6.35,
  #                                              family = "SZoSansCond-Light",
  #                                              segment.color = NA,
  #                                              nudge_x = 0,
  #                                              nudge_y = -0.05,
  #                                              point.padding = unit(0.2, "in"))

  plot(sundaychart)
  ggsave(file="data/assets/sunday-polls-mobile.png", plot=sundaychart, units = "in", dpi = 144, width = 4.44, height = 3.00, limitsize = FALSE)
}

do_one_line_chart()
do_mobile_gant_chart()
