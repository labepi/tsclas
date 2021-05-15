#!/bin/bash

# time span
time_span_l=( "1day" "1week" "2week" )

# emb dim
D_l=( 3 4 5 6 )

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )


for span in "${time_span_l[@]}"
do 
    for D in "${D_l[@]}"
    do 
        for int in "${time_int_l[@]}"
        do
            echo $span $D $int
            python3 analysis_predicted.py $span $D $int
        done
    done
done

