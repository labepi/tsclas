#!/bin/bash

# NOTE: making timespan as an argument, to run separated processes
time_span=$1

time_int="1 hour"

# time span
#time_span_l=( "1day" "1week" "2week" "3week" "1month" )
#for time_span in "${time_span_l[@]}"
#do

    if [ $time_span = "1month" ]
    then
        myto="2020-01-31 23:59:00"
    elif [ $time_span = "2month" ]
    then
        myto="2020-02-29 23:59:00"
    elif [ $time_span = "3month" ]
    then
        myto="2020-03-31 23:59:00"
    fi
 
	echo "SETUP" "$time_int" "$myto" "$time_span"
	Rscript making_dataset_1hour.R "$time_int" "$myto" "$time_span"
#done

