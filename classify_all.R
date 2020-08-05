
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

    # botnet
    #d_name = 'HpHp_L1_mean_feats' # 

    # isiot
    #d_name = 'wunder_2015jan_spline_feats' # jan/2015

    # the Bandt-Pompe parameters

    # embedding dimension
    D=3

    # embedding delay
    tau_l=1:30

    # ASOS
    dataset_path='./data/asos/1min'

    # botnet
    #dataset_path='./data/botnet/1000'
    #dataset_path='../extern/botnet_attack_iot'

    # isiot
    #dataset_path='./data/isiot/datasets30/2015'

    # to make the ISIoT split
    #ISIoT = TRUE
    ISIoT = FALSE

    # for the botnet 2 class mode
    botnet_2class = FALSE

} else {
    # loading the datasets
    d_name = args[1]
    
    # the Bandt-Pompe parameters

    # embedding dimension
    D = as.numeric(args[2])
    
    # embedding delay
    #tau_l = 1:10
    
    SEED = as.numeric(args[3])

    # the reconfiguration of dataset path
    if (length(args) < 4)
    {
        dataset_path='./data/asos/1min_2020_fev_feats'
    } else {
        dataset_path = args[4]
    }

    # defining the ISIoT split
    if (length(args) < 5)
    {
        ISIoT = FALSE
    } else {
        ISIoT = args[5]
    }
    
    # defining the botnet two or more classification
    if (length(args) < 6)
    {
        botnet_2class = FALSE
    } else {
        botnet_2class = args[6]
    }
}

# defining the seed
set.seed(SEED)

# the percentage of train dataset split
train_pct = TRAIN_PCT # from config.R

printdebug(d_name)

# old debug
#printdebug(paste('(D,tau): ',D,',',paste(range(tau_l), collapse=':'), sep=''))
printdebug(paste('Embedding dimension D:',D))

printdebug(paste('SEED:',SEED))

# 1. D
# 2. tau, 
# 3. length {(E(g4)),
# 4. mean of G weights
# 5. sd of G weights
# 6. shannon entropy of G weights
# 7. complexity of G weights
# 8. fisher information of G weights
# 9. PST
# 10. (H) shannon entropy of BP distribution
# 11. (C) complexity of BP dist.
# 12. (FI) fisher information of BP dist.
FEATURES=c(3,6,7,8,9,10,11,12)

# position of the features (H,C), according to the vector above
H_feat_num = 6 
C_feat_num = 7 

# TODO: this is a test using all the 10 computed features
FEATURES=3:12
H_feat_num = 8
C_feat_num = 9

################ LOADING DATASET

printdebug('Loading datasets')

# load raw data and apply transformation to compute features
    
# the dataset path and name
pathname = paste(dataset_path,'/',d_name,'.csv', sep='')

# load data
x_all = read.csv(pathname, header=FALSE)

# NOTE: all datasets now have the asos names as first column
names_all = x_all[,1]
y_all = x_all[,ncol(x_all)]
x_all = x_all[,-c(1,ncol(x_all))]

printdebug('Datasets loaded')

#print(D)
#print(tau_l)


################ SPLIT TRAIN/TEST ###############

printdebug('Datasets split train/test')

# transforming the class in only two for the botnet:
# - benign data
# - malicious data
if (botnet_2class == TRUE)
{
    printdebug("Botnet 2class")

    y_all[y_all != 1] = 2
} 

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
    id_train = createDataPartition(y=y_all, p=train_pct, list=FALSE)
}

# Splitting datasets
x_train = x_all[id_train,]
y_train = y_all[id_train]

x_test = x_all[-id_train,]
y_test = y_all[-id_train]


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

printdebug('Selecting features')

buildTime = Sys.time()

# computing only the features used by find_tau
sub_x_train = extractFeaturesHC(x_train, D, tau_l)

Ncol = ncol(sub_x_train)

# adjusting features: all Hs, all Cs
sub_x_train = sub_x_train[,c(seq(1, Ncol, by=2), seq(2, Ncol, by=2))]

print(head(sub_x_train))
print(dim(sub_x_train))

buildTime = difftime(Sys.time(), buildTime, units='sec')
print(buildTime)

#quit()

# Step 2.
    
# Computing the best tau for this D to select the features

printdebug('Selecting best tau')

# computing the number of features for each tau
num_tau = ncol(sub_x_train)/2 #length(FEATURES)

# number of tau variation for each feature
#num_tau_per_feat = m/length(FEATURES)
num_tau_per_feat = m/2


printdebug(paste('Maximum number of tau:',num_tau))


# subset of x_train, filtering the columns with H and C values, for the
# tau_l considered
#sub_x_train = x_train[,c(H_pos:(H_pos+num_tau-1),C_pos:(C_pos+num_tau-1))]

#x=sub_x_train; y=y_train; tau_l=1:num_tau

buildTime = Sys.time()

# finding the best tau for this train set
dtau = find_tau(x=sub_x_train, y=y_train, D=D, tau_l=1:num_tau)

buildTime = difftime(Sys.time(), buildTime, units='sec')
print(buildTime)

