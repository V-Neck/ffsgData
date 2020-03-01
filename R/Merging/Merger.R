library(purrr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(venn)
library(igraph)

path_to_src  = file.path(here::here(), 'R', 'Harmonizing')
path_to_link = file.path(here::here(), 'R', 'Linking')
# source(file.path(path_to_src, 'Linker.R'))

load(file=file.path(path_to_link,
                    "FinalClassification",
                    "full_classification.RData"))

load(file=file.path(path_to_link,
                    "FinalClassification",
                    "full_combined_harmonized.RData"))

link_idx = classification$prediction == 'L'
links = classification$pairs[link_idx, c('id1', 'id2')]
link_graph = graph_from_edgelist(as.matrix(links), directed=F)
linked_ids = groups(components(link_graph, mode="weak"))
linked_ids = linked_ids[unlist(lapply(
    linked_ids, function(x) length(x) > 1))]

linked_sources = lapply(linked_ids,
                        function(x)  combined_harmonized[x, 'source'])

dup_link_idx = unlist(lapply(linked_sources, function(x) any(duplicated(x))))

dup_links      =    linked_ids[ dup_link_idx]
unique_links   = linked_ids[!dup_link_idx]
unique_sources = linked_sources[!dup_link_idx]

sources = unique(combined_harmonized[, 'source'])

for (source in sources) {
    col_name = paste0("in_", source)
    combined_harmonized[col_name] = ifelse(combined_harmonized[, 'source'] == source, TRUE, NA)
}

collaps_vals = function(x) {
    return(x[!is.na(x)][1])
}

# Pad end components
max_comp = length(components(link_graph, mode="weak")$membership)
max_id   = nrow(combined_harmonized['uid'])
end_cap = 1:(max_id - max_comp) + max_comp
combined_harmonized['person'] = c(components(link_graph, mode="weak")$membership,
                                  end_cap)

final_merged = combined_harmonized %>%
                group_by(person) %>%
                summarise_all(collaps_vals) %>%
                mutate(in_mpv  = ifelse(is.na(in_mpv),  0, 1)) %>%
                mutate(in_fe   = ifelse(is.na(in_fe),   0, 1)) %>%
                mutate(in_kbp  = ifelse(is.na(in_kbp),  0, 1)) %>%
                mutate(in_wapo = ifelse(is.na(in_wapo), 0, 1))

save_dir = file.path(path_to_src, 'Merged')

if(!dir.exists(save_dir)) {
    dir.create(save_dir, recursive=T)
}

save(final_merged,
     file = file.path(save_dir, "final_merged.RData"))
