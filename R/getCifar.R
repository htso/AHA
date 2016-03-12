# getCifar.R -- download and format the three datasets mentioned in the paper

fnm.gz = "cifar-10-matlab.tar.gz"
fnm.tar = "cifar-10-matlab.tar"
fnm = c("data_batch_1.mat",
        "data_batch_2.mat",
        "data_batch_3.mat",
        "data_batch_4.mat",
        "data_batch_5.mat",
        "test_batch.mat",
        "batches.meta.mat")

getCifar10File = function(url, gz.nm, tar.nm, save_dir) {
  require(R.utils)  
  c.url = "http://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz"
  #download.file( url, destfile=gz.nm, mode="wb" )
  gunzip(gz.nm)
  ff = untar(tar.nm, list=TRUE)
  untar(tar.nm, list=FALSE, exdir=save_dir)
  #cvec = lapply(ff, function(ss)unlist(strsplit(ss, split="\\.")))
  #ix = which(sapply(cvec, function(v)length(unlist(v))) > 1)
  ix = c(2,4,5,6,8,9)
  dat = list()
  for ( i in 1:length(ix) ) {  
    dat[[i]] = readMat(con=ff[ix[i]])
  }
  return(dat)
}


readCifar10 = function(save_dir) {
  require(R.matlab)
  require(R.utils)
  matfiles = list.files(path=save_dir, pattern=".mat", full.names=TRUE)
  meta = readMat(con=matfiles[1])
  traindat = list(readMat(con=matfiles[2]),
                  readMat(con=matfiles[3]),
                  readMat(con=matfiles[4]),
                  readMat(con=matfiles[5]),
                  readMat(con=matfiles[6]))
  testdat = readMat(con=matfiles[7])
  return(list(train=traindat, test=testdat, meta=meta))
}










