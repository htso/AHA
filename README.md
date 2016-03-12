# Aha: Unsupervised Learning with Single-Layer Networks

This is an R implementation of Adam Coates' paper on unsupervised learning [1]. 
The name Aha is derived from Adam-Honglak-Andrew, the initial of the three authors, signifying sort of an epiphany that a single layer network could learn as well as
a deep neural net, achieving state-of-the-art result on certain datasets. 

#Installation
To install directly from github, open a terminal, type R, then

    devtools::install_github('htso/AHA')

#Platforms
Tested it on Linux (ubuntu 14.04). Should work on Windows and OS X.

#Dependencies
You need the following packages. To install from a terminal, type 

    install.packages("Rcpp", "LiblineaR", "pixmap", "R.matlab", "R.utils")

#Datasets
In their paper, the algorithm is tested on three datasets : Cifar10, NORB, and STL. I provide the functions to download these datasets directly from the web. But beware that it may take a long time to download certain files, e.g. CIFAR10.

I include a toy dataset, which is small subset of CIFAR10. To load it, just type

    data(tinyCifar10)

#Run
I provide a demo in the /demo subfolder. To run it, 

    setwd(system.file(package="AHA"))
    demo(runscript)

#WARNING
It may take a long time to finish a run, even on the toy dataset. 

[1] Coates, Adam, Andrew Y. Ng, and Honglak Lee. "An analysis of single-layer networks in unsupervised feature learning." International conference on artificial intelligence and statistics. 2011.



