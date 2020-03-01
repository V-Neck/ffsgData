#' Vaughn Johnson
#' 2019-02-19
#' Clerical Review System
#'
#' This package always assumes you're in
#' the top level directory for the package
#' ie, where ffsg.Rproj is kept
#' 
#' To use, run the program, and follow the prompt. If there are
#' too many to count, don't worry, just push enter
#' You'll be shown which pairs are returned from a 
#' sample of 500 rows of the original dataset.
#' You can control how many times you sample 500 rows by
#' changing the value of "k"
#' 
#' You can control how fine toothed your search of threshold
#' values is by changing "search_space"

library(plyr)
library(dplyr)
library(here)
library(RecordLinkage)

path_to_src = here::here(file.path('R', 'Harmonizing'))
source(file.path(path_to_src, "Harmonizer.R"))

load(file.path(path_to_src,
               "HarmonizedFiles",
               "HarmonizedDataSets.RData"))

common_cols = Reduce(intersect, list(colnames(kbp_harmonized),
                                     colnames(fe_harmonized),
                                     colnames(mpv_harmonized),
                                     colnames(wapo_harmonized)))

colinear = c("aka", 'name', 'date', 'str_age')

combined_harmonized = plyr::rbind.fill(kbp_harmonized,
                                       fe_harmonized,
                                       mpv_harmonized,
                                       wapo_harmonized) %>%
                                       select(common_cols) %>%
                                       select(-colinear)

# Renders a data frame which 
# displays the candidate pairs the user
# can see and compare
display_matches = function(classifyObject) {
    links = classifyObject$prediction == 'L'
    num_matches = sum(links)
    ncols = ncol(classifyObject$data)
    df = data.frame(matrix(nrow = 3 * num_matches, ncol= ncols))
    colnames(df) = colnames(classifyObject$data)
    left  = classifyObject$pairs[links, 'id1']
    right = classifyObject$pairs[links, 'id2']
    idx1 = 3 * (0:(num_matches -1))
    idx2  = idx1 + 1
    blank = idx1 + 2

    df[idx1  + 1, ] = classifyObject$data[left, ]
    df[idx2  + 1, ] = classifyObject$data[right, ]
    df[blank + 1, ] = c(rep("", ncols))
    return(df)
}

# How many times do you generate a new sample?
k = 10
# How many values of threshold do you inspect?
search_space = 10

# The number of "positives" identified by the algorithm
# Rows are the iteration (i.e. ,which time we resampled 500 rows)
# Cols are the different values of threshold
n_matches      = matrix(ncol=search_space, nrow=k)
# The number of "trues" identified by a person
# Rows are the iteration (i.e. ,which time we resampled 500 rows)
# Cols are the different values of threshold
n_true_matches = matrix(ncol=search_space, nrow=k)

for (iteration in 1:k) {
    # Sample 500 random observations in
    # the large, combined sample
    comb_sample = combined_harmonized %>% sample_n(500)

    # Find the distance vectors
    blank_dedup_object = compare.dedup(comb_sample,
                                       blockfld = c('state'),
                                       strcmp = T)
    

    # Run EM to estimate m and u in order to 
    # estiamte w, which we can then use to threshold
    # our observations as match or non-match
    EM_dedup_object = emWeights(blank_dedup_object)

    for (i in 1:search_space) {
        # Begin ludicrously low
        threshold = 3*i - 15
        classify  = emClassify(EM_dedup_object, threshold.upper=threshold)
        # Show possible pairs to the reviewing clerk
        print.data.frame(display_matches(classify))
        # Record the number of "positives" returned by the algorithm
        n_matches[iteration, i] = sum(classify$prediction == 'L')
        # Record the number of true pairs shown
        n_true_matches[iteration, i] = readline(prompt="How many true matches: ")
    }
}

print("Threshold values (0th column correpsonds to first value in vector")
print(3*(1:search_space) -15)
print(n_matches)
print(n_true_matches)

save.image("love")
