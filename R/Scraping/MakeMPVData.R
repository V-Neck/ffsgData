#' ---
#' title: "Scraping data from mappingpoliceviolence.net"
#' author: "Vaughn Johnson"
#' date: '`r format(Sys.Date(), "%d %B %Y")`'
#' ---

#' This file scrapes the police killings data from <https://mappingpoliceviolence.org/>.
library(dplyr)
library(here)

#' Scrape the MPV database
#'
#' @param url URL for MPV spreadsheet
#' @param save_file filename to be saved in /ScrapedFiles/
#' @return Void. Saves the data to `save_file`.
#' @export
scrape_MPV_data <- function(url, save_file) {
    mpv = rio::import(url)
    save(mpv, file=save_file)
}
