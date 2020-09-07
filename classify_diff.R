
# script with the final steps for the classification

source('includes.R')

# loading the config file, where are the paths to the functions
source('config.R')

# loading some util functions
source('utils.R')

# loading the bandt-pompe functions
loadSource(bandt_pompe_path, 'bandt_pompe.R')

# loading the transition graph functions
loadSource(bandt_pompe_path, 'bandt_pompe_graph.R')

# loading the measures functions
loadSource(bandt_pompe_path, 'measures.R')

# loading helper functions
loadSource(bandt_pompe_path, 'helpers.R')

# TODO: check this file if it is needed
# loading functions to compute features from a graph
#loadSource(bandt_pompe_path, 'features.R')

# loadin the skinny-dip functions
loadSource(skinnydip_path,'func.R')

# the methods to find the best tau for a given D, according to the most
# separable classes in the CCEP
loadSource('.', 'find_tau.R')

# the Cpp functions
sourceCpp('C/ccep_functions.cpp')

# the methods for extracting features
loadSource('.', 'features.R')

printdebug('Loaded libraries and functions')

# reconfiguring the path for the datasets

# getting command line args
args = commandArgs(trailingOnly = TRUE)

if (length(args) == 0)
{
    # loading the datasets
    # asos
    d_name = 'asos_2020_jan_1day_10min' # jan/2020
    #d_name = 'asos_2020_jan_1day_10min_spline' # jan/2020

    # isiot
    #d_name = 'wunder_2015jan_spline_feats' # jan/2015

    # the Bandt-Pompe parameters

    # embedding dimension
    D=3

    # embedding delay
    tau_l=1:30

    # ASOS
    dataset_path='./data/asos/1min'

    # isiot
    #dataset_path='./data/isiot/datasets30/2015'

    # to make the ISIoT split
    #ISIoT = TRUE
    ISIoT = FALSE

} else {
    # the reconfiguration of dataset path
    dataset_path = args[1]
    
    # the dataset name
    d_name_train = args[2]
    d_name_test = args[3]
 
    
    # the Bandt-Pompe parameters

    # embedding dimension
    D = as.numeric(args[4])
    
    # embedding delay
    tau_l = 1:30
    
    SEED = as.numeric(args[5])

    # defining the ISIoT split
    if (length(args) < 6)
    {
        ISIoT = FALSE
    } else {
        ISIoT = args[6]
    }
    
}

#########################################
# configurations for handling NA values ni time series
na_aware=TRUE
na_rm=TRUE

# defining the seed
set.seed(SEED)

# the percentage of train dataset split
train_pct = TRAIN_PCT # from config.R

printdebug(paste('TRAIN',d_name_train))
printdebug(paste('TEST',d_name_test))

# old debug
#printdebug(paste('(D,tau): ',D,',',paste(range(tau_l), collapse=':'), sep=''))
printdebug(paste('Embedding dimension D:',D))

printdebug(paste('SEED:',SEED))

if (na_aware == TRUE)
    printdebug('NA_AWARE')
    
if (na_rm == TRUE)
    printdebug('NA_RM')

# 1. D
# 2. tau, 
# 3. sd of G weights
# 4. shannon entropy of G weights
# 5. complexity of G weights
# 6. fisher information of G weights
# 7. PST
# 8.  (H) shannon entropy of BP distribution
# 9.  (C) complexity of BP dist.
# 10. (FI) fisher information of BP dist.

# NOTE: remove features
# 3. length {(E(g4)),
# 4. mean of G weights
################ LOADING DATASET

printdebug('Loading datasets')

# load raw data and apply transformation to compute features
    
# the dataset path and name
pathname_train = paste(dataset_path,'/',d_name_train,'.csv', sep='')
pathname_test = paste(dataset_path,'/',d_name_test,'.csv', sep='')

# load data
x_all_train = read.csv(pathname_train, header=FALSE)
x_all_test = read.csv(pathname_test, header=FALSE)

# NOTE: all datasets now have the asos names as first column
names_all_train = x_all_train[,1]
y_all_train = x_all_train[,ncol(x_all_train)]
x_all_train = x_all_train[,-c(1,ncol(x_all_train))]

names_all_test = x_all_test[,1]
y_all_test = x_all_test[,ncol(x_all_test)]
x_all_test = x_all_test[,-c(1,ncol(x_all_test))]



printdebug('Datasets loaded')

################ SPLIT TRAIN/TEST ###############

printdebug('Datasets split train/test')

# define the split rate

# NOTE: performing the same split as the ISIoT paper
if (ISIoT == TRUE)
{
        printdebug("ISIoT split")
        # for loading the ISIoT split
        stationsfile = './data/isiot/cities.usa.txt'
        stations = read.table(stationsfile, stringsAsFactors=FALSE)
        stations_type = stations[,7]

        # using the same tag of the paper
        inds = which(stations_type == 'C')
        id_train = which(ceiling(1:240 / 4) %in% inds)
} else {
    id_train = createDataPartition(y=y_all_train, p=train_pct, list=FALSE)
    id_test = createDataPartition(y=y_all_test, p=train_pct, list=FALSE)
}

# Splitting datasets
x_train = x_all_train[id_train,]
y_train = y_all_train[id_train]

x_test = x_all_test[-id_test,]
y_test = y_all_test[-id_test]


################ DATASET NUMBERS

# number of series in TRAIN
n_train = nrow(x_train)

# number of series in TEST
n_test = nrow(x_test)

# time series length
m = ncol(x_train)

