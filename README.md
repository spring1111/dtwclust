<!-- README.md is generated from README.Rmd. Please edit that file -->
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/dtwclust)](https://cran.r-project.org/package=dtwclust) [![Downloads](http://cranlogs.r-pkg.org/badges/dtwclust)](http://cranlogs.r-pkg.org/badges/dtwclust) [![Travis-CI Build Status](https://travis-ci.org/asardaes/dtwclust.svg?branch=master)](https://travis-ci.org/asardaes/dtwclust) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/asardaes/dtwclust?branch=master&svg=true)](https://ci.appveyor.com/project/asardaes/dtwclust) [![codecov](https://codecov.io/gh/asardaes/dtwclust/branch/master/graph/badge.svg)](https://codecov.io/gh/asardaes/dtwclust)

Time Series Clustering Along with Optimizations for the Dynamic Time Warping (DTW) Distance
===========================================================================================

Time series clustering with a wide variety of strategies and a series of optimizations specific to the Dynamic Time Warping (DTW) distance and its corresponding lower bounds (LBs). There are implementations of both traditional clustering algorithms, and more recent procedures such as k-Shape and TADPole clustering. Functionality can be easily extended with custom distance measures and centroid definitions.

Many of the algorithms implemented in this package are specifically tailored to DTW, hence its name. However, the main clustering function is flexible so that one can test many different clustering approaches, using either the time series directly, or by applying suitable transformations and then clustering in the resulting space. Other implementations included in the package provide some alternatives to DTW.

DTW is a dynamic programming algorithm that tries to find the optimum warping path between two series. Over the years, several variations have appeared in order to make the procedure faster or more efficient. Please refer to the included references for more information, especially Giorgino (2009), which is a good practical introduction.

Most optimizations require equal dimensionality, which means time series should have equal length. DTW itself does not require this, but it is relatively expensive to compute. Other distance definitions may be used, or series could be reinterpolated to a matching length (Ratanamahatana and Keogh, 2004).

Implementations
---------------

-   Partitional, hierarchical and fuzzy clustering
    -   k-Shape clustering
        -   Shape-based distance
        -   Shape extraction for time series
    -   TADPole clustering
-   DTW Barycenter Averaging
-   Keogh's and Lemire's DTW lower bounds
-   Global alignment kernel distance
-   Parallelization for most functions

Installation
------------

The latest version from CRAN can be installed with `install.packages("dtwclust")`.

If you want to test the latest version from github, first install the [prerequisites for R package development](https://support.rstudio.com/hc/en-us/articles/200486498-Package-Development-Prerequisites) (LaTeX is only neccesary if you want to build the vignette) as well as the [remotes package](https://cran.r-project.org/package=remotes), and then type `remotes::install_github("asardaes/dtwclust")`.

If you're wondering about which version to install, take a look at the [CHANGELOG](CHANGELOG.md) file, I try to keep it updated. Check the [Unix](https://travis-ci.org/asardaes/dtwclust) and [Windows](https://ci.appveyor.com/project/asardaes/dtwclust) continuous integration builds to make sure everything is working, but do note that they tend to fail for reasons unrelated to the package's functionality.

Dependencies
------------

-   Partitional procedures are inspired by the `flexclust` package.
-   Hierarchical procedures use the native `hclust` function by default.
-   Cross-distance matrix calculations make use of the `proxy` package.
-   The core DTW calculations can be done by the `dtw` package or the included `dtw_basic` function.
-   Plotting is done with the `ggplot2` package.
-   Parallel computation depends on the `foreach` package, and also uses `bigmemory` for some optimizations.
-   Cluster evaluation can be done with package `clue` or the `cvi` function.

Examples
--------

``` r
# Load series
data(uciCT)

# Reinterpolate series to equal length and normalize
series <- reinterpolate(CharTraj, new.length = max(lengths(CharTraj)))
series <- zscore(series)
```

### Partitional

``` r
# Using DTW with help of lower bounds and PAM centroids
pc.dtwlb <- tsclust(series, k = 20L, 
                    distance = "dtw_lb", centroid = "pam", 
                    seed = 3247, trace = TRUE,
                    control = partitional_control(pam.precompute = FALSE),
                    args = tsclust_args(dist = list(window.size = 20L)))
#> Repetition 1 for k = 20
#> Iteration 1: Changes / Distsum = 100 / 3214.899
#> Iteration 2: Changes / Distsum = 16 / 2684.667
#> Iteration 3: Changes / Distsum = 7 / 2617.178
#> Iteration 4: Changes / Distsum = 0 / 2611.894
#> 
#>  Elapsed time is 2.083 seconds.

plot(pc.dtwlb)
```

![](README-partitional-1.png)

### Hierarchical

``` r
# Based on shape-based distance
hc.sbd <- tsclust(CharTraj, type = "hierarchical", k = 20L, 
                  distance = "sbd", preproc = zscore,
                  control = hierarchical_control(method = "all"),
                  trace = TRUE)
#> 
#> Calculating distance matrix...
#> Performing hierarchical clustering...
#> 
#>  Elapsed time is 0.912 seconds.

# CVIs for HC+SBD
print(cvis <- sapply(hc.sbd, cvi, b = CharTrajLabels))
#>                [,1]         [,2]        [,3]         [,4]         [,5]
#> ARI      0.74050121   0.70344375   0.3428238   0.53026441   0.51258299
#> RI       0.97838384   0.97232323   0.8965657   0.94848485   0.94202020
#> J        0.60223048   0.55948553   0.2369598   0.38405797   0.36923077
#> FM       0.75369221   0.72880580   0.4479318   0.58214036   0.57759590
#> VI       0.22265488   0.21511035   0.5185772   0.34855573   0.34677938
#> Sil      0.58811104   0.61748556   0.4094015   0.53663563   0.56617496
#> SF       0.46587629   0.49555414   0.5949832   0.52241669   0.56892670
#> CH     709.19997325 709.41247992 475.5431233 632.22264816 645.54710628
#> DB       0.65336293   0.61402700   0.5085174   0.75527034   0.46973394
#> DBstar   1.68466461   1.09582372   0.9083771   1.03450267   0.61732267
#> D        0.13801520   0.22382404   0.1308103   0.17967703   0.23163554
#> COP      0.06595574   0.06893191   0.1154545   0.08337437   0.08273567
#>                [,6]        [,7]         [,8]
#> ARI      0.57464085   0.4182468   0.41964584
#> RI       0.95414141   0.9216162   0.92202020
#> J        0.42531646   0.2919708   0.29304029
#> FM       0.62350648   0.5019646   0.50295569
#> VI       0.31972827   0.4460655   0.44257501
#> Sil      0.57151588   0.4741491   0.50197422
#> SF       0.55858504   0.5752352   0.57919722
#> CH     667.89703885 531.7178679 553.99994918
#> DB       0.55074053   0.5464752   0.45639546
#> DBstar   0.64117537   0.7977064   0.66318416
#> D        0.16176333   0.1747119   0.19373597
#> COP      0.07841355   0.1000334   0.09445372

# Best according to variation of information
plot(hc.sbd[[which.min(cvis["VI", ])]])
```

![](README-hierarchical-1.png)

### TADPole

``` r
pc.tadp <- tsclust(series, type = "tadpole", k = 20L,
                   trace = TRUE,
                   control = tadpole_control(dc = 1.5, window.size = 20L))
#> 
#>  Entering TADPole...
#> 
#> Computing lower and upper bound matrices
#> Pruning during local density calculation
#> Pruning during nearest-neighbor distance calculation (phase 1)
#> Pruning during nearest-neighbor distance calculation (phase 2)
#> Pruning percentage = 77.8%
#> Performing cluster assignment
#> 
#> TADPole completed for k = 20 & dc = 1.5
#> 
#>  Elapsed time is 0.355 seconds.

plot(pc.tadp, clus = 1L:4L)
```

![](README-tadpole-1.png)

### Fuzzy

``` r
# Calculate autocorrelation up to 50th lag, considering a list of time series as input
acf_fun <- function(dat, ...) {
    lapply(dat, function(x) as.numeric(acf(x, lag.max = 50L, plot = FALSE)$acf))
}

# Autocorrelation-based fuzzy c-means
fc <- tsclust(series[1L:25L], type = "fuzzy", k = 5L,
              preproc = acf_fun, distance = "L2",
              seed = 123)

fc
#> fuzzy clustering with 5 clusters
#> Using l2 distance
#> Using fcm centroids
#> Using acf_fun preprocessing
#> 
#> Time required for analysis:
#>    user  system elapsed 
#>   0.270   0.000   0.268 
#> 
#> Head of fuzzy memberships:
#> 
#>       cluster_1   cluster_2    cluster_3   cluster_4 cluster_5
#> A.V1 0.04732844 0.017488756 0.0026332040 0.008325063 0.9242245
#> A.V2 0.01457851 0.005171223 0.0007800123 0.002521617 0.9769486
#> A.V3 0.06903925 0.027825249 0.0028701917 0.008586875 0.8916784
#> A.V4 0.14868285 0.349944504 0.0250225304 0.070086628 0.4062635
#> A.V5 0.14642795 0.227211257 0.0242881075 0.074452121 0.5276206
#> B.V1 0.48283724 0.078487945 0.0689223100 0.153092291 0.2166602
```

### (Some) multivariate support

``` r
# Multivariate series, provided as a list of matrices
mv <- CharTrajMV[1L:20L]

# Using GAK distance
mvc <- tsclust(mv, k = 4L, distance = "gak", seed = 390)

# Note how the variables of each series are appended one after the other in the plot
plot(mvc)
```

![](README-multivariate-1.png)

### Parallel support

``` r
require("doParallel")
#> Loading required package: doParallel
#> Loading required package: foreach
#> Loading required package: iterators

# Create and register parallel workers
cl <- makeCluster(detectCores())
registerDoParallel(cl)

# Parallel backend detected automatically
hc <- tsclust(CharTraj, k = 20L,
              distance = "dtw_basic", centroid = "dba",
              seed = 9421, trace = TRUE,
              args = tsclust_args(dist = list(window.size = 20L),
                                  cent = list(window.size = 20L,
                                              max.iter = 15L)))
#>  Elapsed time is 2.91 seconds.

## Returning to sequential calculations
stopCluster(cl)
registerDoSEQ()

## Modifying some plot parameters
plot(hc, labs.arg = list(title = "DBA Centroids", x = "time", y = "series"))
```

![](README-parallel-1.png)

License
=======

GNU General Public License v3.0. See [license](LICENSE) and [copyright](inst/COPYRIGHTS).

This software package was developed independently of any organization or institution that is or has been associated with the author.
