
# script for automatizing the classification call

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

# doing the ISIoT split
ISIoT=TRUE

dataset_path='./data/isiot'

d_name="wunder_2015" # jan/2015
#d_name="wunder_2015_spline" # jan/2015

start_seq=1
total=30

for seed in $(seq $start_seq $((start_seq + total - 1)))
do
    Rscript classify.R $dataset_path $d_name $D $seed $ISIoT 
done

