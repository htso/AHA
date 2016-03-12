
# train : numeric matrix of training features
# This function scale the training matrix to [-1,1] range if method 1 is chosen,
# and scale to a mean of 0 and a standard deviation of 1 if method 2 is picked.
applyScaling2Mat = function(data, scale.f=NULL, method=1) {
  data.s = matrix(0, nrow=nrow(data), ncol=ncol(data))
  if ( method == 1 ) {
    if ( is.null(scale.f) == TRUE ) {
      vmin = apply(data, 2, min)
      vmax = apply(data, 2, max)
      vrng = vmax - vmin  
    } else {
      vmin = scale.f$vmin
      vrng = scale.f$vrng
    }
    for ( i in 1:ncol(data)) {
      if ( vrng[i] > 0 ) {
        vv = data[,i] - vmin[i]
        data.s[,i] = 2*vv / vrng[i] - 1
      } else {
        data.s[,i] = data[,i]
      }
    }
    scale.f = list(vmin=vmin, vrng=vrng)
  } else if ( method == 2 ) {
    if ( is.null(scale.f) == TRUE ) {
      vave = apply(data, 2, mean, na.rm=TRUE)
      vsd = apply(data, 2, sd, na.rm=TRUE)  
    } else {
      vave = scale.f$vave
      vsd = scale.f$vsd
    }
    for ( i in 1:ncol(data)) {
      if ( vsd[i] > 0 ) {
        vv = data[,i] - vave[i]
        data.s[,i] = vv / vsd[i]
      } else {
        data.s[,i] = data[,i]
      }
    }
    scale.f = list(vave=vave, vsd=vsd)
  } else {
    # No scaling if method is neither 1 nor 2
    data.s = data
  }
  return(list(data.s=data.s, scale.f=scale.f))
}


# This function write the matrix X and label ilbl to a text file 
# using the sparse encoding format defined in SVMLight :
#      label | feature1:value1 feature2:value2 .... featureN:valueN
# X : matrix of size n x p, where n is the no of observations and p the no of features
# ilbl : vector of length n
# fname : name of the output text file
VWSparse.write = function(X, ilbl, fname) {
  nc = ncol(X)
  nr = nrow(X)
  lbl.len = length(ilbl)
  if ( lbl.len != nr ) {
    stop("label length not equal to no of rows.")
  }  
  feat.nm = paste("x", 1:nc, sep="")
  for ( i in 1:nr ) {
    one.line = NULL
    for ( j in 1:nc ) {
      if ( X[i,j] > 0 ) {
        feat = paste(feat.nm[j] , ":", X[i,j], collapse="", sep="")
        one.line = c(one.line, feat) 
      }
    }
    tmp2 = c(ilbl[i], "|", one.line, "\n")
    cat(tmp2, file=fname, fill=FALSE, append=TRUE)
    cat(i, "\t")
  }
}



# dat : data matrix where each row is an image, 
#       each row has 32*32*3 entries.
# ii : index of the rows to plot
plotCifar = function(dat, ii) {
  require(pixmap)
  n = length(ii)
  nr = ceiling(sqrt(n))
  X11(); par(mfrow=c(nr,nr), mar=c(0,0,0,0))
  for ( k in 1:n ) {
    x = dat[ii[k], 1:ncol(dat)]
    # turn x into a matrix of 3 columns, where each column is one color channel
    x1 = matrix(x, ncol=3, byrow=FALSE)
    # each column represents a 2D image
    # the data is arranged in row-major format
    r1 = matrix(x1[,1], ncol=32, byrow=TRUE)
    g1 = matrix(x1[,2], ncol=32, byrow=TRUE)
    b1 = matrix(x1[,3], ncol=32, byrow=TRUE)  
    zz = pixmapRGB(c(r1,g1,b1), nrow=32, ncol=32,
                   bbox=c(-1,-1,1,1))
    plot(zz, axes=FALSE)
  }
}


# x : matrix where rows are observations and columns the features
normize = function(x) {
  ctr = apply(x, 2, mean)
  stds = apply(x, 2, sd)
  x1 = t(t(x) - ctr)
  x2 = t(t(x1) / stds)
  return(list(x=x2, ctr=ctr, stds=stds))
}

# x : matrix where rows are observations and columns the features
whiten = function(x) {
  pp = prcomp(x, center=FALSE, scale=FALSE, retx=TRUE)
  U = pp$rotation # U's columns are the eigenvectors
  ev.sqrt = pp$sdev # these are sqrt of eigenvalues
  x.rot = t(U) %*% t(x) # (3072 x 3072) x t(5000 x 3072) = 3072 x 5000
  x.rot = t(x.rot)
  x.wh =t(t(x.rot) / ev.sqrt )
  return(list(x=x, U=U, ev=ev.sqrt))
}

# x : vector of features
# ctr, stds : the center vector and stdev vector provided 
normize.against = function(x, ctr, stds) {
  return(c((x-ctr)/stds))
}

# x : matrix where rows are observations and columns the features
# U, ev : the matrix of eigenvectors and square root of eigenvalues provided 
whiten.against = function(x, U, ev) {
  x.rot = t(U) %*% x # (3072 x 3072) x t(5000 x 3072) = 3072 x 5000
  return(x.rot / ev )
}

# patch : 1 x N matrix, where there are M rows of image patches, each patch has N columns
# cent : K x N matrix of centroids
# calculate the euclidean distance between each row of patch with each row of cent.
# Ref : Coates, Lee, Ng, Analysis of Single-Layer Networks in Unsupervised Feature Learning, ICML 2011
# fast version
triangle.Kmeans1 = function(patch, cent) {
  n = nrow(cent)
  z.k = NULL
  for ( i in 1:n ) z.k[i] = sqrt(sum((cent[i,] - patch)*(cent[i,] - patch)))
  mu.z = mean(z.k)
  z1 = - z.k + mu.z
  return(pmax(0,z1))
}

# slow version
triangle.Kmeans0 = function(patch, cent) {
  n = nrow(cent)
  # z.k : M x K 
  z.k = t(apply(patch, 1, function(y) apply(cent, 1, function(r) norm(r-y,"2"))))
  mu.z = apply(z.k, 1, mean) # M x 1
  z1 = t(- t(z.k) + mu.z) # M x K
  f.k = matrix(pmax(0, z1), ncol=ncol(z1))
  return(f.k)
}

# Ref : Coates, Lee, Ng, Analysis of Single-Layer Networks in Unsupervised Feature Learning, ICML 2011
hard.Kmeans = function(patch, cent) {
  # z.k : M x K 
  z.k = t(apply(patch, 1, function(y) apply(cent, 1, function(r) norm(r-y,"2"))))
  ix = apply(z.k, 1, which.min)
  f.k = matrix(0, nrow=nrow(z.k), ncol=ncol(z.k))
  for ( i in 1:nrow(f.k)) {
    f.k[i,ix[i]] = 1
  }
  return(f.k)
}

