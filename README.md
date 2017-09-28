# Showcase: telco customer churn prediction with [GNU R](https://www.r-project.org/) and [H2O](http://h2o.ai/)

Showcase for using H2O and R for churn prediction (inspired by [ZhouFang928 examples](https://github.com/ZhouFang928/sql-server-samples/tree/master/samples/features/r-services/Telco%20Customer%20Churn%20v1)).

ZhouFang928 in a blog post [Telco Customer Churn with R in SQL Server 2016](http://blog.revolutionanalytics.com/2016/08/telco-customer-churn-with-r-in-sql-server-2016.html) presented a great analysis of telco customer churn prediction. I found it missed one of my favorite machine-learning library [H2O](http://h2o.ai) in the comparison. This showcase presents how easy it is to use [H2O](http://h2o.ai) library to build very good quality predictive models.

## Prerequisities

I have used:

* [R](https://www.r-project.org/) in version 3.3.2
* [R Suite](https://github.com/WLOGSolutions/RSuite/blob/master/docs/basic_workflow.md) in version [0.9-211](https://github.com/WLOGSolutions/RSuite/releases/tag/211)
* [H2O](https://www.h2o.ai/) in version [3.15.0.4034](http://h2o-release.s3.amazonaws.com/h2o/master/4034/R)

### Remark for Windows users

Instalation of the packages requires [Rtools](https://cran.r-project.org/bin/windows/Rtools/) compatible with your R version.

## Usage instruction

### Prepare project

Install dependencies for the project

```bash
rsuite proj depsinst
```

It will result in the following output

```
2017-09-23 20:39:18 INFO:rsuite:Detecting repositories (for R 3.3)...
2017-09-23 20:39:20 WARNING:rsuite:Project is configured to use non reliable repositories: S3. You should use only reliable repositories to be sure of project consistency over time.
2017-09-23 20:39:20 INFO:rsuite:Will look for dependencies in ...
2017-09-23 20:39:20 INFO:rsuite:.          MRAN#1 = http://mran.microsoft.com/snapshot/2017-09-23 (win.binary, source)
2017-09-23 20:39:20 INFO:rsuite:.            S3#2 = http://h2o-release.s3.amazonaws.com/h2o/master/4034/R (source)
2017-09-23 20:39:20 INFO:rsuite:Collecting project dependencies (for R 3.3)...
2017-09-23 20:39:20 INFO:rsuite:Resolving dependencies (for R 3.3)...
2017-09-23 20:39:44 INFO:rsuite:Detected 29 dependencies to install. Installing...
2017-09-23 20:43:47 INFO:rsuite:All dependencies successfully installed.
```

Build custom packages

```bash
rsuite proj build
```

You should get the following output

```
2017-09-23 20:48:46 INFO:rsuite:Installing externalpackages (for R 3.3) ...
2017-09-23 20:48:51 INFO:rsuite:Installing modelbuilder (for R 3.3) ...
2017-09-23 20:48:57 INFO:rsuite:Successfuly build 2 packages
```

### Train and evaluate models

Run model training and evaluation 

```bash
Rscript.exe R\build_telco_churn_model.R --nthreads=4 --max-mem="4g"
```

Please note that script has two parameters:

* *nthreads* - number of threads to be used with -1 (all) as default
* *max_mem* - maximum memory size for H2O with 4g as default

### Check results

After succesful model building you can find it (in H2O format) in folder `export`. It can be loaded in H2O Flow for further inspection.

## Approach

I decided to go with Gradient Boosting Models. To select best model I used *grid search* for such parameters:

* number of trees: 50, 100, 500
* max tree depth: 4, 8, 16, 32 

Best model was selected using AUC metric -- resulting in 100 trees with max depth equals 16.
After model building I optimized threshold to maximize minimum per class accuracy. 

## Obtained results

Best model (with threshold selected to maximize min per class classification error) gave following results on  test dataset:

* **AUC** = 0.949
* **Accuracy** = 0.879
* **Precision** = 0.420
* **Recall** = 0.848

## Performance issues

Computation involved validating (using 5-fold cross validation) 12 GBM models with different parameters.
On my laptop (Intel i7,  8GB RAM, Windows 10) it took around 25 minutes. Using Amazon's EC2 c4.4xlarge instance the time droped to around 14-15 minutes.

## Good practices 

1. Always install packages for each project separately. [R Suite](https://github.com/WLOGSolutions/RSuite) solution makes it for you.
2. Select best model with any parametr tunning procedure.
3. Do not forget to optimize threshold.
4. Use logging instead of `print` function.

# Project structure description

## Project structure

Folders:

* **data** - this folder contains CSV file with customers' info. It is a copy of data from ZhouFang928's example.
* **export** - this folder is for saving computing results (currently final model is stored there)
* **R** - master scripts
* **packages**
    * **externalpackages** - dummy package to maintain 3rd party packages dependencies 
    * **modelbuilder** - package that delivers funciton that builds GBM models 
