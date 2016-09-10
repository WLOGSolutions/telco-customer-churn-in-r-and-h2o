find_best_model <- function(h2o_grid) {
  best_model <- NULL
  for (model_id in h2o_grid@model_ids) {
    model <- h2o.getModel(model_id)
    model_auc <- h2o.auc(model, xval = TRUE)
    print(sprintf("Model %s got %s AUC", model@model_id, model_auc))
    if (is.null(best_model)) {
      best_model <- list(
        model = model,
        threshold = h2o.find_threshold_by_max_metric(h2o.performance(model, xval = TRUE), 
                                                     "min_per_class_accuracy"),
        thresholds = h2o.performance(model, xval = TRUE))
    } else if (h2o.auc(best_model$model, xval = TRUE) < model_auc) {
      best_model <- list(
        model = model,
        threshold = h2o.find_threshold_by_max_metric(h2o.performance(model, xval = TRUE), 
                                                     "min_per_class_accuracy"),
        thresholds = h2o.performance(model, xval = TRUE))
    }
  }
  return(best_model)
}
