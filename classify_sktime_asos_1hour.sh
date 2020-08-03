
# script for automatizing the classification call

# NOTE: making timespan as an argument, to run separated processes
time_span=$1

total=10 # also for the seed
seq_begin=1

dataset_path='./data/asos/1hour'

for seed in $(seq $seq_begin $((seq_begin+total-1)))
do
    d_name="asos_2020_jan_"$time_span"_1hour"
    #echo $d_name $seed
    
    python3 classify_sktime.py $dataset_path $d_name $seed 
done

