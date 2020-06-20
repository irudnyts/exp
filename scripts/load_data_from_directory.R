library(here)
library(abind)
library(magrittr)

# load_data_from_directory <- function(path, target_size) {
#     
#     classes <- list.dirs(path = path, recursive = FALSE, full.names = TRUE)
#     x <- list()
#     y <- list()
#     
#     for (class in classes) {
#         
#         class_files <- list.files(
#             path = class,
#             full.names = TRUE
#         )
#         class_arrays <- list()
#         
#         for (class_file in class_files) {
#             class_arrays[[class_file]] <- image_load(
#                 path = class_file, target_size = target_size
#             ) %>% image_to_array()
#         }
#         
#         x[[class]] <- abind(class_arrays, along = 0)
#         y[[class]] <- rep(which(class == classes), length(class_files))
#         
#     }
#     
#     list(
#         x = abind(x, along = 1),
#         y = unlist(y)
#     )
#     
# }

load_image <- function(path, target_size) {
    image_load(path = path, target_size = target_size) %>% image_to_array()
}

load_directory <- function(path, target_size) {
    files <- list.files(path = path, full.names = TRUE)
    array_list <- lapply(files, load_image, target_size = target_size)
    abind(array_list, along = 0)
}

load_data_from_directory <- function(path, target_size) {
    
    directoreis <- list.dirs(
        path = path,
        recursive = FALSE,
        full.names = TRUE
    )
    
    array_list <- lapply(directoreis, load_directory, target_size = target_size)
    
    n_observations <- sapply(array_list, function(x) dim(x)[1])
    
    list(
        x = abind(array_list, along = 1),
        y = rep(1:length(directoreis), n_observations)
    )
    
}
