
# script for automatizing the classification call

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

total=10 # also for the seed
seq_begin=1

dataset_path='./data/asos/1min'

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# NOTE: making timespan as an argument, to run separated processes
time_span=$2

for time_int in "${time_int_l[@]}"
do 
    for seed in $(seq $seq_begin $((seq_begin+total)))
    do
        d_name="asos_2020_jan_"$time_span"_"$time_int"_feats"
        
        #echo $d_name $seed

        #continue

        Rscript classify.R $d_name $D $seed $dataset_path
        
    done
done

