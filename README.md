# How to Use This Package

This package has 4 main parts:

1. Scraping
2. Harmonizing
3. Linking
4. Merging

Each of these packages makes use of the package `here`. `here` uses a project's directory to navigate to other files. Therefore, in order to run these scripts, you need to open project "ffsgData" in RStudio. Opening the project "ffsg" will *not* work.

Each of these have their own directory which hold both the source code and the datasets which result from running that source code. In general, you will want to run these scripts in order. When calling Harmonizing or Linking, the code will automatically run the prior scripts.

The linking process generally takes around 45 minutes on my 2 GHz, 8 GB RAM computer. Because of this long run time, the Merging script does *not* automatically run the prior scripts.

# Scraping
Scraping is composed of five scraping scripts and one master script. The master script sources the content of all five scraping scripts. Four of the scraping scripts scrape the police shooting datasets, and the fifth scraping script scrapes the US census. Upon running, each scripts saves its dataset in `R/Scraping/ScrapedFiles`. In the case of the census script, it saves both county and state datasets in `R/Scraping/ScrapedFiles/Populations`. To run all 5 scripts, simply run `MasterScraper.R`

# Harmonizing
Harmonizing is organized slightly differently than Scraping. Harmonizer only has one script, Harmonizer.R, which Harmonizes all 4 datasets (it does nothing to the census datasets). Upon completion, it saves all 4 datasets in a single file `HarmonizedDataSets.RData` in the folder `R/Harmonizing/HarmonizedFiles`. If a new dataset is ever added, it should be relatively straight forward to follow the example of existing datasets in `Harmonizer.R`.


# Linking
Linkage consists of two scripts: `Linker.R` and `ClericalReview.R`. `ClericalReview.R` is a script which lets a user estimate a good threshold for a weight cuttoff. You can run the script, follow the instructions, and get an estimate.

Linkage also consists of `Linker.R`, which is the script that runs the Fellegi and Sunter algorithm to actually find links between the records. It produced two files: `full_classification.RData` and `full_combined_harmonized.RData`. `full_classification` contains the output of running record linkage, which you can read about on page 11 [here](https://cran.r-project.org/web/packages/RecordLinkage/RecordLinkage.pdf). `full_comboined_harmonized` contains a giant dataframe where each of the harmonized datasets is stacked ontop of each other rowwise. The columns each dataset has in common are not duplicated. For the columns that are present in some datasets but not others `NA` is filled in for the rows of the datasets that are missing that column.

# Merging
Merging consists of one file: `Merging.R`. It takes the contents of `full_classification`, which is a set of links between rows in `full_combined_harmonized`, and turns those links into a graph. It then uses that graph to find which sets of records are all linked together, indicating we think they are the same person. It then collapses `full_combined_harmonized` by the sets of linked records by naively choosing the first non-null value it finds to be the representive for that person. It also adds four columsn which indicate which datasets that person was originally found in. It outputs this new, collapsed file in `R/Merging/Merged`.
