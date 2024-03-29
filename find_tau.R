
# computes the class separability index for a given dataset
class_separability = function(Hl, Cl, y, D=3,
                    lim_min=NULL, lim_max=NULL)
{
    # parameters definition
    #######################

    # parameters for the KDE
    num_kde = 250

    # TODO: esse valor deve vir de algum parametro, p-value, 95%, etc
    prob_lim = 1e-4 
    
    # NOTE: used for estimating the prob_lim by its quantile
    alpha_qt=0.05

    # significance level for skinny-dip
    alpha_sk=0.05

    # use or not the robust skinny-dip
    robust=TRUE
    #robust=FALSE

    # use the alpha for the quantile if TRUE, or 1-alpha otherwise
    quant_min=TRUE   # (min)
    #quant_min=FALSE  # (max)

    # the limit used for the maps around the range of x-y
    limxy=0.0

    # loading the CCEP limits for the current D
    ###########################################

    # NOTE: added the option to pass the limits as parameters

    # CCEP limits
    if (is.null(lim_min) | is.null(lim_max))
    {
        limHC = read.table(paste(bandt_pompe_path, 
                            '/limits/limits_N',factorial(D),'.dat', 
                            sep=''), header=T)

        # isolating the min and max curves
        lim_min = limHC[limHC$Z == 1,]
        lim_max = limHC[limHC$Z == 2,]
        # NOTE: we have to invert the max curve 
        # (due to the way it was saved by bandt_pompe/limits.R)
        lim_max = lim_max[nrow(lim_max):1,]
    }


    ######################################################

    # computing individual separability for each class
    
    # creating a dataframe for the current parameters
    x.df = data.frame(
                    id=as.character(1:length(Hl)),
                    H=as.numeric(Hl), 
                    C=as.numeric(Cl), 
                    Class=as.factor(y))
        
    # computing the limits for the whole classes
    dxlim = range(x.df$H) + c(-limxy, limxy)
    dylim = range(x.df$C) + c(-limxy, limxy)
    
    # the unique classes from y
    d_class_l = unique(y)

    # the number of classes
    num_class = length(d_class_l)

    # this list stores the Z of each class, to be used for counting the
    # probabilities of each class accuracy on each point of the grid
    mat_z = matrix(0, ncol=num_class, nrow=num_kde*num_kde)

    # looping the classes
    for(d_class in 1:num_class)
    {
        # filterging by class
        x.df_i = x.df[x.df$Class == d_class_l[d_class],]

        # if there is only one sample per class could not be applied
        if (robust==TRUE & nrow(x.df_i) > 1)
        {
            # doing skinny-dip
            
            # finding the clusters with skinny-dip
            skres = skinnyDipClusteringFullSpace(cbind(x.df_i$H, x.df_i$C),significanceLevel=alpha_sk)

            # setting outliers points as a null cluster
            skres[skres == 0] = NA

            # filtering to remove outliers points
            x.df_i = x.df_i[is.na(skres) == FALSE,]
        }

        # NOTE: pre-computing the bandwidths of the kde
        bwd_x = bandwidth.nrd(x.df_i$H)
        bwd_y = bandwidth.nrd(x.df_i$C)

        bwd = c(
                ifelse((bwd_x == 0 | is.na(bwd_x)), 0.1, bwd_x),
                ifelse((bwd_y == 0 | is.na(bwd_y)), 0.1, bwd_y))


        # TODO: check if this can be done in Cpp
        # and if it is necessary

        # computing the kernel density estimation of the points
        km = kde2d(x.df_i$H, x.df_i$C, n=num_kde, h=bwd,
                     lims=c(dxlim[1],dxlim[2],
                            dylim[1],dylim[2]))

        ##########################################
        # NOTE: removing the points outside the CCEP limits
        ##########################################

        # TODO: check if this can be faster if loading the f_min and
        # f_max functions interpolated from the curves

        # zeroing the points outside the CCEP limits
        km$z = limCCEP(as.numeric(km$x), as.numeric(km$y), as.matrix(km$z), 
                       as.matrix(lim_min), as.matrix(lim_max))

        # TODO: check if it is necessary to remove lowest values or if
        # it is sufficient the skinny dip outliers removing

        # converting the density to probability
        if (sum(km$z) != 0)
        {
            km$z = km$z/sum(km$z)
        }

        # removing very low values
        km$z[km$z <= 1e-30] = 0

        # storing the Z of kde for this class
        mat_z[,d_class] = c(km$z)
 
    } # end d_class
    
    # for each 'pixel' at mat_z
    # adjusting the values as probabilities [0,1]
    mat_z = mat_z/apply(mat_z, 1, sum)
    mat_z[is.nan(mat_z)] = 0
    mat_z[which(mat_z <= 1e-30)] = 0
    
    # testing the "classificability"
    si_l = c()
    for(d_class in 1:num_class)
    {
        # filtering by the points with value
        inds = mat_z[,d_class] > 0

        # computing the individual separability for the class
        s_i = sum(mat_z[,d_class])/sum(inds)

        # storing
        si_l = c(si_l, s_i)
        
        #cat(d_class, prob_i, prob_1, '\n')
    }

    # computing the class-separability index
    S_I = sum(1/num_class*si_l, na.rm=T) # prob

    # also returning the list for all tau's
    attr(S_I, 'dtau_l') = si_l

    ######################################################

    return(S_I)

}


