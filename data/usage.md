
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




