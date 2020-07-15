# this script gets the filtered stations and create a dataset, according
# to the type of feats determined

library(lubridate)
#source('utils.R')

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
myto='2020-01-31 23:59:00'

# the column times if anyone has lost
alltimes = seq(from = ymd_hms(myfrom), to = ymd_hms(myto), by='min')

# size of perfect dataset
N = length(alltimes)

# transforming airport data to dataset
#dataset_path = 'data/ASOS_1min_2020_fev'
dataset_path = './raw'

# the dataset file
savefile="asos_2020_jan_1month.csv"

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

    # TODO: check this
    # estimating relative humidity (fahrenheit)
    #x[,'relh'] = 100-(25/9)*(x$tmpf-x$dwpf)

    # size of current dataset
    n = nrow(x)

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
    ds = matrix(NA, ncol=N+1, nrow=length(feats_l))

    # NOTE: each feature is a different type (class) identified by its
    # position i in the feats_l list

    inds = alltimes %in% x$times
    inds2 = x$times %in% alltimes

    # adjusting the data by type
    for(i in 1:length(feats_l))
    {
        ds[i,c(inds, TRUE)] = c(x[inds2,feats_l[i]], i)
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



