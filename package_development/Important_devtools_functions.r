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
# to make use %>%
usethis::use_pipe()

# this allows to install e.g. from bioconductor
setRepositories()
# if it complaines about missing documentation, you may not have run this command
devtools::document() # before check
# turn an R object into a data set as part of the package
# also add description to R/data.R
usethis::use_data(TNT_communities, overwrite = TRUE)
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
  
  # oversampling
  oversampled_keras_binary,
  oversampled_keras_multi,
  oversampled_keras_regression,
  
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
  
  ###### for ranger
  # split merged list into training and test parts
  splitted_input_binary,
  splitted_input_multi,
  splitted_input_regression,
  
  # oversampling
  oversampled_input_binary,
  oversampled_input_multi,
  oversampled_regression,
  
  # running ranger
  parameter_df,
  test_grid,
  internal = TRUE, overwrite = TRUE)

# first command to setup the structure
usethis::use_testthat()
# second command to setup testing in the package
usethis::use_test()
# and this command finally runs the tests
devtools::test()

# the last commit e.g. for a new function allows to bump the version number
git tag -a "0.1"
git push --tags

# how to build own or github packaes from repo in ansible
r --vanilla -e "devtools::check()"
r --vanilla -e "devtools::build()"
r --vanilla -e "devtools::install()"
r --vanilla -e 'devtools::install_github("mikemc/speedyseq")'
