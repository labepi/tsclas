
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

d_name="wunder_2015_feats" # jan/2015
#d_name="wunder_2015_spline_feats" # jan/2015

start_seq=1
total=30

for seed in $(seq $start_seq $((start_seq + total - 1)))
do
    #echo '>>> '$seed
    
    Rscript classify.R $d_name $D $seed $dataset_path $ISIoT 

    # the output will be in the script calling
    #&> "results/isiot/result_isiot_wunder_2015jan_D"$D".txt"
    
done

