
# script for automatizing the classification call

# TODO: trying the classification of our method with interpolation

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

total=30 # also for the seed
seq_begin=1

dataset_path='./data/asos/1min'

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# NOTE: making timespan as an argument, to run separated processes
time_span=$2

method=$3

for time_int in "${time_int_l[@]}"
do 
    for seed in $(seq $seq_begin $((seq_begin+total-1)))
    do
        d_name="asos_2020_jan_"$time_span"_"$time_int"_"$method
        
        #echo $d_name $seed

        #continue

        Rscript classify_all.R $d_name $D $seed $dataset_path
        
    done
done

