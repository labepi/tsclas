#!/bin/bash

echo station,lat,lon
tail -n 1 raw/*.csv | cut -d',' -f1,3,4 | grep ',' | grep -v station


