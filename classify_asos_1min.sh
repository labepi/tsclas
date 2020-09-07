
# script for automatizing the classification call

# the mebedding dimension
D=$1

total=30 # also for the seed
seq_begin=1

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

        Rscript classify.R $dataset_path $d_name_train $d_name_test $D $seed 
        
    done
done

