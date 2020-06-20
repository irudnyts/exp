library(here)

dir.create(path = here("data/cat/"))
dir.create(path = here("data/dog/"))

cats <- list.files(path = "data/train/", pattern = "cat", full.names = TRUE)
dogs <- list.files(path = "data/train/", pattern = "dog", full.names = TRUE)

file.copy(
    from = sample(x = cats, size = 1000),
    to = here("data/cat/")
)

file.copy(
    from = sample(x = dogs, size = 1000),
    to = here("data/dog/")
)
