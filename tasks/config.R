options(scipen = 999)
farben = c("spd" = "#ce1b1b","afd" = "#009dd1","grüne" = "#349f29", "cdu.csu" = "#000000", "linke" = "#cc35a0")

sztheme_points <- theme(
  strip.background = element_blank(),
  strip.text.y = element_blank(),
  strip.text.x = element_blank(),
  # axis.line.x = element_line(color = "#000000"),
  axis.text.y = element_blank(),
  axis.text.x = element_blank(),
  axis.ticks = element_blank(),
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  panel.background = element_blank(),
  panel.border = element_blank(),
  # panel.grid.major.y = element_line(color = "#000000", size = 0.2),
  panel.grid.major.x = element_blank(),
  panel.grid.minor = element_blank(),
  legend.position = "none",
  plot.background = element_blank())

add_percent <- function(string, suffix = " %") paste0(string, suffix)

sztheme_lines <- theme(
  strip.background = element_blank(),
  strip.text.y = element_blank(),
  strip.text.x = element_blank(),
  axis.line.y = element_blank(),
  # axis.text.y = element_blank(),
  # axis.text.x = element_blank(),
  axis.ticks = element_blank(),
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  # axis.ticks.length = unit(.85, "cm"),
  panel.background = element_blank(),
  panel.border = element_blank(),
  panel.grid.major.y = element_line(colour = "#eae7e7"),
  panel.grid.major.x = element_blank(),
  panel.grid.minor.y = element_line(colour = "#eae7e7"),
  panel.grid.minor.x = element_blank(),
  plot.background = element_blank(),
  plot.margin = unit(c(1,4,1,1), "lines"),
  legend.position = "none",
  text = element_text(size = 18, family = "SZoSans-Regular")
)
