#' ---
#' title: "Scraping population data for Dates and Counties"
#' author: "Vaughn Johnson"
#' date: '`r format(Sys.Date(), "%d %B %Y")`'
#' ---
#' Population data for all years, by region, state and county

#' As of 2019-06-04, the tabulations for race, sex, and origin
#' have not been published by the US census for 2018 or 2019.
#' This means that we have relatively incomplete data for the most
#' recent years. However, we do have total population data for 2018,
#' so we can use the demographic proportions from 2017 to estimate
#' the populations for 2018, 2019
#'
#' The data for 2000-2010 is already in exactly the intercensal
#' format that you would want, so my expectation is that in 2020,
#' we will have a much, much nicer set of tabulations for 2010-2020
#'
#'
#' For the time being, it probably makes the most sense to just continue
#' with the status quo, and not break down the population totals
#' by demographics

library(dplyr)
library(rio)
library(here)

#' Scrape the Census Bureau's website for population data
#'
#' @param county_urls a named list where the names are date ranges
#' and the values are urls to the corresponding census totals
#' @param save_file
#' @return Void. Saves the data to `save_file`.
#' @export

scrape_population_data <- function(county_urls, save_file) {
    expected_date_range = c("2000-2010", "2010-2018")
    given_date_range = names(county_urls)
    date_descrpency = setdiff(expected_date_range, given_date_range)

    if(length(date_descrpency) != 0){
        print("Expected: ")
        print(expected_date_range)
        print("But got: ")
        print(given_date_range)
        print("Double check: ")
        print(date_descrpency)
        stop()
    }

    censuses = list("2000-2010"=read.csv(county_urls["2000-2010"]),
                  "2010-2018"=read.csv(county_urls["2010-2018"]))

    states = list()
    counties = list()

    common_cols = c("SUMLEV",
                    "REGION",
                    "DIVISION",
                    "STATE",
                    "COUNTY",
                    "STNAME",
                    "CTYNAME")

    for (date_range in names(county_urls)) {
        census = censuses[[date_range]]
        cols = colnames(census)
        pop_est_cols_idx = grep("POPESTIMATE", cols)
        pop_est_cols = cols[pop_est_cols_idx]
        pop_rename = gsub("POPESTIMATE", "", pop_est_cols)

        clean_census = census %>%
                    select(c(common_cols, pop_est_cols)) %>%
                    rename_at(pop_est_cols,~pop_rename)

        states[[date_range]] = clean_census %>%
                                filter(COUNTY == 0) %>%
                                distinct()

        counties[[date_range]] = clean_census %>%
                                    filter(COUNTY != 0) %>%
                                    distinct()
    }

    merged_states = states[["2000-2010"]] %>%
                     merge(states[["2010-2018"]], by=common_cols)

    merged_counties = counties[["2000-2010"]] %>%
                    merge(counties[["2010-2018"]], by=common_cols)

    save(merged_states,   file = file.path(save_file, "StatePop.RData"))
    save(merged_counties, file = file.path(save_file, "CountyPop.RData"))
}
