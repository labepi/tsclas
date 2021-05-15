#!/bin/bash

# script to analyze the classfication results

if [ $# -ne 1 ]
then
    echo "inform gap: 10/30/50"
    exit
fi

D_l=( 3 4 5 6 )

# time span is informed by command line
#time_span_l=( "1day" "1week" "2week" "3week" "1month" )
time_span_l=( "1day" "1week" "2week" "3week" )

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# path
dataset_path='../../../results/asos/1min'
#dataset_path='../../../results/asos/1min/backup'

gap=$1

for D in "${D_l[@]}"
do
    for time_span in "${time_span_l[@]}"
    do
        for time_int in "${time_int_l[@]}"
        do
            echo -n $D" "$time_span" "$time_int' '
            d_name="res_asos_2020_jan_"$time_span"_D"$D"_gap"$gap".txt"
            #cat  | grep FINAL | grep "_$time_int"

            tmp=$(cat $dataset_path/$d_name 2> /dev/null | grep FINAL | \
                grep "\_$time_span\_" | grep "\_$time_int")

            if [ $? -ne 0 ]
            then
                #echo '0 0 0 0 0 0 0'
                echo 'NA NA NA NA NA NA 0'
                continue
            fi

            # acc
            acc=$(cat $dataset_path/$d_name | grep 'FINAL_ACC' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            # times
            time_train=$(cat $dataset_path/$d_name | grep 'TIME_TRAIN' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                awk '{s=($5+$7+$9+$11+$13); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

            time_test=$(cat $dataset_path/$d_name | grep 'TIME_TEST' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                awk '{s=($5+$7+$9); 
                      delta=s-avg; avg+=delta/NR;
                      mean2+=delta*(s-avg);} END {print avg" "sqrt(mean2/(NR-1))" "NR; }')
            
            echo $acc' '$time_train' '$time_test


#            if [ $? -ne 0 ]
#            then
#                echo '0 0 0 0 0'
#                continue
#            fi
#
#            #echo $tmp
#            
#            #echo $d_name
#            acc=$(cat $dataset_path/$d_name | grep FINAL | \
#                grep "\_$time_span\_" | grep "\_$time_int" | \
#                awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')
#
#            echo -n $acc' '
#
#            time=$(cat $dataset_path/$d_name | grep FINAL | \
#                grep "\_$time_span\_" | grep "\_$time_int" | \
#                awk '{delta=$5-avg; avg+=delta/NR;
#                            mean2+=delta*($5-avg);} END {print avg" "sqrt(mean2/(NR-1))" "NR; }')
#            
#            echo $time
 
# the computed names
#names=$(cat results/$d_name | grep -v DEBUG | grep asos | cut -d'_' -f 5 | uniq)
#names=$(echo {1..23}hour 1day 1week 1month)

        done
    done
done

