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

sensitivities <- readRDS(
    file = here("runs/cloudml_2020_06_19_123843011/sensitivities.rds")
)

mean(sensitivities[6:10])

