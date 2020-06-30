
# TODO: see if this features extraction must go to the bandt_pompe
# repository (features.R)

# function to copmute the features
# list of features:
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
# 13. j
# 
transformPST = function(x, myD, mytau_l, savePST=FALSE)
{
    # number of features
    featsnum = 13 #14
    # features as function of tau
    # - all series will be together
    pst = matrix(0, ncol=featsnum, nrow=0) #n_train*length(myD_l)*length(mytau_l2))

    # TODO: acho que nao tem esse num, e ver como fazer com o y

    # number of features
    num = dim(x)[2] - 1

    # length of series
    m = dim(x)[1]
    
    # each feature
    for(j in 1:num)
    {
        xi = as.numeric(x[,j+1])

        i = 1
        for (mytau in mytau_l)
        {
            if (checkParameters(m, myD, mytau, lim=2) == FALSE)
            {
                next
            }

            #print(paste('D',myD,'tau',mytau))
        
            bpd = bandt_pompe_distribution(xi, D=myD, tau=mytau)

            #print(bpd)

            # shannon entropy
            H = shannon_entropy(bpd$probabilities, normalized=TRUE)
    
            # statistical complexity
            C = complexity(bpd$probabilities,H)

            # fisher information
            FI = fisher_information(bpd$probabilities)

            g4 = bandt_pompe_transition_graph(xi, D=myD, tau=mytau)

            #print(g4)
            
            pst = rbind(pst,
                        c(                          
                          myD, 
                          mytau, 
                          length(E(g4)),
                          mean(E(g4)$weight),
                          sd(E(g4)$weight),
                          shannon_entropy(E(g4)$weight, norm=T),
                          complexity(E(g4)$weight, norm=T),
                          fisher_information(E(g4)$weight),
                          sum(E(g4)$weight[which_loop(g4)]),
                          H,
                          C,
                          FI,
                          j
                         )
                        )

            i = i + 1
        }

        # saving objects
        if (savePST == TRUE)
        {
            saveRDS(pst, file=paste(features_path, '/properties_',attr(x, 'station'),'.dat', sep=''))
            #saveRDS(g, file=paste('data/properties_chaotic_map_',k,'_',xlab,'-g.dat', sep=''))
            #saveRDS(bpd, file=paste('data/properties_chaotic_map_',k,'_',xlab,'-bpd.dat', sep=''))
            #saveRDS(pst, file=paste('data/properties_',k,'_',j,'-pst.dat', sep=''))
        }

        #quit()
        #print(dim(pst))
    }

    return(pst)

}

# function to copmute the features
# list of features:
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
# 13. j
# 
transformPSTSingle = function(x, myD, mytau_l, savePST=FALSE)
{
    # the features to compute
    mycolumns = c('D', 'tau', 'lenE', 'meanEw', 'sdEw', 'Hw', 'Cw', 'Fw', 
            'PST', 'Hpi', 'Cpi', 'Fpi')
    
    # all features will be together
    data = c()

    # length of series
    m = length(x)
    
    # computing features for each tau
    for (mytau in mytau_l)
    {
        if (checkParameters(m, myD, mytau, lim=2) == FALSE)
        {
            next
        }

        #print(paste('D',myD,'tau',mytau))
    
        # computing the bandt_pompe distribution
        bpd = bandt_pompe_distribution(x, D=myD, tau=mytau)

        # computing the bandt pompe transition graph
        g = bandt_pompe_transition(x, D=myD, tau=mytau)
        g4 = bandt_pompe_transition_graph(x, D=myD, tau=mytau)
        
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

        # information theory quantifiers from edges weights
        Hw = shannon_entropy(weights, normalized=TRUE)
        Cw = complexity(weights, Hw, normalized=TRUE)
        Fw = fisher_information(weights)

        # probability of self transitions
        pst = matrix.trace(g)

        # joining each features vector
        data = c(data, c(myD, mytau, lenE, meanEw, sdEw, Hw, Cw, Fw, pst, Hpi, Cpi, Fpi))

    }

    # aggregating the features together
    feats = matrix(data, ncol=length(mycolumns), byrow=TRUE)
    colnames(feats) = mycolumns

    # saving objects
    #if (savePST == TRUE)
    #{
    #    saveRDS(pst, file=paste(features_path, '/properties_',attr(x, 'station'),'.dat', sep=''))
    #}

    return(feats)

}

