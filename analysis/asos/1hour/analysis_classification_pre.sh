#!/bin/bash

# script to analyze the classfication results

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi


D_l=( 3 4 5 6 )

# time span is informed by command line
time_span_l=( "1month" "2month" "3month" "4month" "5month" "6month" )

# path
dataset_path='../../../results/asos/1hour'


for D in "${D_l[@]}"
do
    for time_span in "${time_span_l[@]}"
    do
            echo -n $D" "$time_span" "
            d_name="res_asos_2020_jan_"$time_span"_D"$D".txt"

            tmp=$(cat $dataset_path/$d_name 2> /dev/null | grep FINAL | \
                grep "\_$time_span\_" )
            
            if [ $? -ne 0 ]
            then
                #echo '0 0 0 0 0 0 0'
                echo 'NA NA NA NA NA NA 0'
                continue
            fi

            # acc
            acc=$(cat $dataset_path/$d_name | grep 'FINAL_ACC' | \
                grep "\_$time_span\_" | \
                awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            # times
            time_train=$(cat $dataset_path/$d_name | grep 'TIME_TRAIN' | \
                grep "\_$time_span\_" | \
                awk '{s=($5+$7+$9+$11+$13); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            time_test=$(cat $dataset_path/$d_name | grep 'TIME_TEST' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                awk '{s=($5+$7+$9); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1))" "NR; }')
            
            echo $acc' '$time_train' '$time_test

#            #cat  | grep FINAL | grep "_$time_int"
#
#            acc=$(cat $dataset_path/$d_name | grep FINAL | \
#                awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')
#
#            echo $acc
 
    done
done

