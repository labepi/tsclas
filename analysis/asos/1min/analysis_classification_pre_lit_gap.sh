#!/bin/bash

# script to analyze the classfication results from literature algorithms

# time span is informed by command line
#time_span_l=( "1day" "1week" "2week" "3week" "1month" )
time_span_l=( "1day" "1week" "2week" "3week" )

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# path
dataset_path='../../../results/asos/1min'

# classifiers
clf_l=( "knn" "randf" "tsf" "rise" )
clf_n=( 7 10 13 16 )

if [ $# -ne 2 ]
then
    echo "inform method: linear/polynomial/spline and gap"
    exit
fi

#method='spline'
method=$1

gap=$2


for time_span in "${time_span_l[@]}"
do
    for time_int in "${time_int_l[@]}"
    do
        # looping in classifiers
        for i in $(seq 0 3)
        do
            alg=${clf_l[i]}
            
            echo -n $alg" "$time_span" "$time_int" "
            
            d_name="res_asos_2020_jan_"$time_span"_sktime_"$alg"_"$method"_gap"$gap".txt"

            #echo $dataset_path/$d_name

            tmp=$(cat $dataset_path/$d_name 2> /dev/null | grep "\_$time_span\_" | \
                grep "\_$time_int" | grep $alg )

            if [ $? -ne 0 ]
            then
                echo 'NA NA NA NA NA NA 0'
                continue
            fi

            #accuracy
            acc=$(cat $dataset_path/$d_name | grep 'FINAL_ACC' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            # times
            time_train=$(cat $dataset_path/$d_name | grep 'TIME_TRAIN' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                awk '{s=($5+$7+$9); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            time_test=$(cat $dataset_path/$d_name | grep 'TIME_TEST' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                awk '{s=($5+$7+$9); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1))" "NR; }')

            echo $acc' '$time_train' '$time_test
 
            
        done
    done
done

