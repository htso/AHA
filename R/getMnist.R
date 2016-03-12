# getDatasets.R -- download and format the three datasets mentioned in the paper

require(R.utils)

# These four files are
#  1. training images (60,000 x 784)
#  2. training labels (60,000 x 1)
#  3. test images (10,000 x 784)
#  4. test labels (10,000 x 1)
mnist.gz.fnm = c("train-images-idx3-ubyte.gz", "train-labels-idx1-ubyte.gz", 
              "t10k-images-idx3-ubyte.gz", "t10k-labels-idx1-ubyte.gz")

mnist.url = c("http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz",
              "http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz",
              "http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz",
              "http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz")

# download the four mnist files from Yann LeCun's website
getMnistFiles = function(url, fnm, destdir) {
  for ( i in 1:length(url)) {
    rawfullpath = paste(destdir, fnm[i], sep="/")
    download.file(url[i], destfile=rawfullpath, mode="wb")
    gunzip(filename=rawfullpath, overwrite=TRUE)
  }
}

# Convert the binary files into R format
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

