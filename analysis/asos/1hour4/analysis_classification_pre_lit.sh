#!/bin/bash

# script to analyze the classfication results from literature algorithms

# time span is informed by command line
time_span_l=( "1month" "2month" "3month" "4month" "5month" "6month" )

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# path
dataset_path='../../../results/asos/1hour4'

# classifiers
clf_l=( "knn" "randf" "tsf" "rise" )

if [ $# -ne 1 ]
then
    echo "inform method: linear/polynomial/spline"
    exit
fi

#method='spline'
method=$1

for time_span in "${time_span_l[@]}"
do
        # looping in classifiers
        for i in $(seq 0 3)
        do
            alg=${clf_l[i]}
            
            echo -n $alg" "$time_span" "
            
            d_name="res_asos_2020_jan_"$time_span"_sktime_"$alg"_"$method".txt"

            #echo $dataset_path/$d_name

            #if [ ! -f $dataset_path/$d_name ]
            #then
            #    #echo "NA NA"
            #    continue
            #fi
            
            tmp=$(cat $dataset_path/$d_name 2> /dev/null | grep "\_$time_span\_" | \
                grep $alg )

            if [ $? -ne 0 ]
            then
                echo 'NA NA NA NA NA NA 0'
                continue
            fi

            #accuracy
            acc=$(cat $dataset_path/$d_name 2> /dev/null | grep 'FINAL_ACC' | \
                grep "\_$time_span\_" | \
                awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} 
                        END {print avg" "sqrt(mean2/(NR-1)); }' 2> /dev/null)

            if [ $? -ne 0 ]
            then
                echo 'NA NA NA NA NA NA 0'
                continue
            fi

            # times
            time_train=$(cat $dataset_path/$d_name | grep 'TIME_TRAIN' | \
                grep "\_$time_span\_" | \
                awk '{s=($5+$7+$9); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            
            if [ $? -ne 0 ]
            then
                echo 'NA NA NA NA NA NA 0'
                continue
            fi
            
            time_test=$(cat $dataset_path/$d_name | grep 'TIME_TEST' | \
                grep "\_$time_span\_" | \
                awk '{s=($5+$7+$9); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1))" "NR; }')

            if [ $? -ne 0 ]
            then
                echo 'NA NA NA NA NA NA 0'
                continue
            fi
            
            echo $acc' '$time_train' '$time_test
 
        done
done



