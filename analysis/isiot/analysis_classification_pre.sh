#!/bin/bash

# script to analyze the classfication results

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

D_l=( 3 4 5 6 )

# raw data or spline
data_l=( "raw" "spline" )

# path
dataset_path='../../results/isiot'

for D in "${D_l[@]}"
do
    for data in "${data_l[@]}"
    do
        echo -n $D" "$data" "

        if [ $data = "raw" ]
        then
            data_str=""
        elif [ $data = "spline" ]
        then
            data_str="spline_"
        fi

        d_name="res_isiot_2015_jan_"$data_str"D"$D".txt"
        #cat  | grep FINAL | grep "_$time_int"

        #echo $d_name

        acc=$(cat $dataset_path/$d_name | grep FINAL | \
            awk '{delta=$4-avg; avg+=delta/NR; mean2+=delta*($4-avg);} END {print avg" "sqrt(mean2/(NR-1)); }')

        echo $acc
 
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


