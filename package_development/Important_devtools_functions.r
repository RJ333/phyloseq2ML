# Access to R Studio Server
ssh -i new_id ubuntu@ip-address -p some_number -L 8787:localhost:8787
# in local browser
localhost:8787

# Important commands for package development
devtools::
  document() # when documentation was updated
  check() # errors, warnings, notes
  test() # ALWAYS!!!!!
  build()
  install()

# Required packages should be added to the DESCRIPTION
usethis::use_package("methods")
usethis::use_package("phyloseq")
usethis::use_package("data.table")
usethis::use_package("keras")
usethis::use_package("tensorflow")
usethis::use_package("ranger")
usethis::use_package("purrr")
# if they are only suggests, use:
usethis::use_package("speedyseq", "Suggests")
usethis::use_package("futile.logger", "Suggests")
usethis::use_package("fastDummies", "Suggests")
usethis::use_package("tidyr", "Suggests")
usethis::use_package("speedyseq", "Suggests")
usethis::use_package("ggplot2", "Suggests")
# to make use %>%
usethis::use_pipe()

# setup a vignette for the package
usethis::use_vignette("Phyloseq2ML-vignette")
usethis::use_vignette("Prepare_phyloseq_for_Machine_Learning")
usethis::use_vignette("Ranger_classification")
usethis::use_vignette("Keras_classification")
usethis::use_vignette("Ranger_regression")
usethis::use_vignette("Keras_regression_multiclass")

# this allows to install e.g. from bioconductor
setRepositories()
# if it complaines about missing documentation, you may not have run this command
devtools::document() # before check
# turn an R object into a data set as part of the package
# also add description to R/data.R
# remove not required columns in package
to_remove <- c("Latitude", "Longitude", "Sed_mass_g", "Tube_weight", "Weight_in",
  "Weight_out", "Freeze_batch", "Color", "Rocks", "Supernatant", "Shells", "Grain_size")
sample_data(TNT_communities) <- sample_data(TNT_communities)[, !names(sample_data(TNT_communities)) %in% to_remove ]
# reorder the sample data
new_order <- c("Udemm", "Cruise_ID", "Station_ID", "Sample_Type", "Experiment", "Area", "Collection", "Munition_near",
  "Biological_replicate", "Depth_cm", "Metagenome", "Weight_loss", "Notes", "Date", "Time", "Direction",
  "Distance_from_mine", "Distance_rel", "Extraction_ID", "Library", "Primerset", "Run", "Library_purpose", "Nucleic_acid",
  "Technical_replicate", "Kit", "Kit_batch", "Extract_concentration_ng_microL", "TNT", "ADNT_2", "ADNT_4", "DANT_2.4", "DANT_2.6",
  "DNT_2.4", "DNT_2.6", "DNB", "TNB", "HMX", "RDX", "Tetryl", "Sum_ng_g", "UXO_sum", "Hg_microg_kg", "Pb206_207_ratio",
  "P_percent", "Ca_percent", "Fe_percent", "Sc45_ppm","V51_ppm", "Cr52_ppm", "Mn55_ppm", "Co59_ppm", "Ni60_ppm","Cu63_ppm", "Zn66_ppm",
  "As75_ppm", "Sr86_ppm", "Zr90_ppm","Mo95_ppm", "Ag107_ppm", "Cd111_ppm", "Sn118_ppm", "Sb121_ppm","Cs133_ppm", "Ba137_ppm",
  "W186_ppm", "Tl205_ppm", "Pb207_ppm","Bi209_ppm", "Th232_ppm", "U238_ppm", "Sum_ppm_ICP_MS", "TIC", "TN", "TC", "TS", "TOC",
  "Microm_001_mean","Microm_63_mean", "Microm_125_mean", "Microm_250_mean", "Microm_500_mean", "Microm_1000_mean")

# make sure we keep all names
setdiff(names(sample_data(TNT_communities)), new_order)
setdiff(new_order, names(sample_data(TNT_communities)))
sample_data(TNT_communities) <- sample_data(TNT_communities)[, new_order]
to_remove2 <- c("Cruise_ID", "Station_ID",  "Udemm",  "Date", "Time", "Experiment", "Area",  "TNT","ADNT_2", "ADNT_4", "DANT_2.4",
"DANT_2.6", "DNT_2.4", "DNT_2.6", "DNB", "TNB", "HMX", "RDX", "Tetryl", "Sum_ng_g")
sample_data(TNT_communities) <- sample_data(TNT_communities)[, !names(sample_data(TNT_communities)) %in% to_remove2 ]

# reduce amount of samples
new_otutable <- head(otu_table(TNT_communities), 40)
TNT_communities <- merge_phyloseq(sample_data(TNT_communities), tax_table(TNT_communities), new_otutable)

usethis::use_data(TNT_communities, overwrite = TRUE)

# This is for internal test data
usethis::use_data(testps,
  taxa_vector_list,
  subset_list_df,
  subset_list_extra,
  response_variables,
  # types of response variables
  responses_multi,
  responses_binary,
  responses_regression,

  # merge the input tables with the response variables
  merged_input_binary,
  merged_input_multi,
  merged_input_regression,

  ###### keras
  # dummify input tables for keras ANN
  keras_dummy_binary,
  keras_dummy_multi,
  keras_dummy_regression,

  # split keras dummies
  splitted_keras_binary,
  splitted_keras_multi,
  splitted_keras_regression,

  # augmentation
  augmented_keras_binary,
  augmented_keras_multi,
  augmented_keras_regression,

  # scaling
  scaled_keras_binary,
  scaled_keras_multi,
  scaled_keras_regression,

  # keras format
  ready_keras_binary,
  ready_keras_multi,
  ready_keras_regression,

  # keras run
  test_keras_binary_training,
  test_keras_multi_prediction,
  test_keras_regression_training,
  test_keras_regression_prediction,

  ###### for ranger
  # split merged list into training and test parts
  splitted_input_binary,
  splitted_input_multi,
  splitted_input_regression,

  # augmentation
  augmented_input_binary,
  augmented_input_multi,
  augmented_regression,

  # running ranger
  parameter_df,
  test_grid,
  test_grid_regress,
  internal = TRUE, overwrite = TRUE)

# first command to setup the structure
usethis::use_testthat()
# second command to setup testing in the package
usethis::use_test()
# and this command finally runs the tests
devtools::test()

# merge feature branches into develop
# new tags for merge requests from develop into master
# the last commit e.g. for a new function allows to bump the version number
# also adjust DESCRIPTION
git tag -a "0.1"
git push --tags

# how to build own or github packaes from repo in ansible
r --vanilla -e "devtools::check()"
r --vanilla -e "devtools::build()"
r --vanilla -e "devtools::install()"
r --vanilla -e 'devtools::install_github("mikemc/speedyseq")'
