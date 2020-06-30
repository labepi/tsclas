# class_iot

Classification of IoT data with ordinal patterns transformations.

# Description

In this project a classification of the Collaborative IoT time series is proposed, based on the knowledge extracted from a set of reliable time series.

These reliable time series is the set of airport weather stations from several parts of the world.

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

- asos/
    - the ASOS files, could be the raw data and the pre-computed
      features

- montori/
    - the IoT data files used for the Montori et al. paper

- anomaly/
    - the dataset for anomaly detection from botnet attacks on IoT
      devices

- thingspeak
    - our compiled version of the thingspeak IoT datasets

