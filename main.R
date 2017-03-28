### get config packages, colors, etc
source("tasks/config.R")

### get data, either by scraping or API
source("tasks/scrape-wahlrechtde-umfragen.R")
#source("tasks/api-wahlrechtde-umfragen.R")

# calculate rolling averages and confidence intervals
# four available versions
# 1) basic confidence intervalls: rolling average over 10, confidence error from individual poll
# 2) gaussian version of propagation of uncertainty
# 3) linear version of propagation of uncertainty
# 4) interpolated
# 5) rolling average of latest poll by each institute, linear propagation of uncertainty


### 1) basic confidence intervalls
#source("tasks/calculations-basic-version.R")

### 2) confidence intervalls by using gaussian version of propagation of uncertainty
source("tasks/calculations-gauss-error.R")
### 3) confidence intervalls by using linear version of propagation of uncertainty
#source("tasks/calculations-linear-error.R")

### 4) interpolated confidence intervalls
#source("tasks/calculations-interpolated.R")
#source("tasks/chart-longterm-polls-interpolated.R")
#source("tasks/chart-sunday-polls-interpolated.R")

### 5) rolling average of latest poll by each institute, weighted by number of interviews, linear propagation of uncertainty
source("tasks/calculations-latest_polls_weights.R")


### generate two charts
source("tasks/chart-longterm-polls.R")
source("tasks/chart-sunday-polls.R")

#system("node tasks/buildReadme")
