# getDatasets.R -- download and format the three datasets mentioned in the paper

require(R.matlab)
require(R.utils)

norb.url = c("norb-5x01235x9x18x6x2x108x108-testing-01-cat.mat.gz",
      "norb-5x01235x9x18x6x2x108x108-testing-01-dat.mat.gz",
      "norb-5x01235x9x18x6x2x108x108-testing-01-info.mat.gz",
      "norb-5x01235x9x18x6x2x108x108-testing-02-cat.mat.gz",
      "norb-5x01235x9x18x6x2x108x108-testing-02-dat.mat.gz",
      "norb-5x01235x9x18x6x2x108x108-testing-02-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-01-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-01-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-01-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-02-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-02-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-02-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-03-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-03-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-03-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-04-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-04-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-04-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-05-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-05-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-05-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-06-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-06-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-06-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-07-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-07-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-07-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-08-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-08-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-08-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-09-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-09-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-09-info.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-10-cat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-10-dat.mat.gz",
      "norb-5x46789x9x18x6x2x108x108-training-10-info.mat.gz")




