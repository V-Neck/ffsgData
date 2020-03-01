#' ---
#' title: "Scraping data from fatalencounters.org"
#' author: "Jainul Vaghasia"
#' date: '`r format(Sys.Date(), "%d %B %Y")`'
#' ---

#' This file scrapes the police killings data from <https://fatalencounters.org/>.
#'

library(RecordLinkage)
library(dplyr)
library(rio)

# assumes current dir is local repo dir.
# Don't need this anymore -- best not to setwd to play nice with sourcing from
# other files. Instead use mydir and paste to save out.
#setwd(paste(mydir, 'Data/Scraping/ScrapedFiles/', sep="/"))

# fatal encounters, <https://fatalencounters.org/>

# get google sheet
# a few records have unreadable "Year" entries, but the record is read, and year can be retrieved
# from the Date of Injury field.
# note you can retrieve/view parsing problems with problems(fe)

#' Scrape the Census Bureau's website for population data
#'
#' @param url URL for Fatal Encounters spreadsheet
#' @param save_file filename to be saved in /ScrapedFiles/
#' @return Void. Saves the data to `save_file`.
#' @export
scrape_FE_data <- function(url, save_file) {
  fe <- rio::import(url, sep=",")

  ##################################################################################

  # remove non-pertinent columns; these include columns "read me",
  # undocumented columns with only one data point, and a duplicate ID col
  irrelevant_cols = c("Unique ID",
                      "Unique identifier (redundant)",
                      "Unique ID formula",
                      "Were police aware of symptoms of mental illness before interaction? INTERNAL USE, NOT FOR ANALYSIS",
                      "Video")

  fe = fe %>% select(-irrelevant_cols)

  # Clean up column names

  new_names = list("Subject's name" = 'name',
                   "Subject's age" = 'age',
                   "Subject's race" = 'race',
                   "Subject's gender" = 'sex',
                   "URL of image of deceased" = 'URLpic',
                   "Date of injury resulting in death (month/day/year)" = 'dateMDY',
                   "Location of injury (address)" = 'address',
                   "Location of death (city)" ='city',
                   "Location of death (state)" = 'state',
                   "Location of death (zip code)" = 'zip',
                   "Location of death (county)" = 'county',
                   "Full Address" = 'fullAddress',
                   "Latitude" = 'latitude',
                   "Longitude" = 'longitude',
                   "Agency(ies) involved in death" = 'agency',
                    "Cause of death" = 'causeOfDeath',
                    "A brief description of the circumstances surrounding the death" = 'circumstances',
                   "Official disposition of death (justified or other) INTERNAL USE, NOT FOR ANALYSIS" = 'officialDisposition',
            "Link to news article or photo of official document" = 'URLarticle',
                    "Date&Description" = 'Description',
                    "Date (Year)" = 'year')

  # Dp
  fe = fe %>% plyr::rename(new_names)

  # remove data points that are not fact-checked
  fe = fe %>% filter(fe$name != "Items below this row have not been fact-checked.")

  # ID non-police-shootings
  suicidal.causes <- c("Drug overdose",
                       "Murder-suicide",
                       "Murder/suicide",
                       "Ruled an overdose",
                       "Ruled natural causes",
                       "Ruled suicide",
                       "Substance use",
                       "suicide")

  fe$kbp.filter <- ifelse(toupper(fe$`officialDisposition`)
                               %in% toupper(suicidal.causes),
                               "killed by self", "killed by police")

  # Filter out non-police-shootings and write out clean FE csv
  fe.clean <- filter(fe, kbp.filter == "killed by police")

  ## Clean up field entries

  # clean up year, using dateMDY variable -- this will fix the parsing errors
  fe.clean$year <- as.numeric(substr(fe.clean$dateMDY,7,10))

  # fix spelling errors in gender and race
  replacement <- function(x) {
    if (is.na(x)) {
      return(NA)
    }
    if (RecordLinkage::jarowinkler(tolower(x), "female") >= 0.9) {
      return("Female")
    } else if (RecordLinkage::jarowinkler(tolower(x), "male") >= 0.9) {
      return("Male")
    }
  }

  fe.clean$sex <- as.character(lapply(fe.clean$sex, replacement))

  replacement.2 <- function(x) {
    if (is.na(x)) {
      return(NA)
    }
    if (RecordLinkage::jarowinkler(x, "Hispanic/Latino") >= 0.9) {
      return("Hispanic/Latino")
    } else if (RecordLinkage::jarowinkler(x, "European-American/White") >= 0.9) {
      return("European-American/White")
    } else if (RecordLinkage::jarowinkler(x, "African-American/Black") >= 0.9) {
      return("African-American/Black")
    } else if (RecordLinkage::jarowinkler(x, "Asian/Pacific Islander") >= 0.9) {
      return("Asian/Pacific Islander")
    } else if (RecordLinkage::jarowinkler(x, "Middle Eastern") >= 0.9) {
      return("Middle Eastern")
    } else if (RecordLinkage::jarowinkler(x, "Native American/Alaskan") >= 0.9) {
      return("Native American/Alaskan")
    } else if (RecordLinkage::jarowinkler(x, "Race unspecified") >= 0.9) {
      return("Race unspecified")
    }
  }
  fe.clean$race <- as.character(lapply(fe.clean$race, replacement.2))

  save(fe.clean, file=save_file)
}
