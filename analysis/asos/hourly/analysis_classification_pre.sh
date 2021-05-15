#!/bin/bash

# script to analyze the classfication results

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

# time span is informed by command line
#time_span=( "1day" "1week" "2week" "3week" "1month" )
time_span_l=( "1day" "1week" "2week" "3week" )

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# path
dataset_path='./results/asos/1min'

for time_span in "${time_span_l[@]}"
do
    for time_int in "${time_int_l[@]}"
    do
 
        d_name="res_asos_2020_jan_"$time_span"_D"$D".txt"
        cat $dataset_path/$d_name | grep FINAL | grep $time_int

# the computed names
#names=$(cat results/$d_name | grep -v DEBUG | grep asos | cut -d'_' -f 5 | uniq)
#names=$(echo {1..23}hour 1day 1week 1month)

    done
done


exit


for name in $names
do
    #echo $name' ====== \n'
    #cat results/$d_name | grep -v DEBUG | grep asos | grep "\_$name\_" 

    echo -n $name' '

    testacc=$(cat $d_name | grep FINAL | grep asos | grep "\_$name\_")
    
    if [ $? == 0 ]
    then
        # acc raw
        acc=$(cat $d_name | grep FINAL | grep asos | grep "\_$name\_" | \
            awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')
        #echo -n $acc' '
        echo $acc
    else
        echo "NA NA"
    fi
    
done


