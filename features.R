
# This script contains the functions for computing the features used in
# our work

# the dataset should following the format:
#
# p1, ..., pm
# p1, ..., pm
# p1, ..., pm
# ...
# p1, ..., pm
#
# where p1, ..., pm are the columsn corresponding to the m data points
# of each time series

# X - the dataset containing all time series data
# D -  the embedding dimension
# tau_l - a list of embedding delays, the returning features are
#       collapsed sequentially by the tau used to compute them
# Returns the following computed list of features (for each time series):
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
extractFeatures = function(X, D=3, tau_l=1:10)
{
    # TODO: check if this value must be given or set ouside here
    num_of_features = 12

    #buildTime = Sys.time()

    # the length of the series
    m = ncol(X)

    # checking the max number of tau, for this dataset, and if the
    # informed tau_l can be used
    max_tau = min(length(tau_l), checkMaxTau(m, D, lim=2))

    # TODO: check if this is the best strategy
    M = matrix(0, nrow=nrow(X), ncol=num_of_features*max_tau)

    for(i in 1:nrow(X))
    {
        M[i,] = extractFeatureSingle(X[i,], D, tau_l)

        #print(M[i,])
        #print(length(M[i,]))
    }

    #buildTime = difftime(Sys.time(), buildTime, units='sec')
    #print(buildTime)

    return(M)
}

# x - a single time series data
# D -  the embedding dimension
# tau_l - a list of embedding delays, the returning features are
#       collapsed sequentially by the tau used to compute them
# Returns the following computed list of features:
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
extractFeatureSingle = function(x, D=3, tau_l=1:10, na.rm=TRUE)
{
    # the features to compute
    mycolumns = c('D', 'tau', 'lenE', 'meanEw', 'sdEw', 'Hw', 'Cw', 'Fw', 
            'PST', 'Hpi', 'Cpi', 'Fpi')
    
    # all features will be together
    data = c()

    # length of series
    m = length(x)
    
    # computing features for each tau
    for (tau in tau_l)
    {
        if (checkParameters(m, D, tau, lim=2) == FALSE)
        {
            next
        }

        #buildTime = Sys.time()
        # pre-computing the symbols for both bpd ans g
        symbols = bandt_pompe_c(as.numeric(x), D, tau)
        #symbols = bandt_pompe(as.numeric(x), D, tau)

        #buildTime = difftime(Sys.time(), buildTime, units='sec')
        #print(buildTime)

        # computing the bandt_pompe distribution
        bpd = bandt_pompe_distribution(symbols, D=D, tau=tau, useSymbols=TRUE)

        # computing the bandt pompe transition graph
        g = bandt_pompe_transition(symbols, D=D, tau=tau, useSymbols=TRUE)
        
        # bpd distribution features
        
        # shannon entropy
        Hpi = shannon_entropy(bpd$probabilities, normalized=TRUE)
    
        # statistical complexity
        Cpi = complexity(bpd$probabilities, Hpi)

        # fisher information
        Fpi = fisher_information(bpd$probabilities)
        
        # transition graph features

        # edges and weights (non-zero transitions)
        edges = g != 0
        weights = g[edges]
        
        # number of edges
        lenE = sum(edges)

        # mean of edges weights
        meanEw = mean(weights)
        
        # mean of edges weights
        sdEw = sd(weights)
        #if (is.na(sdEw)){ sdEw = 0 }

        # information theory quantifiers from edges weights
        Hw = shannon_entropy(weights, normalized=TRUE)
        Cw = complexity(weights, Hw, normalized=TRUE)
        Fw = fisher_information(weights)

        # probability of self transitions
        pst = matrix.trace(g)
        
        # the current vector of features
        curdata = c(D, tau, lenE, meanEw, sdEw, Hw, Cw, Fw, pst, Hpi, Cpi, Fpi)

        # making NA and NaN values to be 0?
        if (na.rm == TRUE)
        {
            curdata[is.na(curdata)] = 0
        }

        # joining each features vector
        data = c(data, curdata)
    }

    return(data)
}



