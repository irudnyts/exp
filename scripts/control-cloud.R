library(keras)
library(cloudml)
library(here)

cloudml::gcloud_init()

cloudml::gs_rsync(
    source = here("data/"),
    destination = "gs://cv-experiment-280812/data",
    recursive = TRUE
)

setwd(here("scripts/"))

cloudml_train(file = here("scripts/train.R"),
              master_type = "standard_p100", region = "europe-west1")

setwd(here())

job_collect()