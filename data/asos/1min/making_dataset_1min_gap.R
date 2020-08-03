# this script gets the filtered stations and create a dataset, according
# to the type of feats determined

suppressMessages(library(lubridate))
#source('utils.R')

args = commandArgs(trailingOnly = TRUE)

# default values with no args
time_int = '1 min'
myto = '2020-01-31 23:59:00'
label = '1month'
gap_num = 10

if (length(args) >= 1)
{
    time_int = args[1]
}

if (length(args) >= 2)
{
    myto = args[2]
}

if (length(args) >= 3)
{
    label = args[3]
}

if (length(args) >= 4)
{
    gap_num = as.numeric(args[4])
}

# converting for percentage
gap_pct=gap_num/100

#print(args)

# TODO: needs feats_l to be defined, it will be the types of classes of
# the new dataset

# the list of features to use from the dataset
feats_l = c(
'tmpf', # Air Temperature in Fahrenheit, typically @ 2 meters
'dwpf', # Dew Point Temperature in Fahrenheit, typically @ 2 meters
'drct', # Wind Direction in degrees from north
'sknt', # Wind Speed in knots
'pres1' # Pressure altimeter in inches
)

# NOTE: there is no relh in 1min datasets
# 'relh', # Relative Humidity in %

# create the new adjusted dataset
myfrom='2020-01-01 00:00:00'
#myto='2020-01-31 23:59:00' # defined as command line argument

# the column times if anyone has lost
alltimes = seq(from = ymd_hms(myfrom), to = ymd_hms(myto), by=time_int)

#print(alltimes)
#print(length(alltimes))

#quit()

# size of perfect dataset
N = length(alltimes)

# transforming airport data to dataset
#dataset_path = 'data/ASOS_1min_2020_fev'
dataset_path = './raw'

gap_dir = './gap/'

# the dataset file
savefile=paste(gap_dir, 
               "asos_2020_jan_",
               label,"_",
               gsub(' ', '', time_int),
               "_gap",gap_num,
               ".csv", 
               sep='')

#print(savefile)
#quit()

stationsfile='all_1min.txt'

# minimum proportion of missing data accepted
minprop = 0.8

# looping in all stations
stations = read.table(stationsfile, stringsAsFactors=FALSE)
stations = stations[,1]

# TODO: define begin and end if it was necessary a reduced time interval
begin=NULL
end=NULL

#stations = c('12N','1J0','1V4','2WX')

for(name in stations)
{

    file_path = paste(dataset_path,'/',name,'.csv', sep='')

    if (!file.exists(file_path))
        next 
    
    cat(name, ' ')
    
    # loading
    x = read.csv(file_path)

    #print(dim(x))

    #quit()
    
    # converting times
    x$times = as.POSIXct(strptime(x$valid.UTC., format='%Y-%m-%d %H:%M', tz='UTC'))

    # what's the required times that exists in the dataset
    inds = alltimes %in% x$times

    # what's of the dataset that are in required times
    inds2 = x$times %in% alltimes

    #print(head(x))

    # TODO: check this
    # estimating relative humidity (fahrenheit)
    #x[,'relh'] = 100-(25/9)*(x$tmpf-x$dwpf)

    # size of current dataset, after filtering by time
    #n = nrow(x)
    n = sum(inds)

    # check if a minimum size necessary
    if (n/N < minprop)
    {
        cat('--\n')
        next
    }
    
    # to log
    cat(n,n/N,' ')

    # the minute for this station
    #minute = format(x$times[1], format='%M')

    # times adjusted
    #x$timesadj = as.POSIXct(x$times - minutes(minute))

    # the matrix of adjusted data
    #ds = matrix(NA, ncol=N+1, nrow=length(feats_l))
    # TODO: check if this is a slower option
    ds = matrix(NA, ncol=1+N+1, nrow=0) 
    # 1+N+1 => ASOS_CODE + feats + class
    # NOTE: each feature is a different type (class) identified by its
    # position i in the feats_l list


    j = 0

    # adjusting the data by type
    for(i in 1:length(feats_l))
    {
        na_num = sum(is.na(x[inds2,feats_l[i]]))

        #cat(N,na_num,'\n')
        #print(x[inds2,feats_l[i]])
        
        # check if each time series has a minimum size necessary 
        if( ((N-na_num)/N) < minprop )
        {
            next
        }

        # just add the time series if it has the minimum number of valid
        # points, without NA values
        j = j+1
        ds = rbind(ds, rep(NA, N+1))

        # the time series data
        ds_j = x[inds2,feats_l[i]]
        
        # NOTE: doing the gap here

        # the size of the current time series
        Nj = length(ds_j)

        # size of the gap
        gap_size = floor(N * gap_pct)
        
        # choosing the point to add the gap
        gap_start = sample(seq(1, Nj - gap_size), 1)

        # adding the gap
        ds_j[gap_start:(gap_start+gap_size-1)] = NA

        # saving the time series to dataset
        ds[j,c(TRUE, inds, TRUE)] = c(name, ds_j, i)
    }
    
    # toqWed 12 Feb 2020 07:37:59 PM -03 log
    cat('\n')

    # saving appending in a file
    write.table(ds, savefile, sep = ",", row.names=FALSE, col.names=FALSE, append=T)

}

# TODO: do it separately for data type?

# tmpf
# 1, 2, 3, 4, ..., PAAD
# 1, 2, 3, 4, ..., BOS

# relh
# ....

# TODO: save in different files (by type)?



