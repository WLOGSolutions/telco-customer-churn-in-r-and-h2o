# Showcase: telco customer churn prediction with [GNU R](https://www.r-project.org/) and [H2O](http://h2o.ai/)

Showcase for using H2O and R for churn prediction (inspired by [ZhouFang928 examples](https://github.com/ZhouFang928/sql-server-samples/tree/master/samples/features/r-services/Telco%20Customer%20Churn%20v1).

ZhouFang928 in a blog post [Telco Customer Churn with R in SQL Server 2016](http://blog.revolutionanalytics.com/2016/08/telco-customer-churn-with-r-in-sql-server-2016.html) presented a great analysis of telco customer churn prediction. I found it missed one of my favorite machine-learning library [H2O](http://h2o.ai) in the comparison. This showcase presents how easy it is to use [H2O](http://h2o.ai) library to build very good quality predictive models.

# Prerequisities

I have used R version 3.2.3 with the following R packages:

* [data.table](https://cran.r-project.org/web/packages/data.table/index.html), version 1.9.6
* [h2o](http://www.h2o.ai/download/h2o/r), version 3.10.0.6
* [bit64](https://cran.r-project.org/web/packages/bit64/index.html), version 0.9-5
* [pROC](https://cran.r-project.org/web/packages/pROC/index.html), version 1.8

# Project structure

* **data** - this folder contains CSV file with customers' info. It is a copy of data from ZhouFang928's example.
* **export** - this folder is for saving computing results
* **build_telco_churn_model.R** - R script that does the thing

# Instruction

To run the example just execute `source("build_telco_churn_model.R")`