# number of classes
num_classes = length(unique(y_train))

printdebug(paste('Original dimension TRAIN:',paste(dim(x_train), collapse='x')))
printdebug(paste('Original dimension TEST:',paste(dim(x_test), collapse='x')))

################ FINDING BEST TAU

# Step 1. 

#buildTotalTime = Sys.time()

printdebug('Computing features for CCEP')

buildTime = Sys.time()
# computing only the features used by find_tau
sub_x_train = extractFeaturesHC(x_train, D, tau_l, na_aware=na_aware, na_rm=na_rm)
Ncol = ncol(sub_x_train)
# adjusting features: all Hs, all Cs
sub_x_train = sub_x_train[,c(seq(1, Ncol, by=2), seq(2, Ncol, by=2))]
#print(head(sub_x_train))
#print(dim(sub_x_train))
t_ccep = difftime(Sys.time(), buildTime, units='sec')

# Step 2.
    
# Computing the best tau for this D to select the features

printdebug('Selecting best tau')

# computing the number of features for each tau
num_tau = ncol(sub_x_train)/2 #length(FEATURES)

# number of tau variation for each feature
#num_tau_per_feat = m/length(FEATURES)
num_tau_per_feat = m/2


printdebug(paste('Maximum number of tau:',num_tau))


buildTime = Sys.time()
# finding the best tau for this train set
dtau = find_tau(x=sub_x_train, y=y_train, D=D, tau_l=1:num_tau)
t_findtau = difftime(Sys.time(), buildTime, units='sec')

# mannually setting dtau
#dtau = 1 # 
#dtau = 20 # 

#printdebug(paste('Selected tau:',dtau))
cat(d_name_train,d_name_test,SEED,'SELECTED_TAU', dtau,'\n')

#############################################################

# computing all the features for the specific pair (D,tau)

printdebug('Computing features for the selected tau')

# train
buildTime = Sys.time()
x_train = extractFeatures(x_train, D, c(dtau), na_aware=na_aware, na_rm=na_rm)
t_features_train = difftime(Sys.time(), buildTime, units='sec')
# test
buildTime = Sys.time()
x_test = extractFeatures(x_test, D, c(dtau), na_aware=na_aware, na_rm=na_rm)
t_features_test = difftime(Sys.time(), buildTime, units='sec')

# removing columns D,tau
x_train = x_train[,-c(1,2)]
x_test = x_test[,-c(1,2)]

printdebug(paste('New dimension TRAIN:',paste(dim(x_train), collapse='x')))
printdebug(paste('New dimension TEST:',paste(dim(x_test), collapse='x')))

# TODO: saving the current dataset
#x_all2 = cbind(
#      names_all,
#      rbind(
#        cbind(x_train, y_train), 
#        cbind(x_test, y_test)
#      )
#      )
#
#print(dim(x_all2))
#
#savefile = 'dataset_test2.csv'
#
## saving appending in a file
#write.table(x_all2, savefile, sep = ",", row.names=FALSE, col.names=FALSE)

################ PRE-PROCESS ###############

printdebug('Removing NA values')

# just for the cases where features are computed as NAs
x_train = as.matrix(x_train)
x_test = as.matrix(x_test)
x_train[is.na(x_train)] = 0
x_test[is.na(x_test)] = 0

printdebug('Scaling data')



# preprocesing the features dataset
# train
buildTime = Sys.time()
transform = preProcess(x_train, method=c("center", "scale"))
x_train = predict(transform, x_train)
t_scale_train = difftime(Sys.time(), buildTime, units='sec')
# test
buildTime = Sys.time()
x_test  = predict(transform, x_test)
t_scale_test = difftime(Sys.time(), buildTime, units='sec')

##################################################
## CLASSIFICATION 
##################################################

# Radom Forest classifier without tunning parameters
##################################################

################ BEGIN TRAIN ###############

# NOTE: the same parameters as the python randf version
ntree=200
mtry=2

buildTime = Sys.time()
rf = randomForest(x_train, as.factor(y_train), mtry=mtry, ntree=ntree)
t_train = difftime(Sys.time(), buildTime, units='sec')

#print(importance(rf))

cat(d_name_train,d_name_test,SEED,'TRAIN_ACC', 1 - rf$err.rate[ntree,1],'\n')

################ BEGIN TEST ###############

# testing the tunned parameters

# predicting on x_test
buildTime = Sys.time()
y_pred = predict(rf, x_test)
t_test = difftime(Sys.time(), buildTime, units='sec')

# printing string y_test-y_pred
cat(d_name_train,d_name_test,SEED,'PREDICTED', 
    paste(y_test, y_pred, sep='-', collapse=','),'\n')

cat(d_name_train,d_name_test,SEED,'TIME_TRAIN',
     'ccep:',t_ccep,
     'findtau:',t_findtau,
     'feats:',t_features_train,
     'scale:',t_scale_train,
     'train:',t_train,'\n')

cat(d_name_train,d_name_test,SEED,'TIME_TEST',
     'feats:',t_features_test,
     'scale:',t_scale_test,
     'test:',t_test,'\n')

# confusion matrix
#cm = confusionMatrix(table(y_test,res))
#printdebug(paste('OVERALL accuracy: ', cm$overall['Accuracy']))
#output1 = paste('FINAL_ACC', cm$overall['Accuracy'])

acc = sum(y_test==y_pred)/length(y_test)

cat(d_name_train,d_name_test,SEED,'FINAL_ACC',acc,'\n')

