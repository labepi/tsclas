
# script for automatizing the interpolation

dataset_path='./data/asos/1min/gap'

# time interval 
time_int_l=( "1min" "5min" "10min" "15min" )

# time span
#time_span_l=( "1day" "1week" "2week" "3week" "1month" )

if [ $# -ne 3 ]
then
    echo "inform: timespan gapnum method"
    exit
fi

# NOTE: making timespan as an argument, to run separated processes
time_span=$1

gap_num=$2

method=$3

#for time_span in "${time_span_l[@]}"
for time_int in "${time_int_l[@]}"
do
    d_name=$dataset_path"/asos_2020_jan_"$time_span"_"$time_int"_gap"$gap_num".csv"
    
    #echo $d_name
    #continue

    python3 interpolate.py $d_name $method &> "outputs/output_interpolate_gap"$gap_num"_asos_"$time_span"_"$time_int"_"$method".txt"
    
done

