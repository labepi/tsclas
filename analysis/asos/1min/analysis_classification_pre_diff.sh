#!/bin/bash

# script to analyze the classfication results

D_l=( 3 4 5 6 )

# time span is informed by command line
#time_span_l=( "1day" "1week" "2week" "3week" "1month" )
time_span_l=( "1day" "1week" "2week" "3week" )

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# path
dataset_path='../../../results/asos/1min'


for D in "${D_l[@]}"
do
    for time_span1 in "${time_span_l[@]}"
    do
    for time_span2 in "${time_span_l[@]}"
    do
        for time_int in "${time_int_l[@]}"
        do
            d_name="res_asos_2020_jan_"$time_span1"_"$time_span2"_diff_D"$D".txt"
            #cat  | grep FINAL | grep "_$time_int"

            tmp=$(cat $dataset_path/$d_name 2> /dev/null | grep FINAL | \
                grep "\_$time_span1\_" | grep "\_$time_span2\_" | \
                grep "\_$time_int " )
            
            if [ $? -ne 0 ]
            then
                #echo '0 0 0 0 0 0 0'
                #echo 'NA NA NA NA NA NA 0'
                continue
            fi
            
            #echo '>>'$tmp
            #exit

            echo -n $D" "$time_span1" "$time_span2" "$time_int' '
            
            #echo 'NA NA NA NA NA NA 0'
            #continue

            # acc
            acc=$(cat $dataset_path/$d_name | grep 'FINAL_ACC' | \
                grep "\_$time_span1\_" | grep "\_$time_span2\_" | \
                grep "\_$time_int " | \
                awk '{delta=$5-avg; avg+=delta/NR; mean2+=delta*($5-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            # times
            time_train=$(cat $dataset_path/$d_name | grep 'TIME_TRAIN' | \
                grep "\_$time_span1\_" | grep "\_$time_span2\_" | \
                grep "\_$time_int " | \
                awk '{s=($6+$8+$10+$12+$14); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            time_test=$(cat $dataset_path/$d_name | grep 'TIME_TEST' | \
                grep "\_$time_span1\_" | grep "\_$time_span2\_" | \
                grep "\_$time_int " | \
                awk '{s=($6+$8+$10); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1))" "NR; }')
            
            echo $acc' '$time_train' '$time_test
 
        done
    done
    done
done

