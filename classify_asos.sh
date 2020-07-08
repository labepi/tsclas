
# script for automatizing the classification call

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

hour=1
total=10 # also for the seed
seq_begin=1

dataset_path='./data/asos/1min_2020_fev_feats'

for i in $(seq 1 26)
do
    if [ $i -eq 24 ]
    then
        name="1day"
    elif [ $i -eq 25 ]
    then 
        name="1week"
    elif [ $i -eq 26 ]
    then
        name="1month"
    else
        name=$i"hour"
    fi

    for seed in $(seq $seq_begin $((seq_begin+total)))
    do
        d_name="asos_1min_2020_fev_"$name"_spline_feats"
        Rscript classify.R $d_name $D $seed $dataset_path
        #echo $d_name $seed
    done
done

