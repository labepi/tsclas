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
    for time_span in "${time_span_l[@]}"
    do
        for time_int in "${time_int_l[@]}"
        do

            d_name="res_asos_2020_jan_"$time_span"_D"$D".txt"
            d_name_base="res_asos_2020_jan_"$time_span"_sktime_tsf_linear.txt"
            
            tmp=$(cat $dataset_path/$d_name 2> /dev/null | grep FINAL | \
                grep "\_$time_span\_" | grep "\_$time_int" )
            
            if [ $? -ne 0 ]
            then
                continue
            fi
            
            echo -n $D" "$time_span" "$time_int' '

            # train_acc
            train_acc=$(cat $dataset_path/$d_name | grep 'TRAIN_ACC' | \
                grep "\_$time_span\_" | grep "\_$time_int" | cut -d' ' -f4)

            if [ $? -ne 0 ]
            then
                continue
            fi

            test_acc=$(cat $dataset_path/$d_name | grep 'FINAL_ACC' | \
                grep "\_$time_span\_" | grep "\_$time_int" | cut -d' ' -f4)
            
            if [ $? -ne 0 ]
            then
                continue
            fi
            
            base_acc=$(cat $dataset_path/$d_name_base | grep 'FINAL_ACC' | \
                grep "\_$time_span\_" | grep "\_$time_int" | \
                ../../../mean.awk -v col=4 | sed 's/^ //' | cut -d' ' -f1)

            if [ $? -ne 0 ]
            then
                continue
            fi
            
            echo -n $train_acc | sed 's/ /,/g'

            echo -n ';'$test_acc | sed 's/ /,/g'
            
            echo ';'$base_acc
            
        done
    done
done

