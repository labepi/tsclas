
# script for automatizing the classification call

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

# NOTE: making timespan as an argument, to run separated processes
time_span=$2

total=29 # also for the seed
seq_begin=1

dataset_path='./data/asos/1hour'

for seed in $(seq $seq_begin $((seq_begin+total)))
do
    d_name="asos_2020_jan_"$time_span"_1hour_feats"
    Rscript classify.R $d_name $D $seed $dataset_path
    #echo $d_name $seed
done

