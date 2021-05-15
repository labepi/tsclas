
source('config.R')

library(matrixcalc)

# loading the bandt-pompe functions
source(paste(bandt_pompe_path, 'bandt_pompe.R', sep='/'))

# loading the transition graph functions
source(paste(bandt_pompe_path, 'bandt_pompe_graph.R', sep='/'))

# loading the measures functions
source(paste(bandt_pompe_path, 'measures.R', sep='/'))

# loading functions to compute features from a graph
#source(paste(bandt_pompe_path, 'features.R', sep='/'))

# loading helper functions
source(paste(bandt_pompe_path, 'helpers.R', sep='/'))

# the functions to compute the features
source('features.R')

# the dataset should following the format:
#
# p1, ..., pm, class1
# p1, ..., pm, class2
# p1, ..., pm, class3
# ...
# p1, ..., pm, classn
#
# where p1, ..., pm are the columsn corresponding to the m data points
# of each time series, and the last column are the classes labels

# getting command line args
args = commandArgs(trailingOnly = TRUE)

if (length(args) == 0)
{
    # loading the datasets
    # asos
    #d_name = 'asos_1min_2020_fev_1hour_spline_feats' # fev/2020

    # botnet
    d_name = 'HpHp_L1_mean' # 

    # isiot
    #d_name = 'wunder_2015jan_spline_feats' # jan/2015

    # ASOS
    #dataset_path='./data/asos/1min_2020_fev_feats'

    # botnet
    dataset_path='./data/botnet/1000'

    # isiot
    #dataset_path='./data/isiot/datasets30/2015'

    # the Bandt-Pompe parameters

    # embedding dimension
    D=3

    # maximum embedding delay
    num_tau=10


} else {
    # loading the passed arguments

    # the dataset name
    d_name = args[1]
    
    # the dataset path
    dataset_path = args[2]

    # the Bandt-Pompe parameters

    # embedding dimension
    D = as.numeric(args[3])
    
    # embedding delay
    num_tau = as.numeric(args[4])

}

# mounting the path name
X_path = paste(dataset_path,'/',d_name,'.csv', sep='')

# the path to save the computed features
save_file = paste(dataset_path,'/D',D,'/',d_name,'_feats.csv', sep='')

#print(save_path)
#quit()

# loading the dataset 
X = read.csv(X_path, header=FALSE)

#print(dim(X))

# TODO: remove the column for asos names here

# removing the class label
y = X[,ncol(X)]
X = X[,-ncol(X)]

# dataset numbers

# the number of tau's
tau_l = 1:num_tau

# the number of time series
n = nrow(X)

# the number of data points
m = ncol(X)

# computing the features
res = extractFeatures(X, D, tau_l)

# the number of features computed
num_feats = ncol(res)

# here, the num_tau miust be adjusted with checking the max possible number of tau, 
# for this dataset, and if the informed tau_l can be used
num_tau = min(length(tau_l), checkMaxTau(m, D, lim=2))

# the number of features compiuted for each pair (D,tau)
num_feats_each = num_feats/num_tau

# filtering by selected features:
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

#FEATURES=c(3,6,7,8,9,10,11,12)

# the 10 computed features (removing D and tau columns)
FEATURES=3:12

# computing the correct indexes
inds = c()
#for(i in 1:num_tau)
for(f in FEATURES)
{
    #inds = c(inds, FEATURES+num_features*(i-1))
    inds = c(inds, seq(f, num_feats, num_feats_each))
}

# filtering columns of features
res = res[,inds]

# adding the class column
res = as.data.frame(cbind(res, y))

#print(dim(res))

# saving the computed features
write.table(res, save_file, sep=',', row.names=FALSE, col.names=FALSE)

