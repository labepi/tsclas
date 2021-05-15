#!/bin/bash

echo 'class asos 1min'
./analysis_classification_pre.sh > res_partial_asos_1min.txt

echo 'class sktime asos 1min'
./analysis_classification_pre_lit.sh linear > res_partial_asos_1min_literature_linear.txt

echo 'class asos 1min gaps'
parallel "./analysis_classification_pre_gap.sh {} > res_partial_asos_1min_gap{}.txt" ::: 10 30 50

echo 'class sktime asos 1min gaps'
parallel "./analysis_classification_pre_lit_gap.sh linear {} > res_partial_asos_1min_literature_linear_gap{}.txt" ::: 10 30 50

echo 'class asos 1min diff'
./analysis_classification_pre_diff.sh > res_partial_asos_1min_diff.txt

