#!/bin/bash

# script to analyze the selected tau's

D_l=( 3 4 5 6 )

# time span is informed by command line
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
            echo -n $D" "$time_span" "$time_int' '
            d_name="res_asos_2020_jan_"$time_span"_D"$D".txt"
            #cat  | grep FINAL | grep "_$time_int"

            tmp=$(cat $dataset_path/$d_name 2> /dev/null | grep SELECTED | \
                grep "\_$time_span\_" | grep "\_$time_int" )
            
            if [ $? -ne 0 ]
            then
                echo 'NA NA NA'
                continue
            fi

            #echo $tmp
            
            #echo $d_name
            #taus=$(cat $dataset_path/$d_name | egrep "FINAL|Selected" | \
            #        sed -z 's/\n/ /g' | sed 's/DEB/\nDEB/g' | \
            #        grep "\_$time_span\_" | grep "\_$time_int" | \
            #        #awk '{sum+=$8;} END {print sum/NR; }')
            #        awk '{delta=$8-avg; avg+=delta/NR;
            #                mean2+=delta*($8-avg);} 
            #            END {print avg" "sqrt(mean2/(NR-1))" "NR; }')
            taus=$(cat $dataset_path/$d_name | egrep "SELECTED" | \
                    grep "\_$time_span\_" | grep "\_$time_int" | \
                    #awk '{sum+=$8;} END {print sum/NR; }')
                    awk '{delta=$4-avg; avg+=delta/NR;
                            mean2+=delta*($4-avg);} 
                        END {print avg" "sqrt(mean2/(NR-1))" "NR; }')

            echo $taus' '

        done
    done
done

