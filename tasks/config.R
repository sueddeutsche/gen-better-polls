options(scipen = 999)
farben = c("spd" = "#ce1b1b","afd" = "#009dd1","grüne" = "#349f29", "cdu.csu" = "#222222", "linke" = "#cc35a0", "fdp" = "#ffb700")
plabels = c("spd" = "SPD", "afd" = "AFD","grüne" = "Grüne", "cdu.csu" = "CDU/CSU", "linke" = "Die Linke", "fdp" = "FDP")

sztheme_points <- theme(
  strip.background = element_blank(),
  strip.text.y = element_blank(),
  strip.text.x = element_blank(),
  # axis.line.x = element_line(color = "#000000"),
  # axis.text.y = element_blank(),
  axis.text = element_text(family = "SZoSansCond-Light", size = 18),
  axis.ticks = element_blank(),
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  panel.background = element_blank(),
  panel.border = element_blank(),
  panel.grid.major.x = element_line(color = "#eeeeee", size = 0.2),
  # panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  plot.margin = unit(0, "in"),
  legend.position = "none",
  # legend.position = "left",
  # legend.direction = "vertical",
  # legend.key.height = unit(.5, "in"),
  # legend.key.width = unit(2,"in"),
  plot.background = element_blank())

sztheme_lines <- theme(
  strip.background = element_blank(),
  strip.text.y = element_blank(),
  strip.text.x = element_blank(),
  # axis.line =  element_line(colour = "#eeeeee", size = 0.2),
  axis.line.y = element_blank(),
  # axis.text.y = element_blank(),
  # axis.text.x = element_blank(),
  axis.ticks = element_blank(),
  axis.ticks.length = unit(0,"lines"),
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  # axis.ticks.length = unit(.85, "cm"),
  panel.background = element_blank(),
  panel.border = element_blank(),
  panel.grid.major.y = element_line(colour = "#eeeeee", size = 0.4),
  panel.grid.minor.y = element_line(colour = "#eeeeee", size = 0.2),
  panel.grid.major.x = element_line(colour = "#eeeeee", size = 0.4),
  panel.grid.minor.x = element_line(colour = "#eeeeee", size = 0.2),
  panel.spacing = unit(c(0,0,0,0), "lines"),
  plot.background = element_blank(),
  plot.margin = unit(c(0,3.5,0.2,0.2), "lines"),
  legend.position = "none",
  text = element_text(size = 23, family = "SZoSansCond-Light")
)
