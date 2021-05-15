#!/bin/bash

# accuracy and times
echo 'normal'
Rscript analysis_classification_asos_1min.R linear

# all gaps - acc and times
echo 'gaps'
parallel Rscript analysis_classification_asos_1min_gap.R linear {} ::: 10 30 50

# diffs
echo 'diffs'
Rscript analysis_classification_asos_1min_diff.R

