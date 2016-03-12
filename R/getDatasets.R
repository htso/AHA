# getDatasets.R -- download and format the three datasets mentioned in the paper

library(R.matlab)
library(R.utils)
library(pixmap)

mnist.fnm = c("train-images-idx3-ubyte.gz", "train-labels-idx1-ubyte.gz", 
              "t10k-images-idx3-ubyte.gz", "t10k-labels-idx1-ubyte.gz")

mnist.url = c("http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz",
              "http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz",
              "http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz",
              "http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz")

cifar10 = "http://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz"

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

stl.url = "http://ai.stanford.edu/~acoates/stl10/stl10_matlab.tar.gz"


getMnistFiles = function(url, fnm, destdir) {
  for ( i in 1:length(url)) {
    rawfile = paste(destdir, fnm[i], sep="/")
    download.file(url[i], destfile=, mode="wb")
    gunzip(filename = fnm[i], destname=destdir)
  }
}


# Load the MNIST digit recognition dataset into R
# http://yann.lecun.com/exdb/mnist/
# assume you have all 4 files and gunzip'd them
# creates train$n, train$x, train$y  and test$n, test$x, test$y
# e.g. train$x is a 60000 x 784 matrix, each row is one digit (28x28)
# call:  show_digit(train$x[5,])   to see a digit.
# brendan o'connor - gist.github.com/39760 - anyall.org

read_mnist <- function(fpath) {
  load_image_file <- function(filename) {
    ret = list()
    f = file(filename,'rb')
    readBin(f,'integer',n=1,size=4,endian='big')
    ret$n = readBin(f, 'integer', n=1, size=4, endian='big')
    nrow = readBin(f, 'integer', n=1, size=4, endian='big')
    ncol = readBin(f, 'integer', n=1, size=4, endian='big')
    x = readBin(f, 'integer', n=ret$n*nrow*ncol, size=1, signed=FALSE)
    ret$x = matrix(x, ncol=nrow*ncol, byrow=T)
    close(f)
    return(ret)
  }
  load_label_file <- function(filename) {
    f = file(filename, 'rb')
    readBin(f, 'integer', n=1, size=4, endian='big')
    n = readBin(f, 'integer', n=1, size=4, endian='big')
    y = readBin(f, 'integer', n=n, size=1, signed=F)
    close(f)
    return(y)
  }
  train = load_image_file(paste(fpath, "train-images-idx3-ubyte", sep="/"))
  test = load_image_file(paste(fpath, "t10k-images-idx3-ubyte", sep="/"))
  train$y = load_label_file(paste(fpath,"train-labels-idx1-ubyte", sep="/"))
  test$y = load_label_file(paste(fpath, "t10k-labels-idx1-ubyte", sep="/"))  
  return(list(train=train, test=test))
}

show_digit <- function(arr784, col=gray(12:1/12), ...) {
  X11();image(matrix(arr784, nrow=28)[,28:1], col=col, ...)
}

