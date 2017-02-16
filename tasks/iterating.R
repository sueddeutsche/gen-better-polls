df_ci_lower %>% arrange(partei, desc(datum)) %>% View

# df mit partei, datum, ein institut
d <- df_ci_lower %>% arrange(partei, desc(datum)) %>% select(datum, partei, allensbach) %>% filter(!is.na(allensbach))

# install.packages("iterators)
library(iterators)

# d_it ist die liste über die wir jetzt rüber gehen können
d_it <- iter(d, by = "row")

nextElem(d_it)
nextElem(d_it)
nextElem(d_it)
