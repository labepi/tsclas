# tsclas

Classification of IoT data with ordinal patterns transformations.

# Description

In this project a classification of IoT time series based on the class
separability analysis of their ordinal patterns tfransformation is
proposed.

# Folders and Files

- data/ 
    
    - This directory contains the IoT related data used for the classification.

- classify.R
    - The main classification script. It contains the final steps for the proposed classification.

- classify.sh
    - A script for automatizing the classification call.

- config.R
    - Some configurations used for the classification.
    
- features.R
    - A script for computing the features used.

- find_tau.R
     - The methods to find the best tau for a given D, according to the most separable classes in the CCEP.

- includes.R
    - The required packages.

- README.md
    - This readme.

- utils.R
    - Some utility functions.

# Datasets considered

- data/asos/
    - the ASOS files, could be the raw data and the pre-computed
      features

- data/asos/1min
    - the ASOS files, for 1-minute time interval

- data/asos/1hour
    - the ASOS files, for 1-hour time interval

