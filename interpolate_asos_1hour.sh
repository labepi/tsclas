
# script for automatizing the interpolation

# time span
time_span_l=( "1month" "2month" "3month" )

dataset_path='./data/asos/1hour'

for time_span in "${time_span_l[@]}"
do
    d_name=$dataset_path"/asos_2020_jan_"$time_span"_1hour.csv"
    echo $d_name 

    python3 interpolate.py $d_name
done

