
# script for automatizing the classification call

if [ $# -eq 0 ]
then
    D=3
else
    D=$1
fi

num_tau=30

# name
d_name='wunder_2015_spline'

# path
dataset_path='./data/isiot'

Rscript computing_features.R $d_name $dataset_path $D $num_tau

# getting the fields names
#for d_name in $(cat data/botnet/demonstrate_structure.csv | sed 's/,/ /g')
#do
#    echo $d_name
#    Rscript computing_features.R $d_name $dataset_path $D $num_tau
#done

