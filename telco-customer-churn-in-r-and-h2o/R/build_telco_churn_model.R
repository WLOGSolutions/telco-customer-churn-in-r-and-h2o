# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (!length(script_path)) { return(".") }
  return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

data_path <- file.path(script_path, "../data")
export_path <- file.path(script_path, "../export")

library(externalpackages)
library(modelbuilder)

loginfo("--> Loading data...")
all_data <- fread(file.path(data_path, "edw_cdr.csv"))
all_data <- all_data[, !c("month", "year"), with = FALSE]
all_data <- all_data[complete.cases(all_data)]
all_data <- all_data[!duplicated(all_data)]

loginfo("--> loaded %s rows", nrow(all_data))

set.seed(1234)

loginfo("--> Cleaning&transforming data...")
all_data[, ind := factor(sample(0:1, size = .N, replace = TRUE, prob = c(0.3, 0.7)),
                         levels = 0:1,
                         labels = c("Test", "Train"))]
all_data[, churn := factor(ifelse(churn == 1, "churn", "nochurn"))]

loginfo("--> done")

nthreads <- as.integer(args$get("nthreads", required = FALSE, default = -1))
max_mem_size <- args$get("max_mem", required = FALSE, default = "4g")

logdebug("------> nthreads:%d, max_mem_size:%s", nthreads, max_mem_size)

h2o_local <- h2o.init(nthreads = nthreads,
                      max_mem_size = max_mem_size)
h2o.removeAll()

h2o_train <- as.h2o(x = all_data[ind == "Train"],
                    destination_frame = "churn_train")

h2o_test <- as.h2o(x = all_data[ind == "Test"],
                   destination_frame = "churn_test")

loginfo("--> Datasets imported into H2O cluster")

predictors <- setdiff(colnames(all_data),
                      c("churn",
                        "customerid"))
churn_var <- "churn"

best_model <- find_best_classifier_model(
    model_quality_measure = "AUC",
    algorithm = "gbm",
    grid_id = "gbm_grid",
    training_frame = h2o_train,
    x = predictors,
    y = churn_var,
    nfolds = 5,
    balance_classes = TRUE,
    distribution  = "bernoulli",
    hyper_params = list(
        ntrees = c(50,
                   100,
                   500
                   ),
        max_depth = c(4,
                      8,
                      16,
                      32)))

h2o.saveModel(best_model$model, path = export_path, force = TRUE)

loginfo("--> Best model exported into export folder")

loginfo("--> Best model with AUC=%s", h2o.auc(best_model$model, xval = TRUE))
loginfo("--> Threshold for min per class accuracy metric = %s", best_model$threshold)

test_preds <- cbind(all_data[ind == "Test"],
                    as.data.table(h2o.predict(object = best_model$model,
                                              newdata = h2o_test))[, .(churn_pred = ifelse(churn > 1 - best_model$threshold,
                                                                                           "churn",
                                                                                           "nochurn"),
                                                                       churn_prob = churn)])

loginfo("--> Scoring test datasets done")

loginfo("Test accuracy: %.3f", test_preds[, mean(churn == churn_pred)])
loginfo("Test precision: %.3f", test_preds[, sum(churn == "churn" & churn_pred == "churn")/(sum(churn == "churn" & churn_pred == "churn") +
                                                                                              sum(churn == "nochurn" & churn_pred == "churn"))])
loginfo("Test recall: %.3f", test_preds[, sum(churn == "churn" & churn_pred == "churn")/(sum(churn == "churn" & churn_pred == "churn") +
                                                                                           sum(churn == "churn" & churn_pred == "nochurn"))])

tree_roc <- pROC::roc(test_preds[, churn], test_preds[, churn_prob])
loginfo("Test AUC: %.3f", pROC::auc(tree_roc))