# x: a matrix representing the subset of x_train with only H and C
#   values, the format for each row is all Hs followed by all Cs, for
#   all computed tau's:
#   E.g.,: H1, H2, ..., Hn, C1, C2, ..., Cn
#   where n is the max tau 
# y: the y_train classes
# D: the embedding dimension
# tau_l: the list of embedding delays (tau) to test
# lim_min and lim_max: min and max limits for the CCEP
find_tau = function(x, y, D=3, tau_l=1:10, debug=TRUE, # FALSE
                    lim_min=NULL, lim_max=NULL)
{
    # loading the CCEP limits for the current D
    ###########################################

    # NOTE: added the option to pass the limits as parameters
    # limits
    if (is.null(lim_min) | is.null(lim_max))
    {
        limHC = read.table(paste(bandt_pompe_path, 
                            '/limits/limits_N',factorial(D),'.dat', 
                            sep=''), header=T)

        # isolating the min and max curves
        lim_min = limHC[limHC$Z == 1,]
        lim_max = limHC[limHC$Z == 2,]
        # NOTE: we have to invert the max curve 
        # (due to the way it was saved by bandt_pompe/limits.R)
        lim_max = lim_max[nrow(lim_max):1,]
    }

    # computing some metrics
    ########################
    
    # the number of tau's considered
    num_tau = length(tau_l)

    # to store the class-separability indexes
    SI_l = rep(0, num_tau)

    # for all computed taus
    for(dtau in 1:num_tau)
    {
        # filtering the features for the current tau
        Hl = as.numeric(x[,dtau])
        Cl = as.numeric(x[,dtau+num_tau])

        # calling the function
        SI_l[dtau] = class_separability(Hl, Cl, y, D, lim_min, lim_max)
    } # end d_tau
 
    # computing max dtau
    max_dtau = which.max(SI_l)

    # also returning the list for all tau's
    attr(max_dtau, 'dtau_l') = SI_l

    return(max_dtau)
}

