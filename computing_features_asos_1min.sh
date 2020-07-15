
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

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# path
dataset_path='./data/asos/1min'

for time_int in "${time_int_l[@]}"
do       
    # name
    d_name='asos_2020_jan_'$time_span'_'$time_int

    echo $d_name

    Rscript computing_features.R $d_name $dataset_path $D $num_tau \ 
        &> "outputs/output_"$d_name"_D"$D".out" 

done

