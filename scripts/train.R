# library(here)
library(keras)
library(caret)
library(cloudml)
# use_session_with_seed(seed = 1968) # disables GPU

set.seed(1968) # set seed for CV

# source(here("scripts/load_data_from_directory.R"))
source("load_data_from_directory.R")

data <- load_data_from_directory(
    # path = here("data/"),
    path = gs_data_dir_local("gs://cv-experiment-280812/data"),
    target_size = c(100, 100)
)

data$y <- data$y - 1

n_folds <- 5

folds <- createFolds(
    y = factor(data$y),
    k = n_folds,
    list = TRUE,
    returnTrain = TRUE
)

sensitivities <- numeric(n_folds)

augmented_generator <- image_data_generator(
    zoom_range = 0.2,
    rescale = 1 / 255,
    horizontal_flip = TRUE
)

generator <- image_data_generator(rescale = 1 / 255)



for (fold in folds) {

# fold <- folds$Fold1
    
    train_generator <- flow_images_from_data(
        x = data$x[fold, , ,],
        y = data$y[fold],
        generator = augmented_generator,
        batch_size = 32
    )
    
    valid_generator <- flow_images_from_data(
        x = data$x[-fold, , ,],
        y = data$y[-fold],
        generator = generator,
        batch_size = 32
    )
    
    model <- keras_model_sequential() %>%
        layer_conv_2d(filters = 6, kernel_size = c(5, 5),
                      strides = 1, padding = "same", activation = "relu",
                      input_shape = c(100, 100, 3)) %>% 
        layer_average_pooling_2d(pool_size = c(2, 2), strides = 2) %>% 
        layer_conv_2d(filters = 16, kernel_size = c(5, 5),
                      strides = 1, activation = "relu") %>% 
        layer_average_pooling_2d(pool_size = c(2, 2), strides = 2) %>% 
        layer_conv_2d(filters = 120, kernel_size = c(5, 5),
                      strides = 1, activation = "relu") %>% 
        layer_flatten() %>%
        layer_dense(units = 84, activation = "relu") %>% 
        layer_dense(units = 1, activation = "sigmoid")
    
    model %>% compile(
        loss = loss_binary_crossentropy,
        optimizer = optimizer_rmsprop(),
        metric = "accuracy"
    )
    
    model %>% fit_generator(
        generator = train_generator,
        steps_per_epoch = train_generator$n / train_generator$batch_size,
        epochs = 10,
        validation_data = valid_generator,
        validation_steps = valid_generator$n / valid_generator$batch_size,
        callbacks = callback_early_stopping(patience = 5,
                                            restore_best_weights = TRUE),
    )
    
    valid_generator$batch_size <- valid_generator$n 
    valid_generator$shuffle <- FALSE
    
    predicted <- model %>% 
        predict_generator(generator = valid_generator, steps = 1)
    # predicted <- (apply(predicted, MARGIN = 1, which.max) - 1) %>% as.factor()
    predicted <- ifelse(predicted > 0.5, 1, 0) %>% as.numeric()
    observed <- valid_generator$y
    # confusionMatrix(factor(predicted), factor(observed))
    sensitivities <- c(sensitivities,
                       sensitivity(factor(predicted), factor(observed)))
    
}

saveRDS(object = sensitivities, file = "sensitivities.rds")