# x: a matrix representing the subset of x_train with only H and C
#   values, the format for each row is all Hs followed by all Cs, for
#   all computed tau's:
#   E.g.,: H1, H2, ..., Hn, C1, C2, ..., Cn
#   where n is the max tau 
# y: the y_train classes
# D: the embedding dimension
# tau_l: the list of embedding delays (tau) to test
# lim_min and lim_max: min and max limits for the CCEP
find_tau_old = function(x, y, D=3, tau_l=1:10, debug=TRUE, # FALSE
                    lim_min=NULL, lim_max=NULL)
{
    # parameters definition
    #######################

    # parameters for the KDE
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

    # NOTE: added the option to pass the limits as parameters
    # limits
    if (is.null(lim_min) | is.null(lim_max))
    {
        limHC = read.table(paste(bandt_pompe_path, 
                            '/limits/limits_N',factorial(D),'.dat', 
                            sep=''), header=T)

        # isolating the min and max curves
        lim_min = limHC[limHC$Z == 1,]
        lim_max = limHC[limHC$Z == 2,]
        # NOTE: we have to invert the max curve 
        # (due to the way it was saved by bandt_pompe/limits.R)
        lim_max = lim_max[nrow(lim_max):1,]
    }

    # computing some metrics
    ########################
    
    # the number of tau's considered
    num_tau = length(tau_l)

    # the unique classes from y_train
    d_class_l = unique(y)

    # the number of classes
    num_class = length(d_class_l)

    # this list stores the Z of each class, to be used for counting the
    # probabilities of each class accuracy on each point of the grid
    mat_z = matrix(0, ncol=num_class, nrow=num_kde*num_kde)

    # the resulting accuracies for each dtau
    res_l = c()

    # for all computed taus
    for(dtau in tau_l)
    {
        # getting the features for the current dtau
        x.df = data.frame(
                        id=as.character(1:nrow(x)), 
                        H=as.numeric(x[,dtau]), 
                        C=as.numeric(x[,dtau+num_tau]), 
                        Class=as.factor(y))
        
        # computing the limits for the whole classes
        dxlim = range(x.df$H + c(-limxy, limxy))
        dylim = range(x.df$C + c(-limxy, limxy))

        # looping the classes
        for(d_class in 1:num_class)
        {
            # filterging by class
            x.df_1 = x.df[x.df$Class == d_class_l[d_class],]

            # creating the normal multivariate
            mvx = cbind(x.df_1$H, x.df_1$C)

            #print(mvx)

            # if there is only one sample per class
            if (robust==FALSE | nrow(mvx) == 1)
            {
                # all series from the class
                x.df_i = x.df_1
            } else {

                # doing skinny-dip
                
                #buildTime = Sys.time()

                # finding the clusters with skinny-dip
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
            }

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

            #buildTime = difftime(Sys.time(), buildTime, units='sec')
            #print(paste('time kde:',buildTime))

            ##########################################
            # NOTE: removing the points outside the CCEP limits
            ##########################################

            #buildTime = Sys.time()

            # zeroing the points outside the CCEP limits
            km$z = limCCEP(as.numeric(km$x), as.numeric(km$y), as.matrix(km$z), 
                           as.matrix(lim_min), as.matrix(lim_max))

            #buildTime = difftime(Sys.time(), buildTime, units='sec')
            #print(paste('time filter:',buildTime))

            #image(km)
            #plot.ccep(D=D, add=T)

            ## looping at each x,y from the kde2d
            #for (i in 1:num_kde)
            #{
            #    # finding the point p1 in H min and max curves 
            #    # which is the first H that is >= than p1
            #    #id_min = min(which(lim_min$H >= km$x[p[1]]))
            #    #id_max = min(which(lim_max$H >= km$x[p[1]]))
            #    id_min = min(which(lim_min$H >= km$x[i]))
            #    id_max = min(which(lim_max$H >= km$x[i]))


            #    for(j in 1:num_kde)
            #    {

            #        #print(paste('id_min:',id_min,'id_max:',id_max))
            #        
            #        # checking if this point is NOT between C_min and C_max range
            #        # for this specific H positions
            #        #if (km$y[p[2]] < lim_min[id_min,'SC']
            #        #    |
            #        #    lim_max[id_max,'SC'] < km$y[p[2]])
            #        if (km$y[j] < lim_min[id_min,'SC']
            #            |
            #            lim_max[id_max,'SC'] < km$y[j])
            #        {
            #            # zeroing this point significance
            #            #km$z[p[1],p[2]] = 0
            #            km$z[i,j] = 0
            #        }
            #    }
            #}

            # TODO: check this

            # zeroing the lowest probabilities
            
#            # first filtering to have only the values with non-zero probability
#            #the_z = quantile(km$z[km$z!=0])
#            the_z = km$z[km$z!=0]
#
#            # TODO: check if this is necessary at this point
#            if (quant_min == TRUE)
#            {
#                prob_lim_i = quantile(the_z, probs=c(alpha_qt), na.rm=TRUE)
#            } else {
#                prob_lim_i = quantile(the_z, probs=c(1-alpha_qt), na.rm=TRUE)
#            }
#
#            # making the cut
#            km$z[km$z < prob_lim_i] = 0

            # converting the density to probability
            if (sum(km$z) != 0)
            {
                km$z = km$z/sum(km$z)
            }


            # storing the Z of kde for this class
            mat_z[,d_class] = c(km$z)
 
        } # end d_class

        # for each 'pixel' at mat_z
        # adjusting the values as probabilities [0,1]
        mat_z = mat_z/apply(mat_z, 1, sum)
        mat_z[is.nan(mat_z)] = 0

        # testing the "classificability"
        res_i = c()
        res_1 = c()
        for(d_class in 1:num_class)
        {
            #print(d_class)
            #d_class=1

            # filtering by class
            inds = mat_z[,d_class] > 0

            # considering the sum of proabbilities
            prob_i = sum(mat_z[,d_class])/sum(inds)
            res_i = c(res_i, prob_i)
            
            # considering the max probability
            if (sum(inds) > 1)
            {
                prob_1 = sum(apply(mat_z[inds,], 1, which.max) == d_class)/sum(inds)
            } else {
                prob_1 = sum(which.max(mat_z[inds,]) == d_class)/sum(inds)
            }
            res_1 = c(res_1, prob_1)
            
            #cat(d_class, prob_i, prob_1, '\n')

        }

        if (debug==TRUE)
        {
            cat('LIM',robust, quant_min, dtau, 
            sum(1/num_class*res_i, na.rm=T), # prob
            sum(1/num_class*res_1, na.rm=T), # max
            '\n')
        }
        
        # adding to the list
        res_l = c(res_l, sum(1/num_class*res_i, na.rm=T)) # prob

    } # end d_tau
 
    max_dtau = which.max(res_l)
    attr(max_dtau, 'dtau_l') = res_l

    return(max_dtau)
}

