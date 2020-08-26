
# script for automatizing the classification call

if [ $# -ne 3 ]
then
    echo "Error: $0 D span1 span2"
    exit
fi

# embedding dimension
D=$1

seq_begin=1
total=30 # also for the seed

dataset_path='./data/asos/1min'

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# NOTE: making timespan as an argument, to run separated processes
time_span1=$2
time_span2=$3

for time_int in "${time_int_l[@]}"
do 
    for seed in $(seq $seq_begin $((seq_begin+total-1)))
    do
        d_name_train="asos_2020_jan_"$time_span1"_"$time_int
        d_name_test="asos_2020_jan_"$time_span2"_"$time_int
        
        #echo $d_name $seed

        #continue

        Rscript classify_all_diff.R $d_name_train $d_name_test $D $seed $dataset_path
        
    done
done

