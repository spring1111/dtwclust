context("\tGenerics for included classes")

# ==================================================================================================
# setup
# ==================================================================================================

# Original objects in env
ols <- ls()

# ==================================================================================================
# For tsclustFamily and TSClusters
# ==================================================================================================

test_that("Methods for TSClusters objects are dispatched correctly.", {
    # ----------------------------------------------------------------------------------------------
    # initialize first, since the objects created will be used by the other methods
    # ----------------------------------------------------------------------------------------------

    expect_s4_class(
        tsclust_family <- new("tsclustFamily",
                              dist = "sbd",
                              allcent = "pam",
                              preproc = zscore,
                              control = partitional_control()),
        "tsclustFamily"
    )

    expect_s4_class(
        partitional_object <- new("PartitionalTSClusters",
                                  type = "partitional",
                                  k = 4L,
                                  control = partitional_control(),
                                  datalist = data_subset[-2L],
                                  centroids = data_subset[seq(from = 1L, to = 16L, by = 5L)],
                                  cluster = rep(1L:4L, each = 5L)[-2L],
                                  preproc = "zscore",
                                  distance = "sbd",
                                  centroid = "pam",
                                  override.family = TRUE),
        "PartitionalTSClusters"
    )

    expect_s4_class(
        fuzzy_object <- new("FuzzyTSClusters",
                            type = "fuzzy",
                            k = 4L,
                            control = fuzzy_control(),
                            datalist = data_reinterpolated_subset[-2L],
                            centroids = data_reinterpolated_subset[seq(from = 1L, to = 16L, by = 5L)],
                            preproc = "zscore",
                            distance = "sbd",
                            centroid = "fcm",
                            override.family = TRUE),
        "FuzzyTSClusters"
    )

    # extra argument for preproc so that it is used in predict
    expect_s4_class(
        hierarchical_object <- new("HierarchicalTSClusters",
                                   hclust(proxy::dist(data_reinterpolated_subset, method = "L2")),
                                   type = "hierarchical",
                                   k = 4L,
                                   control = hierarchical_control(),
                                   datalist = data_subset[-2L],
                                   centroids = data_subset[seq(from = 1L, to = 16L, by = 5L)],
                                   cluster = rep(1L:4L, each = 5L)[-2L],
                                   preproc = "zscore",
                                   distance = "sbd",
                                   centroid = "pam",
                                   args = tsclust_args(preproc = list(center = FALSE)),
                                   override.family = TRUE),
        "HierarchicalTSClusters"
    )

    # ----------------------------------------------------------------------------------------------
    # clue
    # ----------------------------------------------------------------------------------------------

    expect_identical(clue::as.cl_membership(partitional_object),
                     clue::as.cl_membership(partitional_object@cluster))
    expect_identical(clue::as.cl_membership(fuzzy_object),
                     clue::as.cl_membership(fuzzy_object@cluster))
    expect_identical(clue::as.cl_membership(hierarchical_object),
                     clue::as.cl_membership(hierarchical_object@cluster))

    expect_identical(clue::cl_class_ids(partitional_object),
                     clue::as.cl_class_ids(partitional_object@cluster))
    expect_identical(clue::cl_class_ids(fuzzy_object),
                     clue::as.cl_class_ids(fuzzy_object@cluster))
    expect_identical(clue::cl_class_ids(hierarchical_object),
                     clue::as.cl_class_ids(hierarchical_object@cluster))

    expect_identical(clue::cl_membership(partitional_object),
                     clue::as.cl_membership(partitional_object@cluster))
    expect_identical(clue::cl_membership(fuzzy_object),
                     clue::as.cl_membership(fuzzy_object@cluster))
    expect_identical(clue::cl_membership(hierarchical_object),
                     clue::as.cl_membership(hierarchical_object@cluster))

    expect_false(clue::is.cl_dendrogram(partitional_object))
    expect_false(clue::is.cl_dendrogram(fuzzy_object))
    expect_true(clue::is.cl_dendrogram(hierarchical_object))

    expect_true(clue::is.cl_hard_partition(partitional_object))
    expect_false(clue::is.cl_hard_partition(fuzzy_object))
    expect_true(clue::is.cl_hard_partition(hierarchical_object))

    expect_false(clue::is.cl_hierarchy(partitional_object))
    expect_false(clue::is.cl_hierarchy(fuzzy_object))
    expect_true(clue::is.cl_hierarchy(hierarchical_object))

    expect_true(clue::is.cl_partition(partitional_object))
    expect_true(clue::is.cl_partition(fuzzy_object))
    expect_true(clue::is.cl_partition(hierarchical_object))

    expect_identical(clue::n_of_classes(partitional_object), partitional_object@k)
    expect_identical(clue::n_of_classes(fuzzy_object), fuzzy_object@k)
    expect_identical(clue::n_of_classes(hierarchical_object), hierarchical_object@k)

    expect_identical(clue::n_of_objects(partitional_object), length(partitional_object@cluster))
    expect_identical(clue::n_of_objects(fuzzy_object), length(fuzzy_object@cluster))
    expect_identical(clue::n_of_objects(hierarchical_object), length(hierarchical_object@cluster))

    # ----------------------------------------------------------------------------------------------
    # show
    # ----------------------------------------------------------------------------------------------

    expect_output(show(partitional_object))
    expect_output(show(fuzzy_object))
    expect_output(show(hierarchical_object))

    # ----------------------------------------------------------------------------------------------
    # update
    # ----------------------------------------------------------------------------------------------

    pc_update <- update(partitional_object)
    expect_identical(body(pc_update@family@allcent), body(partitional_object@family@allcent),
                     info = "Updating partitional object with no parameters creates new identical allcent function in family")

    fc_update <- update(fuzzy_object)
    expect_identical(body(fc_update@family@allcent), body(fuzzy_object@family@allcent),
                     info = "Updating fuzzy object with no parameters creates new identical allcent function in family")

    hc_update <- update(hierarchical_object)
    expect_identical(body(hc_update@family@allcent), body(hc_update@family@allcent),
                     info = "Updating hierarchical object with no parameters creates new identical allcent function in family")

    # for artificial update test below
    partitional_object@call <- call("tsclust",
                                    quote(data_subset),
                                    k = 4L,
                                    distance = "sbd",
                                    preproc = quote(zscore))

    expect_true(inherits(update(partitional_object, k = 3L), "TSClusters"),
                info = "Updating a TSClusters object with parameters produces a valid new object")

    # ----------------------------------------------------------------------------------------------
    # plot
    # ----------------------------------------------------------------------------------------------

    expect_error(plot(partitional_object, type = "dendrogram"), "dendrogram.*hierarchical",
                 ignore.case = TRUE, info = "Partitional clusters don't support dendrogram plot")
    expect_error(plot(fuzzy_object, type = "dendrogram"), "dendrogram.*hierarchical",
                 ignore.case = TRUE, info = "Fuzzy clusters don't support dendrogram plot")
    expect_silent(plot(hierarchical_object, type = "dendrogram"))
    expect_true(inherits(plot(hierarchical_object, type = "sc", plot = FALSE), "ggplot"),
                info = "Plotting series and centroids returns a gg object invisibly")
    expect_true(inherits(plot(hierarchical_object, type = "sc", series = data_subset[-1L], plot = FALSE), "ggplot"),
                info = "Plotting series and centroids providing data returns a gg object invisibly")

    # ----------------------------------------------------------------------------------------------
    # predict
    # ----------------------------------------------------------------------------------------------

    expect_identical(predict(partitional_object), partitional_object@cluster,
                     info = "Predicting with partitional clusters and no arguments simply returns existing cluster slot")
    expect_identical(predict(fuzzy_object), fuzzy_object@fcluster,
                     info = "Predicting with fuzzy clusters and no arguments simply returns existing fcluster slot")
    expect_identical(predict(hierarchical_object), hierarchical_object@cluster,
                     info = "Predicting with hierarchical clusters and no arguments simply returns existing cluster slot")

    expect_true(is.integer(predict(partitional_object, newdata = data_subset[1L])),
                info = "Predicting with partitional clusters and newdata returns a new integer index")
    expect_true(is.matrix(predict(fuzzy_object, newdata = data_reinterpolated_subset[1L])),
                info = "Predicting with fuzzy clusters and newdata returns a new matrix of indices")
    expect_true(is.integer(predict(hierarchical_object, newdata = data_subset[1L])),
                info = "Predicting with hierarchical clusters and newdata returns a new integer index")
})

# ==================================================================================================
# as.matrix and as.data.frame for crossdist and pairdist
# ==================================================================================================

test_that("Included as.* methods are dispatched correctly.", {
    crossdist <- proxy::dist(data_reinterpolated_subset, data_reinterpolated_subset)
    expect_true(class(base::as.matrix(crossdist)) == "matrix")
    expect_s3_class(base::as.data.frame(crossdist), "data.frame")
    expect_identical(dim(base::as.matrix(crossdist)), dim(as.data.frame(crossdist)),
                     info = "Changing a crossdist class to matrix/data.frame does not alter dimensions")

    pairdist <- proxy::dist(data_reinterpolated_subset[1L:10L], data_reinterpolated_subset[11L:20L],
                            pairwise = TRUE)
    expect_true(class(base::as.matrix(pairdist)) == "matrix")
    expect_s3_class(base::as.data.frame(pairdist), "data.frame")
    expect_identical(dim(base::as.matrix(pairdist)), dim(as.data.frame(pairdist)),
                     info = "Changing a pairdist class to matrix/data.frame results in equal dimensions")
})

# ==================================================================================================
# clean
# ==================================================================================================

rm(list = setdiff(ls(), ols))
