#' ---
#' title: "Scraping data from killedbypolice.net"
#' author: "Ben Marwick"
#' author: "Martina Morris"
#' author: "Jainul Vaghasia"
#' date: '`r format(Sys.Date(), "%d %B %Y")`'
#' ---

#' This file scrapes the police killings data from <https://killedbypolice.net/>.

library(dplyr)
library(glue)
library(readr)
library(tidyr)
library(tidyverse)
library(htmltab)
library(XML)
library(RCurl)
library(rlist)

# assumes current dir is local repo dir.
# Don't need this anymore -- best not to setwd to play nice with sourcing from
# other files. Instead use mydir and paste to save out.
#setwd(paste(mydir, 'Data/Scraping/ScrapedFiles/', sep="/"))

#' Scrape and Parse Killed By Police's online tables
#'
#' @param save_file filename to be saved in /ScrapedFiles/
#' @return Void. Saves the data to `save_file`.
#' @export

bind_named_list <- function(l) {
    result = NULL
    for(name in names(l)) {
        element = data.frame(l[[name]])
        result = rbind(result, element)
    }

    return(result)
}


scrape_KBP_data <- function(save_file) {
    # killed by police, <https://killedbypolice.net/>
    #' Notice the lack of URL argument. This is because
    #' KBP doesn't have one URL that links to
    #' the database
    BASE_URL <- 'http://killedbypolice.net/kbp'

    current_year = as.integer(format(Sys.Date(), "%Y"))
    # Current year is formatted differently
    years = 2013:current_year

    kbp = NULL

    for(year in years) {
        url = paste0(BASE_URL, year)
        html = getURL(url, .opts = list(ssl.verifypeer = FALSE, followlocation = TRUE))
        table = readHTMLTable(html)
        table = bind_named_list(table)

        if(year == 2018) {
            table = table %>% dplyr::rename("Source" = "Soure")
        }

        kbp = rbind(kbp, table)
    }

    save(kbp, file=save_file)
}
