# a_ha.R
# copyright (c) Horace W. Tso
# Oct 1, 2014
# Ref : Adam Coates, Honglak Lee, Andrew Ng, An analysis of single-layer networks 
#       in unsupervised feature learning, Intl Conf on Artificial Intelligence & Stat,
#       2011.

# dat is the output of readCifar10
prepare_Cifar10 = function(dat) {
  tr = dat[["train"]]
  tt = dat[["test"]]
  dat.tr = rbind(tr[[1]]$data, tr[[2]]$data, tr[[3]]$data, tr[[4]]$data, tr[[5]]$data)
  lbl.tr = c(tr[[1]]$labels, tr[[2]]$labels, tr[[3]]$labels, tr[[4]]$labels, tr[[5]]$labels)
  dat.tt = tt$data
  lbl.tt = c(tt$labels)
  return(list(train=dat.tr, lbl.tr=lbl.tr, test=dat.tt, lbl.tt=lbl.tt))
}


create_kmeans_learner = function(data, K, N_patches=10000, w=6, stride=1, rseed=17, verbose=FALSE) {
  # 1. generate training patches for kmenas ==========================================================
  runtime = system.time(Y <- random.cifar.subpatches(data, N_patches, w=w, stride=stride, seed=rseed))  
  if ( verbose ) {
    cat("random.cifar.subpatches runtime :", runtime, "\n" )
    save(w, stride, N_patches, Y, file="step1-random_subpatches.RData")
  } 
  # 2. normalize Y to zero-mean, unit-variance columns ========
  res1 = normize(Y)
  Y.norm = res1$x
  Mu = res1$ctr
  Sigm = res1$stds
  if ( verbose ) {
    cat("normalization completed.\n")
  }
  # 3. whiten y.norm ==========================================
  system.time(res2 <- whiten(Y.norm))
  Y.wh = res2$x
  U = res2$U
  ev = res2$ev
  rm(res1, res2)
  if ( verbose ) {
    cat("whitening completed.\n")
  }
  # 4. use k-means to get the matrix of centroid centers ===================================
  runtime = system.time(km <- kmeans(Y.wh[sample(nrow(Y.wh), nrow(Y.wh), replace=FALSE),], 
                                     centers=K, nstart=1, algorithm="Lloyd", iter.max=1600))
  KM.CTR = km$centers # K x w*w*3 
  if ( verbose ) {
    cat("kmeans runtime :", runtime, "\n")
    save(KM.CTR, K, Y.wh, Mu, Sigm, w, U, ev, file="step4-kmeans.RData")
  }
  param = list(mu=Mu, sigm=Sigm, U=U, ev=ev, km.ctr=KM.CTR)
  return(param)
}


create_RBM_learner = function(data, nHidden, rseed=17, verbose=FALSE) {
  require(rbm)
  
  param = list()
  return(param)
}

extract_features = function(data, w, stride, learner, hard ) {
  require(Rcpp)
  feat = cpp_Conv_Fea(data, w, stride,
                       learner$mu, 
                       learner$sigm, 
                       t(learner$U), 
                       learner$ev, 
                       learner$km.ctr, 
                       hard)
  return(feat)
}

# w : subpatch size, assumed to be a square
# s : stride, or step side of the sliding window
# K : no of features for classification
# N_patches : number of subpatches to extract from raw image
# C.heur : the cost parameter for SVM
# svm.type : SVM type required by LiblineaR
# verbose : print diagnostics and save intermediary results
train_by_kmeans = function(trainset, lbl.train, features, C.heur=NULL, svm.type=2, verbose=FALSE) {
  require(LiblineaR)
  # Second normalization to prepare for SVM ====================
  data.scaled = applyScaling2Mat( features, scale.f=NULL, method=2 )
  Indat.s = data.scaled[["data.s"]]
  if ( verbose ) 
    cat("second normalization done.\n")
  # Use heuristics to estimate the "Cost" of SVM ==========================================
  if ( is.null(C.heur) == TRUE ) {
    if ( nrow(trainset) > 40000 ) {
      m = 40000
    } else {
      m = nrow(trainset)
    }
    runtime = system.time(C.heur <- heuristicC(Indat.s[sample(nrow(Indat.s), m, replace=FALSE),]))
    if ( verbose ) {
      cat("SVM search heuristic done. runtime :", runtime, "\n")
      cat("Cost chosen by heuristic :", C.heur, "\n")
    }  
  }
  # Fast linear SVM ======================================================
  runtime = system.time(lsvm <- LiblineaR(data=Indat.s, target=lbl.train, 
                                          type=svm.type, 
                                          wi=NULL,
                                          cost=C.heur, 
                                          cross=0, 
                                          verbose=TRUE))
  if ( verbose ) {
    cat("LiblineaR runtime :", runtime, "\n")
    save(lsvm, C.heur, lbl.train, data.scaled, file="step9.RData")
  }
  return(list(lsvm=lsvm, scale.f=data.scaled[["scale.f"]]))
}



predict_svm = function(mod, data) {
  return( as.integer(predict(mod, data)$predictions) )
}
  
calc_accuracy = function(pred, act) {
  return( 100*sum(pred == factor(act))/length(pred) )
}

# dat : CIFAR data matrix where each row is one image, and each column consists of the 
#       red, green blue color channel, each channel is a 32 x 32 matrix
# N_patches : number of random subpatch to generate
# w : the width of a square subpatch
# stride : the step size of the subpatch, assumed to be 1 for now
random.cifar.subpatches = function(dat, N_patches, w, stride=1, seed=17) {
  set.seed(seed)
  NN = nrow(dat)
  N = sqrt(ncol(dat) / 3)
  # red first, then green and blue
  ir = 1:(N*N)
  ig = (N*N+1):(N*N*2)
  ib = (N*N*2+1):(N*N*3)
  nr = (N - w)/stride + 1
  nc = (N - w)/stride + 1
  
  Y = matrix(NA, nrow=N_patches, ncol=w*w*3)
  k = 1
  while( k <= N_patches ) {
    u = sample(NN, 1)
    # dat is arranged by row-major convention, thus converting back
    # to a 2D matrix needs to set byrow=TRUE
    rmat = matrix(dat[u, ir], nrow=N, byrow=TRUE)
    gmat = matrix(dat[u, ig], nrow=N, byrow=TRUE)
    bmat = matrix(dat[u, ib], nrow=N, byrow=TRUE)
    i = sample(nr, 1)
    j = sample(nc, 1)
    # Collapsing a submatrix back to a smaller vector
    # NOTE : transpose is needed to conform to row-major convention in dat
    rpatch = as.vector(t(rmat[i:(i+w-1), j:(j+w-1)]))
    gpatch = as.vector(t(gmat[i:(i+w-1), j:(j+w-1)]))
    bpatch = as.vector(t(bmat[i:(i+w-1), j:(j+w-1)]))
    Y[k,] = c(rpatch, gpatch, bpatch)
    k = k + 1
  }
  return(Y)
}










