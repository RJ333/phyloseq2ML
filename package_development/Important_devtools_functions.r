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
# if they are only suggests, use:
usethis::use_package("speedyseq", "Suggests")
usethis::use_package("futile.logger", "Suggests")
usethis::use_package("fastDummies", "Suggests")
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
  responses_final2,
  responses_regression,
  merged_input_regression,
  merged_input_tables,
  keras_merged,
  keras_merged_regression,
  splitted_keras,
  splitted_keras_regression,
  oversampled_keras,
  oversampled_keras_regression,
  scaled_keras,
  scaled_keras_regression,
  splitted_input,
  splitted_input_regression,
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
