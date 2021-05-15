#!/bin/bash

# script to analyze the classfication results from literature algorithms

# time span is informed by command line
#time_span_l=( "1day" "1week" "2week" "3week" "1month" )
time_span_l=( "1day" "1week" "2week" "3week" )

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# path
dataset_path='../../../outputs'

# methods
method_l=( "linear" "polynomial" "spline" )

#method='spline'

for method in "${method_l[@]}"
do
    for time_span in "${time_span_l[@]}"
    do
        for time_int in "${time_int_l[@]}"
        do

            d_name="output_interpolate_asos_"$time_span"_"$time_int"_"$method".txt"
            #cat  | grep FINAL | grep "_$time_int"

            #echo $dataset_path/$d_name

            if [ ! -f $dataset_path/$d_name ]
            then
                continue
            fi

            time=$(cat $dataset_path/$d_name | grep "TIME" | \
                sed -e 's/\s\+/,/g' | cut -d',' -f4)

            echo $method' '$time_span' '$time_int' '$time
            
    #        # looping in classifiers
    #        for i in $(seq 0 3)
    #        do
    #            echo -n ${clf_l[i]}" "$time_span" "$time_int" "
    #
    #            acc=$(cat $dataset_path/$d_name | grep "\_$time_span\_" | \
    #                grep "\_$time_int\_" | grep ${clf_l[i]} | \
    #                awk '{delta=$'${clf_n[i]}'-avg; avg+=delta/NR; 
    #                            mean2+=delta*($'${clf_n[i]}'-avg);} 
    #                    END {print avg" "sqrt(mean2/(NR-1)); }')
    #            time=$(cat $dataset_path/$d_name | grep "\_$time_span\_" | \
    #                grep "\_$time_int\_" | grep ${clf_l[i]} | \
    #                awk '{delta=$'$((${clf_n[i]}+1))'-avg; avg+=delta/NR; 
    #                            mean2+=delta*($'$((${clf_n[i]}+1))'-avg);} 
    #                    END {print avg" "sqrt(mean2/(NR-1)); }')
    #
    #            if [ $? == 0 ]
    #            then
    #                echo $acc' '$time
    #            else
    #                echo '0 0 0 0'
    #            fi
    #        done
    #        #echo ""
        done
    done
done


