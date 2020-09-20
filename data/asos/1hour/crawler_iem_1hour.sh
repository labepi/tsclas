#!/bin/bash

# script to get 1min data for 1 month for the stations listed in
# stationsfile

# 00,01,...,05
stations_file="airports"$1".csv"

save_dir='./raw'

url1="https://mesonet.agron.iastate.edu/cgi-bin/request/asos.py?station="
#url2="&data=all&year1=2020&month1=1&day1=1&year2=2020&month2=3&day2=31&tz=Etc%2FUTC&format=onlycomma&latlon=yes&missing=M&trace=T&direct=no&report_type=1&report_type=2"
url2="&data=all&year1=2020&month1=1&day1=1&year2=2020&month2=6&day2=30&tz=Etc%2FUTC&format=onlycomma&latlon=yes&missing=M&trace=T&direct=no&report_type=1&report_type=2"

for i in $(cat $stations_file | cut -d',' -f2 | grep -v ident | sed 's/"//g')
do
    echo $i
    url=$url1$i$url2

    #echo $url

    wget -4 $url -O $save_dir/$i.csv -o wget.log.out
   
    # the caller will control this
    #2> /dev/null

    #exit
done

