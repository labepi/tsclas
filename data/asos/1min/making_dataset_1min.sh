#!/bin/bash

# time interval 
time_int_l=( "1 min" "5 min" "10 min" "15 min" )

# NOTE: making timespan as an argument, to run separated processes
time_span=$1

# time span
#time_span_l=( "1day" "1week" "2week" "3week" "1month" )
#for time_span in "${time_span_l[@]}"
#do

    if [ $time_span = "1day" ]
    then
        myto="2020-01-01 23:59:00"
    elif [ $time_span = "1week" ]
    then
        myto="2020-01-07 23:59:00"
    elif [ $time_span = "2week" ]
    then
        myto="2020-01-14 23:59:00"
    elif [ $time_span = "3week" ]
    then
        myto="2020-01-21 23:59:00"
    elif [ $time_span = "1month" ]
    then
        myto="2020-01-31 23:59:00"
    fi
 
    for time_int in "${time_int_l[@]}"
    do       
	    echo "SETUP" "$time_int" "$myto" "$time_span"
	    Rscript making_dataset_1min.R "$time_int" "$myto" "$time_span"
    done
#done

