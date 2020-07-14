#!/bin/bash

# script to get 1min data for 1 month for the stations listed in
# stationsfile

stations_file="all_1min.txt"

url1="https://mesonet.agron.iastate.edu/request/asos/1min_dl.php?station%5B%5D%5B%5D="
url2="&tz=UTC&year1=2020&month1=1&day1=1&hour1=0&minute1=0&year2=2020&month2=1&day2=31&hour2=23&minute2=59&vars%5B%5D=tmpf&vars%5B%5D=dwpf&vars%5B%5D=sknt&vars%5B%5D=drct&vars%5B%5D=gust_drct&vars%5B%5D=gust_sknt&vars%5B%5D=vis1_coeff&vars%5B%5D=vis1_nd&vars%5B%5D=vis2_coeff&vars%5B%5D=vis2_nd&vars%5B%5D=ptype&vars%5B%5D=precip&vars%5B%5D=pres1&vars%5B%5D=pres2&vars%5B%5D=pres3&sample=1min&what=view&delim=comma&gis=yes" 

for i in $(cat $stations_file | cut -d' ' -f1)
do
    echo $i
    url=$url1$i$url2

    #echo $url

    wget -4 $url -O $i.csv -o wget.log.out
   
    # the caller will control this
    #2> /dev/null

    #exit
done

