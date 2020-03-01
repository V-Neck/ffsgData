#' ---
#' title: "Scraping data from washingtonpost.com"
#' author: "Vaughn Johnson"
#' date: '`r format(Sys.Date(), "%d %B %Y")`'
#' ---

#' This file scrapes the police killings data from <https://www.washingtonpost.com/graphics/2019/national/police-shootings-2019/>.
library(dplyr)
library(rio)
library(here)

#' Scrape the MPV database
#'
#' @param url URL for MPV spreadsheet
#' @param save_file filename to be saved in /ScrapedFiles/
#' @return Void. Saves the data to `save_file`.
#' @export
scrape_WaPo <- function(url, save_file) {
    wapo = rio::import(url)
    save(wapo, file=save_file)
}
