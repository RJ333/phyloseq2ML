# Important commands for package development
devtools::
  check() # errors, warnings, notes
  document() # when documentation was updated
  test() # ALWAYS!!!!!
  build()
  install()

# Required packages should be added to the DESCRIPTION
usethis::use_package("methods") 
# if they are only suggests, use:
usethis::use_package("speedyseq", "Suggests")
# this allows to install e.g. from bioconductor
setRepositories()
# if it complaines about missing documentation, you may not have run this command
devtools::document() # before check
# turn an R object into a data set as part of the package
usethis::use_data(ps_no_control)

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
