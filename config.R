# path to the bandt-pompe functions
bandt_pompe_path="../bandt_pompe"

# path to the skinny-dip files
skinnydip_path='../skinny-dip/code/skinny-dip'

# path to datasets
dataset_path='./data'

# print the debug messages
DEBUG=TRUE

# to load the pre-computed features for a given dataset
LOAD_PRECOMPUTED=TRUE
#LOAD_PRECOMPUTED=FALSE

# the seed to use
# NOTE: it will be overwritten if passed as command line argument
SEED=1

# the percentage of train dataset to split
TRAIN_PCT=0.8

# if parallelism is enabled for parameter tunning
DO_PARALLEL=TRUE

# number of cores to use
CORES_NUM=3
#CORES_NUM=-1 # to use: detectCores()-1

