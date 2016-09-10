.libPaths("libs")
install.packages("checkpoint")

repo_url <- checkpoint:::getSnapshotUrl(snapshotDate = "2016-09-01")

install.packages(c(
  #showcase required packages
  "data.table",
  "pROC",
  "bit64",
  "logging"),
  repos = repo_url)

#H2O deps
for (pkg in c("methods","statmod","stats","graphics","RCurl","jsonlite","tools","utils")) {
  if (!(pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
}

install.packages("h2o", 
                 type = "source", 
                 repos = (c("http://h2o-release.s3.amazonaws.com/h2o/rel-turing/6/R")))
