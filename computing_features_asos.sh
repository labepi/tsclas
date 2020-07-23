
# script for automatizing the classification call

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

num_tau=30

# time span is informed by command line
time_span=$2

# name
d_name="asos_2020_jan_"$time_span"_1hour.csv"

# path
dataset_path='./data/asos/1hour'

Rscript computing_features.R $d_name $dataset_path $D $num_tau \ 
        &> "outputs/output_"$d_name"_D"$D".out" 

# getting the fields names
#for d_name in $(cat data/botnet/demonstrate_structure.csv | sed 's/,/ /g')
#do
#    echo $d_name
#    Rscript computing_features.R $d_name $dataset_path $D $num_tau
#done

