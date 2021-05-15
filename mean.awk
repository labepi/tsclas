#!/usr/bin/awk -f
BEGIN {
    #num = ARGV[1];
    #print "column:",col;
}
{
    delta=$col-avg; 
    avg+=delta/NR; 
    mean2+=delta*($col-avg);
} 
END {
    print avg" "sqrt(mean2/(NR-1))" "NR; 
}
