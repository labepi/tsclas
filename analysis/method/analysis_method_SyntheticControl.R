source('../../includes.R')

# loading some util functions
source('../../utils.R')

# path to the bandt-pompe functions
bandt_pompe_path = '../../../bandt_pompe'

# path to the skinny-dip files
skinnydip_path='../../../skinny-dip/code/skinny-dip/'

# loading the bandt-pompe functions
loadSource(bandt_pompe_path, 'bandt_pompe.R')

# loading helper functions
loadSource(bandt_pompe_path, 'helpers.R')

# loading the skinny-dip functions
loadSource(skinnydip_path,'func.R')

# the methods to find the best tau for a given D, according to the most
# separable classes in the CCEP
loadSource('../..', 'find_tau.R')

# the Cpp functions
sourceCpp('../../C/ccep_functions.cpp')


# loading the synthetic control pre-computed features from the UCR
# dataset

D=4

d_name = 'SyntheticControl'

pre_computed_path = '../../../classification/ucr/data/pre_computed'

x_train = read.csv(paste(pre_computed_path,'/features_',d_name,'_',D,'_train.csv', sep=''))
y_train = x_train[,ncol(x_train)]
x_train = x_train[,-c(1,ncol(x_train))] # num and class


# 1. D
# 2. tau, 
# 3. length(E(g4)),
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


# filtering the H and SC features
H_feat_num = 6 
C_feat_num = 7 

# number of series in TRAIN
n_train = nrow(x_train)

# number of series in TEST
n_test = nrow(x_test)

# time series length
m = ncol(x_train)

# number of classes
num_classes = length(unique(y_train))

# computing the number of features for each tau
num_tau = ncol(x_train)/length(FEATURES)

# computing the number of features for each tau
H_pos = num_tau*(H_feat_num-1)+1 # based on the FEATURES items

# computing the tau=1 position of C
C_pos = num_tau*(C_feat_num-1)+1 # based on the FEATURES items


# Computing the best tau for this D to select the features

# number of tau variation for each feature
num_tau_per_feat = m/length(FEATURES)

# subset of x_train, filtering the columns with H and C values, for the
# tau_l considered
sub_x_train = x_train[,c(H_pos:(H_pos+num_tau-1),C_pos:(C_pos+num_tau-1))]

#x=sub_x_train; y=y_train; tau_l=1:num_tau


##### filtering only the classes: 1, 2, 3

x = sub_x_train[y_train<=3,]
y = y_train[y_train<=3]

tau_l=1:num_tau

# opening this function so the areas could be plotted

# finding the best tau for this train set
#dtau = find_tau(x=sub2, y=y2, D=D, tau_l=1:num_tau)

#############################################

    num_kde = 250
    #num_kde = 500

    # TODO: esse valor deve vir de algum parametro, p-value, 95%, etc
    prob_lim = 1e-4 
    
    # NOTE: used for estimating the prob_lim by its quantile
    alpha_qt=0.05
    #alpha_qt=0.01

    # significance level for skinny-dip
    alpha_sk=0.05
    #alpha_sk=0.01

    # use or not the robust skinny-dip
    robust=TRUE
    #robust=FALSE

    # use the alpha for the quantile if TRUE, or 1-alpha otherwise
    quant_min=TRUE   # (min)
    #quant_min=FALSE  # (max)

    # the limit used for the maps around the range of x-y
    #limxy=0.01
    #limxy=0.03
    limxy=0.0

    # loading the CCEP limits for the current D
    ###########################################

    # limits
    limHC = read.table(paste(bandt_pompe_path, 
                        '/limits/limits_N',factorial(D),'.dat', 
                        sep=''), header=T)

    # isolating the min and max curves
    lim_min = limHC[limHC$Z == 1,]
    lim_max = limHC[limHC$Z == 2,]
    # NOTE: we have to invert the max curve 
    # (due to the way it was saved by bandt_pompe/limits.R)
    lim_max = lim_max[nrow(lim_max):1,]

    # computing some metrics
    ########################
    
    # the number of tau's considered
    #num_tau = length(tau_l)

    # the unique classes from y_train
    d_class_l = unique(y)

    # the number of classes
    num_class = length(d_class_l)

    # this list stores the Z of each class, to be used for counting the
    # probabilities of each class accuracy on each point of the grid
    mat_z = matrix(0, ncol=num_class, nrow=num_kde*num_kde)

    # the resulting accuracies for each dtau
    res_l = c()

    dtau=1
    
    x.df = data.frame(
                id=as.character(1:nrow(x)), 
                H=as.numeric(x[,dtau]), 
                C=as.numeric(x[,dtau+num_tau]), 
                Class=as.factor(y))

    par(mfrow=c(1,3))

    dxlim = range(x.df$H + c(-limxy, limxy))
    dylim = range(x.df$C + c(-limxy, limxy))


    for(d_class in 1:num_class)
    {
 
        x.df_1 = x.df[x.df$Class == d_class_l[d_class],]

        # doing skinny-dip
        # creating the normal multivariate
        mvx = cbind(x.df_1$H, x.df_1$C)

            skres = skinnyDipClusteringFullSpace(mvx,significanceLevel=alpha_sk)

            #buildTime = difftime(Sys.time(), buildTime, units='sec')
            #print(paste('time skinny:',buildTime))


            # number of clusters
            numclus = length(unique(skres[skres>0]))
            skres[skres == 0] = NA
            x.df_1$Cluster = as.factor(skres)

            # filtering to remove worst points
            x.df_2 = x.df_1[is.na(x.df_1$Cluster) == FALSE,]

            # only the clustered
            x.df_i = x.df_2

                        # NOTE: pre-computing the bandwidths of the kde
        bwd_x = bandwidth.nrd(x.df_i$H)
        bwd_y = bandwidth.nrd(x.df_i$C)

        bwd = c(
                ifelse((bwd_x == 0 | is.na(bwd_x)), 0.1, bwd_x),
                ifelse((bwd_y == 0 | is.na(bwd_y)), 0.1, bwd_y))

        #buildTime = Sys.time()

        # TODO: check if this can be done in Cpp
        # and if it is necessary

        # computing the kernel density estimation of the points
        km = kde2d(x.df_i$H, x.df_i$C, n=num_kde, h=bwd,
                     lims=c(dxlim[1],dxlim[2],
                            dylim[1],dylim[2]))

        km$z = limCCEP(as.numeric(km$x), as.numeric(km$y), as.matrix(km$z), 
                           as.matrix(lim_min), as.matrix(lim_max))

        par(family='Sans')
        image(km,
              col=hcl.colors(12, "YlOrRd", rev = TRUE))
              #col=hcl.colors(100, "terrain", rev = TRUE))
              #col=gray.colors(33, rev=TRUE))

        plot.ccep(D=D, add=T)


    }

