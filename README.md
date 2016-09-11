# Showcase: telco customer churn prediction with [GNU R](https://www.r-project.org/) and [H2O](http://h2o.ai/)

Showcase for using H2O and R for churn prediction (inspired by [ZhouFang928 examples](https://github.com/ZhouFang928/sql-server-samples/tree/master/samples/features/r-services/Telco%20Customer%20Churn%20v1)).

ZhouFang928 in a blog post [Telco Customer Churn with R in SQL Server 2016](http://blog.revolutionanalytics.com/2016/08/telco-customer-churn-with-r-in-sql-server-2016.html) presented a great analysis of telco customer churn prediction. I found it missed one of my favorite machine-learning library [H2O](http://h2o.ai) in the comparison. This showcase presents how easy it is to use [H2O](http://h2o.ai) library to build very good quality predictive models.

## Prerequisities

I have used R version 3.2.3 with the following R packages:

* [data.table](https://cran.r-project.org/web/packages/data.table/index.html), version 1.9.6
* [h2o](http://www.h2o.ai/download/h2o/r), version 3.10.0.6
* [bit64](https://cran.r-project.org/web/packages/bit64/index.html), version 0.9-5
* [pROC](https://cran.r-project.org/web/packages/pROC/index.html), version 1.8

## Usage instruction

1. Install packages by running `source("install_packages.R")`
2. Train and evaluate model by running `source("build_telco_churn_model.R")`

## Approach

I decided to go with Gradient Boosting Models. To select best model I used *grid search* for such parameters:

* number of trees: 50, 100, 500
* max tree depth: 4, 8, 16, 32 

Best model was selected using AUC metric -- resulting in 100 trees with max depth equals 16.
After model building I optimized threshold to maximize minimum per class accuracy. 

## Obtained results

Best model (with threshold selected to maximize min per class classification error) gave following results on  test dataset:

* **AUC** = 0.947
* **Accuracy** = 0.866
* **Precision** = 0.395
* **Recall** = 0.875

## Performance issues

Computation involved validating (using 5-fold cross validation) 6 GBM models with different parameters.
On my laptop (Intel i7,  8GB RAM, Windows 10) it took around 25 minutes. Using Amazon's EC2 c4.4xlarge instance the time droped to around 14-15 minutes.

## Good practices 

1. Always install packages for each project separately.
2. Select best model with any parametr tunning procedure.
3. Do not forget to optimize threshold.

# Project structure description

## Project structure

Folders:

* **data** - this folder contains CSV file with customers' info. It is a copy of data from ZhouFang928's example.
* **libs** - this folder contains packages installed by `install_packages.R`
* **export** - this folder is for saving computing results (currently final model is stored there)

Files:

* **install_packages.R** - R script that installs packages into local `libs` folder
* **build_telco_churn_model.R** - R script that does the thing
* **find_best_model.R** - utility function that does grid search and returns best model with the optimal threshold.
