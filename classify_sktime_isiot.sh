
# script for automatizing the classification call

total=30 # also for the seed
#total=10 # also for the seed
seq_begin=1

dataset_path='./data/isiot'

# spline/linear/polynomial
method=$1

# knn,randf,tsf,rise,boss,st
algorithm=$2

ISIoT=TRUE

d_name="wunder_2015"

for seed in $(seq $seq_begin $((seq_begin + total - 1)))
do
    python3 classify_sktime.py $dataset_path $d_name $seed $method $algorithm $ISIoT
done

