# GEN Hackathon - Better Poll Visualization

At the Süddeutsche Zeitung Editor's Lab we were working on a better way to deal with opinion polls. 

In autumn 2017 the next general election will be held. In the months to come, opinion polls play an even more important component of reporting about German politics. 

Traditionally, media outlets are reporting about in a new poll in the following style: `If election would be held today, party x would get y per cent of the votes. This is a deline of z per cent compared to previous week.`

This has two major shortcomings:

## Polling data are blurry

As it is the case with a lot of data: We readers are tempted to take them as a fact - solely due the fact of decimal places. But in fact, polls are a insecurity attached that has mainly two sources:

1. Most of the times, only the key figure is communicated. Statistically, this value is the mean inside a confidence level, that can be interpreted as "In 95 percent the party's result will be between 10 and 15 per cent." 

2. Every polling institute has its own way of conduction its survey: How big is the sample size? How do they weigh different demographics? How do they treat undecided voters or non-voters? Therefore every survey is wrong in its own way. But on an aggregate level they provide valid information about potential voting patterns of the electorate. 

Therefore a smarter way of reporting about opinion polls is to get as many data as possible. 


## Data Source

The most comprehensive overview of German opionion polls can be found on [Wahlrecht.de](http://www.wahlrecht.de), a website about maintained by volunteers. 

## Calculation of confidence intervall

The data on [Wahlrecht.de](http://wahlrecht.de) has information on the party's survey result and the sample size. This offers the opportunity to calculate standard errors (se) and a confidence intervall (ci). 

The corresponding formula: 

se = sqrt(p * (1-p) / n)

se: standard error
p: survey result
n: sample size

With a [significance level of 0.05 and a z-value of 1.96](http://www.sjsu.edu/faculty/gerstman/StatPrimer/t-table.pdf) the confidence intervall can be computed: 

Lower limit: ci_lower = p - 1.96 * [p (1-p)/ n] 
Upper limit: ci_upper = p + 1.96 * [p (1-p)/ n]

## Calculation of a rolling average

In order to offer a single value we compute a rolling average with a lag of 10. This is an easy implementation that can be extended, especially by weighing the individual polls. 











---

---

## Aktuelle Meinungsumfragen

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duo Reges: constructio interrete. Aliter enim explicari, quod quaeritur, non potest. In quibus doctissimi illi veteres inesse quiddam caeleste et divinum putaverunt. Expressa vero in iis aetatibus, quae iam confirmatae sunt. Age sane, inquam.

![Umfrage](https://raw.githubusercontent.com/sueddeutsche/gen-better-polls/master/data/assets/plot-rolling.png)

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duo Reges: constructio interrete. Aliter enim explicari, quod quaeritur, non potest. In quibus doctissimi illi veteres inesse quiddam caeleste et divinum putaverunt. Expressa vero in iis aetatibus, quae iam confirmatae sunt. Age sane, inquam.

### Aktuelle Sonntagsfrage

<img src="https://raw.githubusercontent.com/sueddeutsche/gen-better-polls/master/data/assets/current-polls.png" width="500" />

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duo Reges: constructio interrete. Aliter enim explicari, quod quaeritur, non potest. In quibus doctissimi illi veteres inesse quiddam caeleste et divinum putaverunt. Expressa vero in iis aetatibus, quae iam confirmatae sunt. Age sane, inquam.


_Quelle: http://www.wahlrecht.de_


---

---



### Usage

**Requirements** NodeJS 4+, R 3.3+
**Installation** Ensure you have nodeJs and R installed. Then run `Rscript install.R` in the project folder to install 
the requried packages.

> This project consists of a set of small scripts that may be used independently of each other. @see [tasks directory](./tasks)

To completely build the project run either `Rscript main.R` or `npm start`. This will

- scrape the data from the given website and generate a file `data/data-input-longform.csv`
- perform the statistical transformation and save the result in `data/data-latest-average.csv`
- create a visualization of the transformed data in `data/assets/plot.svg` and
- updates the `README.md` with the latest scraped images and markdown snippets from `data/*.md`

These tasks are also mapped in the `package.json` and may be started using `npm run <task>`

 
#### Task: scraper

To scrape the poll data from www.wahlrecht.de, run `Rscript tasks/scrape-wahlrechtde-umfragen.R`. This will create
a table at `data/data-input.csv`.


#### Task: calculations

`Rscript tasks/scrape-wahlrechtde-umfragen.R` transforms table data in `data/data-input.csv` and
`data/data-latest-average.csv` by our statistical method and stores the following results

- `data/data-transformed.csv` timebased chart
- `data/data-latest-average.csv` current result


#### Task: plot

In order to visualize the data in `data/data-transformed.csv` and `data/data-latest-average.csv`, run the script
`Rscript tasks/charts.R`. This will create above images and store them in `data/assets/`.


### FAQ

- some possible errors may be solved by running the scripts (like main.R) in RStudio, instead of the cli




