Version 0.5.1

*  Fixed vignette code and modified the README.md 

Version 0.5

*  Vignette added demonstrating a possible workflow using built-in data set
*  Naming patterns changed to open up for users
*  oversample function is now more appropriately called augment function
*  relative abundance is used for filtering
*  ranger regression mtry set to 1/3 of available independent variables as default
*  speedyseq support added for tax_glom

Version 0.4

*  Keras tensorflow classification runs using purrr:pmap including metrics implemented

Version 0.3
    
*  Ranger classification runs using purrr:pmap including metrics implemented
*  Binary classification is now treated as special case of multi class classification and does not utilize specific binary_* functions anymore

Version 0.2
    
*  Implemented functions to prepare data from phyloseq for Machine Learning with ranger and keras
    
Version 0.1

*  Initial version of the package with first phyloseq subsetting functions
