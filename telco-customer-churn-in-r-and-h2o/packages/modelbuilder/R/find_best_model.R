#'@export
find_best_classifier_model <- function(model_quality_measure = "AUC", ...) {
    h2o_grid <- h2o.grid(...)

    best_model <- list(
        model = h2o.getModel(h2o.getGrid(h2o_grid@grid_id,
                                         sort_by = model_quality_measure,
                                         decreasing = TRUE)@model_ids[[1]]))

    best_model$threshold <- h2o.find_threshold_by_max_metric(h2o.performance(best_model$model,
                                                                             xval = TRUE),
                                                             "min_per_class_accuracy")
    return(best_model)
}
