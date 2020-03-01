#' ---
#' title: "Scraping functions for various online repositories"
#' author: "Martina Morris"
#' author: "Vaughn Johnson"
#' date: '`r format(Sys.Date(), "%Y-%m-%d")`'
#' ---

#' A compliation of functions which scrape data from Mapping Police Violence,
#' Killed By Police, Fatal Encounters, and the Census.
#'
#'

#' Always assume we're stating in the ffsg top level directory

#' Get data from Census, KBP, FE, and MPV
#'
#' @return Void. Adds all scraped data to /ScrapedFiles/ dir
#' @exportdocument()

path_to_src = here::here(file.path('R', "Scraping"))

scrape_all_data <- function() {

    # save cleaned copy
    if(!file.exists(file.path(path_to_src, "ScrapedFiles"))) {
        dir.create(file.path(path_to_src, 'ScrapedFiles'), recursive=T)
    }

    #' Census Data
    source(file.path(path_to_src, "MakePopData.R"))
    county_urls = c("2000-2010"="https://www2.census.gov/programs-surveys/popest/datasets/2000-2010/intercensal/county/co-est00int-tot.csv",
                    "2010-2018"="https://www2.census.gov/programs-surveys/popest/datasets/2010-2018/counties/totals/co-est2018-alldata.csv")
    pop_save_dir = file.path(path_to_src, "ScrapedFiles", "Populations")

    if(!dir.exists(pop_save_dir)) {
        dir.create(pop_save_dir)
    }

    scrape_population_data(county_urls, pop_save_dir)



    #' Fatal Encounters
    source(file.path(path_to_src, "MakeFEData.R"))
    doc_id = "1dKmaV_JiWcG8XBoRgP8b4e9Eopkpgt7FL7nyspvzAsE"
    url_tempalte = 'https://docs.google.com/spreadsheets/d/DOC_ID/export?format=tsv'
    fe_url = sub("(*.)DOC_ID(*.)", paste("\\1", doc_id, "\\2", sep=""), url_tempalte)

    fe_save_file = file.path(path_to_src, "ScrapedFiles", "fe.clean.Rdata")
    scrape_FE_data(fe_url, fe_save_file)



    #' Killed By Police
    source(file.path(path_to_src, "MakeKBPData.R"))
    kbp_save_file = file.path(path_to_src, "ScrapedFiles", "KBP.clean.Rdata")
    scrape_KBP_data(kbp_save_file)



    #' Mapping Police Violence
    source(file.path(path_to_src, "MakeMPVData.R"))
    mpv_url = 'https://mappingpoliceviolence.org/s/MPVDatasetDownload.xlsx'
    mpv_save_file = file.path(path_to_src, "ScrapedFiles", "MPV.clean.Rdata")
    scrape_MPV_data(mpv_url, mpv_save_file)



    #' Washington Post
    source(file.path(path_to_src, "MakeWaPoData.R"))
    wapo_save_file = file.path(path_to_src, "ScrapedFiles",
                               "WaPo.clean.Rdata")
    wapo_url = "https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv"
    scrape_WaPo(wapo_url, wapo_save_file)
}


scrape_all_data()
