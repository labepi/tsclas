
# script for automatizing the classification call

D=$1

# NOTE: making timespan as an argument, to run separated processes
time_span=$2

total=30 # also for the seed
seq_begin=1

dataset_path='./data/asos/1hour'

for seed in $(seq $seq_begin $((seq_begin+total-1)))
do
    d_name="asos_2020_jan_"$time_span"_1hour"

    Rscript classify.R $dataset_path $d_name $D $seed 
done