# mannually setting dtau
#dtau = 1 # 
#dtau = 3 # 

printdebug(paste('Selected tau:',dtau))


#####
# computing the tau=1 position of H
#H_pos = num_tau*(H_feat_num-1)+1 # based on the FEATURES items

# computing the tau=1 position of C
#C_pos = num_tau*(C_feat_num-1)+1 # based on the FEATURES items

#############################################################


# computing all the features for the specific pair (D,tau)

printdebug('Computing features for the selected tau')

buildTime = Sys.time()

x_train = extractFeatures(x_train, D, c(dtau))
x_test = extractFeatures(x_test, D, c(dtau))

buildTime = difftime(Sys.time(), buildTime, units='sec')
print(buildTime)

# removing columns D,tau
x_train = x_train[,-c(1,2)]
x_test = x_test[,-c(1,2)]

#print(head(x_train_tmp))
#print(dim(x_train_tmp))

#quit()

# ths indices to extract the features for the i-th tau
#feats_tau_ind = seq(dtau,m,by=num_tau_per_feat)

#print(feats_tau_ind)

# re-adjusting datasets
#x_train = x_train[,feats_tau_ind]
#x_test = x_test[,feats_tau_ind]

printdebug(paste('New dimension TRAIN:',paste(dim(x_train), collapse='x')))
printdebug(paste('New dimension TEST:',paste(dim(x_test), collapse='x')))

################ PRE-PROCESS ###############

printdebug('Removing NA values')

# TODO: test if another method for removing NAs is best, such as some
# impute method (mean, mode, etc)

x_train = as.matrix(x_train)
x_test = as.matrix(x_test)

x_train[is.na(x_train)] = 0
x_test[is.na(x_test)] = 0


printdebug('Scaling data')

# preprocesing the features dataset
transform = preProcess(x_train, method=c("center", "scale"))

x_train = predict(transform, x_train)
x_test  = predict(transform, x_test)

##################################################
##################################################
######## TESTING SIMPLER CLASSIFIER ##############
##################################################
##################################################

# Radon Forest classifier with tunning parameters
##################################################

# performing a custom caret package extension

printdebug('Tunning randomForest parameters')

# tunning metric is accuracy
metric = "Accuracy"

# creating the custom classifier
customRF = list(type = "Classification", library = "randomForest", loop = NULL)

# configuring tunning parametrs
customRF$parameters = data.frame(parameter = c("mtry", "ntree"),
                                  class = rep("numeric", 2),
                                  label = c("mtry", "ntree"))

# setting options and functions
customRF$grid = function(x, y, len = NULL, search = "grid") {}
customRF$fit  = function(x, y, wts, param, lev, last, weights, classProbs) {
  randomForest(x, y,
               mtry = param$mtry,
               ntree=param$ntree)
}

#Predict label
customRF$predict = function(modelFit, newdata, preProc = NULL, submodels = NULL)
   predict(modelFit, newdata)

#Predict prob
customRF$prob = function(modelFit, newdata, preProc = NULL, submodels = NULL)
   predict(modelFit, newdata, type = "prob")

#customRF$sort   = function(x) x[order(x[,1]),]
customRF$levels = function(x) x$classes

# if parallelization is enabled
if (DO_PARALLEL)
{
    if (CORES_NUM==-1)
        cores = makeCluster(detectCores()-1)
    else
        cores = makeCluster(CORES_NUM)
    registerDoParallel(cores = cores)
}

################ BEGIN TRAIN ###############

# train model
control = trainControl(method="repeatedcv", 
                        number=10, 
                        repeats=3,
                        allowParallel = TRUE)

# the features interval for tunning
#tunegrid = expand.grid(.mtry=c(1:15),.ntree=c(100, 200, 500, 1000, 1500))
tunegrid = expand.grid(.mtry=c(1:6),.ntree=c(200, 350, 500))
#tunegrid = expand.grid(.mtry=c(2),.ntree=c(500))


# training the customized classifier
rf = train(x_train, as.factor(y_train), 
                method=customRF, 
                metric=metric, 
                tuneGrid=tunegrid, 
                trControl=control)

printdebug(paste('Tunned parameters: ',
                 paste(c('mtry', 'ntree'), rf$bestTune,
                       collapse=' ')))

printdebug(paste('TRAIN accuracy: ',
                    rf$results[rownames(rf$bestTune),'Accuracy']))

#summary(rf)
#plot(rf)
#print(rf)

################ BEGIN TEST ###############

# testing the tunned parameters


# predicting on x_test
res = predict(rf, x_test)

printdebug(paste('Predicted test:', paste(y_test, res, sep='-', collapse=',')))

# confusion matrix
#cm = confusionMatrix(table(y_test,res))
#printdebug(paste('OVERALL accuracy: ', cm$overall['Accuracy']))
#output1 = paste('FINAL_ACC', cm$overall['Accuracy'])

acc = sum(res==y_test)/length(y_test)

output1 = paste('FINAL_ACC', acc)

cat(d_name,SEED,output1,'\n')

