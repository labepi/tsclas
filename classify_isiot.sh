
# script for automatizing the classification call

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

# doing the ISIoT split
ISIoT=TRUE



# fixing the seed and looping on the number of features (num_tau)
# seed=1
#for num_tau in $(seq 10 10 30)

# fixing the number of tau's, and looping on the seed
# NOTE: for the seed limits
num_tau=30
start_seq=1
total=30
for seed in $(seq $start_seq $((start_seq + total - 1)))
do
    dataset_path='./data/isiot/datasets'$num_tau'/2015'

    #echo '>>> '$seed

    d_name="wunder_2015jan_spline_feats" # jan/2015
    
    Rscript classify.R $d_name $D $seed $dataset_path $ISIoT 

    # the output will be in the script calling
    #&> "results/isiot/result_isiot_wunder_2015jan_D"$D".txt"
    
done


#done

