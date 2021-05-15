#!/bin/bash

# time span
time_span_l=( "1month" "2month" "3month" "4month" "5month" "6month" )

# emb dim
D_l=( 3 4 5 6 )


for span in "${time_span_l[@]}"
do 
    for D in "${D_l[@]}"
    do 
        #for int in "${time_int_l[@]}"
        #do
            echo $span $D $int
            python3 analysis_predicted.py $span $D 
        #done
    done
done

