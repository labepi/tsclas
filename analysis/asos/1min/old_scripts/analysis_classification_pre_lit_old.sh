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
#clf_n=( 3 6 9 12 )
clf_n=( 7 10 13 16 )

if [ $# -ne 1 ]
then
    echo "inform method: linear/polynomial/spline"
    exit
fi

#method='spline'
method=$1

for time_span in "${time_span_l[@]}"
do
    for time_int in "${time_int_l[@]}"
    do
        #d_name="res_asos_2020_jan_"$time_span"_sktime.txt"
        d_name="res_asos_2020_jan_"$time_span"_sktime_"$method".txt"
        #cat  | grep FINAL | grep "_$time_int"

        #echo $dataset_path/$d_name

        if [ ! -f $dataset_path/$d_name ]
        then
            #echo "NA NA"
            continue
        fi

        # looping in classifiers
        for i in $(seq 0 3)
        do
            echo -n ${clf_l[i]}" "$time_span" "$time_int" "

            tmp=$(cat $dataset_path/$d_name | grep "\_$time_span\_" | \
                grep "\_$time_int " | grep ${clf_l[i]} )

            if [ $? -ne 0 ]
            then
                echo '0 0 0 0 0'
                continue
            fi

            acc=$(cat $dataset_path/$d_name | grep "\_$time_span\_" | \
                grep "\_$time_int " | grep ${clf_l[i]} | \
                awk '{delta=$'${clf_n[i]}'-avg; avg+=delta/NR; 
                            mean2+=delta*($'${clf_n[i]}'-avg);} 
                    END {print avg" "sqrt(mean2/(NR-1)); }' \
                        2> /dev/null
                )
            time=$(cat $dataset_path/$d_name | grep "\_$time_span\_" | \
                grep "\_$time_int " | grep ${clf_l[i]} | \
                awk '{delta=$'$((${clf_n[i]}+1))'-avg; avg+=delta/NR; 
                            mean2+=delta*($'$((${clf_n[i]}+1))'-avg);} 
                    END {print avg" "sqrt(mean2/(NR-1))" "NR; }' \
                        2> /dev/null
                )

            if [ $? -ne 0 ]
            then
                echo '0 0 0 0 0'
                continue
            fi
            
            echo $acc' '$time
        done
        #echo ""
    done
done



