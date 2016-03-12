

library(Rcpp)

data(tinyCifar10)
sourceCpp("inst/Conv105.cpp")

w = 6
stride = 1
K = 200
N_patches = 10000
rseed = 1701
verbose = TRUE

system.time(learner <- create_kmeans_learner(data=dat, K=K, N_patches=N_patches, w=w, stride=stride, rseed=rseed, verbose=verbose))

system.time(train_features <- extract_features(dat, w, stride, learner, 0))

system.time(res <- train_by_kmeans(dat, lbl.In, train_features, C.heur=NULL, svm.type=2, verbose=FALSE))

system.time(test.features <- extract_features(datt, w, stride, learner, 0))

scale.f = res[["scale.f"]]
tfea.norm <- applyScaling2Mat(test.features, scale.f, 2)

datt.norm = tfea.norm[["data.s"]]
mod = res[["lsvm"]]
pred = predict_svm(mod, datt.norm)

calc_accuracy(pred, lbl.Out)
table(pred, lbl.Out)








