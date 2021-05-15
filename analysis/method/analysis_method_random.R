source('../../includes.R')

# loading some util functions
source('../../utils.R')

# path to the bandt-pompe functions
bandt_pompe_path = '../../../bandt_pompe'

# path to the skinny-dip files
skinnydip_path='../../../skinny-dip/code/skinny-dip/'

# loading the bandt-pompe functions
loadSource(bandt_pompe_path, 'bandt_pompe.R')

# loading the bandt-pompe functions
loadSource(bandt_pompe_path, 'measures.R')

# loading helper functions
loadSource(bandt_pompe_path, 'helpers.R')

# loading the skinny-dip functions
loadSource(skinnydip_path,'func.R')

# the methods to find the best tau for a given D, according to the most
# separable classes in the CCEP
loadSource('../..', 'find_tau.R')

# the Cpp functions
sourceCpp('../../C/ccep_functions.cpp')

library(ggplot2)
library(ggpubr)
library(ggrepel)



# loading synthetic random data

#data_path = '../../../graph/data/csv/'
data_path = '../../../graph/data_large/csv/'



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


#0.00 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50
#noise_pts = c(2, 2.25, 2.5)
noise_pts = c(2, 2.25, 2.75)
#noise_pts = c(1.75, 2, 2.25)

D=4
tau=1

num_i = 10

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

# TODO: using data_large to compute more features
# split x$x in 10 series of 5000 for each k_i

# length of the whole time series
m = 50000

# length of the new truncated time series
n = 1000


# a dataset

ds = matrix(0, ncol=3, nrow=0) #nrow=num_i*length(noise_pts))
colnames(ds) = c('H','C','k')

j=0

for(k in noise_pts)
{
    for(i in 1:10)
    {
        #j = j+1

        # formating the name
        d_name = paste('random_k_',k,'_',i,'-series.csv', sep='')
        f_name = paste(data_path,d_name, sep='')

        # loading dataset
        x = read.csv(f_name)

        for(j in seq(1, m, by=n))
        {
            newx = x$x[j:(j+n-1)]
            
            #print(length(newx))
            #print(newx[1:5])
            
            # computing BP
            bp = bandt_pompe_distribution(data=newx, D=D, tau=tau)

            # computing features H,C
            H = shannon_entropy(bp$probabilities, normalized=T)
            SC = complexity(bp$probabilities, normalized=T, entropy=H)

            # TODO: check this
            if (H==0)
                next
            
            #ds[j,] = c(H, SC, k)
            ds = rbind(ds, c(H, SC, k))

        }
        
        #cat(f_name,' ',H,' ',SC,'\n')

    }
}

# fixing the length of the 2.75 time series
ds = rbind(ds, ds[1499,])

# converting to a data.frame
ds = as.data.frame(ds)
ds$k = as.factor(ds$k)

# the H and C ranges
dxlim = range(ds$H + c(-limxy, limxy))
dylim = range(ds$C + c(-limxy, limxy))





#########################
## fig 1 - arranged
#########################


# NOTE: creating a scatter plot with density regions

centers = data.frame(H = c(0.9117510, 0.8742152, 0.7178874),
                     C = c(0.0974972451, 0.1298013987, 0.2216124443),
                     k = as.factor(c(2.00, 2.25, 2.75)))

mypalette = c('#FC6452', '#70B86B', '#73A2CE')
mypalette_dark = c("#6D0026", "#004616", "#273871")

                             
# Scatter plot colored by Class
sp = ggscatter(ds, x='H', y='C', color='k',   #, color='black'
               palette=mypalette, size=3, alpha=0.6, shape=16, #21
               xlim=dxlim, ylim=dylim) + 
               border() + theme_bw() + 
               gplot.ccep(D=4, add=T) +
               geom_point(data=centers, aes(H,C), color='black', 
                          fill=mypalette_dark, size=5, shape=23) +
               geom_label_repel(data=centers, aes(x=H, y=C, label=k), color='black',
                             segment.alpha=0.6, size=8,
                             label.size=NA, point.padding = 0.3,
                             box.padding=0.2,show.legend=FALSE) +
               xlab('Normalized Shannon Entropy') +
               ylab('Statistical Complexity') + 
               theme(text=element_text(size=36),
                     panel.grid.major = element_blank(), 
                     panel.grid.minor = element_blank(),
                     plot.margin=unit(c(0,0,0,0), "cm"))


# Marginal density plot of x (top panel) and y (right panel)
xplot = ggdensity(ds, 'H', fill="k", palette=mypalette) +
               theme(text=element_text(size=30), plot.margin=unit(c(0,0,0,0), "cm"))
yplot = ggdensity(ds, "C", fill="k", palette=mypalette) + rotate() +
               theme(text=element_text(size=30), plot.margin=unit(c(0,0,0,0), "cm"))

# Cleaning the plots
yplot = yplot + clean_theme() 
xplot = xplot + clean_theme() 

# Compute descriptive statistics by groups
stable = desc_statby(ds, measure.var="H", grps = "k")
names(stable)[2] = 'Length'
stable = stable[, c("k", "Length")]

# Summary table plot, medium orange theme
stable.p = ggtexttable(stable, rows=NULL, theme=ttheme("classic", base_size=30))

# Arranging the plot
p = ggarrange(xplot, stable.p, sp, yplot, 
          ncol=2, nrow=2,  align="hv", 
          widths=c(2, 1), heights=c(1, 2),
          common.legend=TRUE, legend='right') 

ggsave('img/fig_arrange.pdf', p, width=14, height=10)



#########################
## fig 2 - fig with 3 regions to be joined manually
#########################

#kmall = matrix(0, ncol=num_kde, nrow=num_kde)

pdf('img/fig_3areas_cont.pdf', width=22)

par(mfrow=c(1,3), tcl=0.5, cex.axis=2, cex.lab=2, mar = c(5, 5, 4, 2))
#par(mfrow=c(3,2), family='Sans')
#par(mfrow=c(1,1), family='Sans')

num_kde=250
#alpha_sk=0.05
alpha_sk=0.5
dxlim = c(0.6,0.95)

# reds
reds = c("#FFFFFF", 
"#FFBBA6", "#FFBBA6", "#FFBBA6",
"#FF846D", "#FF846D", 
"#F23B36", "#F23B36", 
"#B20936", "#B20936", 
"#6D0026", "#6D0026")

# greens
greens = c("#FFFFFF", 
"#C4E5BB", "#C4E5BB", "#C4E5BB" ,
"#90C988", "#90C988", 
"#4AA64A", "#4AA64A", 
"#227732", "#227732", 
"#004616", "#004616")

# blues
blues = c("#FFFFFF", 
"#BCD7EA", "#BCD7EA", "#BCD7EA", 
"#8CB5D8", "#8CB5D8",
"#598EC5", "#598EC5",
"#3263A7", "#3263A7",
"#273871", "#273871")


# the matrix to store the lateral projections
# for H and C
zMH = matrix(0, nrow=0, ncol=3)
zMC = matrix(0, nrow=0, ncol=3)
# x z j

added=F
j=1
for(k in noise_pts)
{
    ds_i = ds[ds$k == k,]

    # doing skinny-dip
    # creating the normal multivariate
    mvx = cbind(ds_i$H, ds_i$C)
    
    #print(mvx)

    # finding the clusters with skinny-dip
    skres = skinnyDipClusteringFullSpace(mvx,significanceLevel=alpha_sk)
    
    # filtering to remove worst points
    ds_i = ds_i[skres!=0,]

    # NOTE: pre-computing the bandwidths of the kde
    bwd_x = bandwidth.nrd(ds_i$H)
    bwd_y = bandwidth.nrd(ds_i$C)
    
    bwd = c(
            ifelse((bwd_x == 0 | is.na(bwd_x)), 0.1, bwd_x),
            ifelse((bwd_y == 0 | is.na(bwd_y)), 0.1, bwd_y))
    
    # computing the kernel density estimation of the points
    km = kde2d(ds_i$H, ds_i$C, n=num_kde, h=bwd,
                lims=c(dxlim[1],dxlim[2],
                       dylim[1],dylim[2]))

    # limit to the CCEP region
    km$z = limCCEP(as.numeric(km$x), as.numeric(km$y), as.matrix(km$z), 
                    as.matrix(lim_min), as.matrix(lim_max))


    # converting the density to probability
    if (sum(km$z) != 0)
    {
        km$z = km$z/sum(km$z)
    }

    # doing the lateral projection of the regions of plane
    z_vH = apply(km$z, 1, max)
    z_vC = apply(km$z, 2, max)

    zMH = rbind(zMH, cbind(km$x, z_vH, j))
    zMC = rbind(zMC, cbind(km$x, z_vC, j))

    #kmall = kmall + km$z

    if (j==1)
        mycol = reds
    else if (j==2)
        mycol = greens
    else
        mycol = blues
        
        #mycol = hcl.colors(12, "Reds", rev = TRUE)
        #mycol = hcl.colors(12, "Greens", rev = TRUE)
        #mycol = hcl.colors(12, "Blues", rev = TRUE)
    #mycol[1]="#FFFFFF"
        
    #par(family='Sans')
    image(km, add=added, col=mycol, 
          xlab='Normalized Shannon Entropy',
          ylab='Statistical Complexity') #useRaster=T, 
    
    #contour(km, add=T, lwd=0.1, col='lightgray', drawlabels=F)
    #persp3d(km, phi = 15, theta = 25, col=j, alpha=0.5, add=added)

    #if (added==FALSE) { added=TRUE }

    j = j+1

    # the CCEP limits
    plot.ccep(D=D, add=T)
    # the density
    #plot(km$x, z_v, type='l') #, ylim=c(0,0.003))
}


dev.off()



# H
colnames(zMH) = c('x', 'z', 'j')
dfMH = as.data.frame(zMH)

dfMH$j = as.factor(dfMH$j)


p = ggplot(data=dfMH, aes(x, z, color=j, fill=j)) + geom_line() + 
    geom_polygon(aes(fill=j), alpha=0.5) +
    scale_color_discrete(name = "k", labels = noise_pts) +
    scale_fill_discrete(name = "k", labels = noise_pts) +
    xlab('Normalized Shannon Entropy') +
    ylab('Probability') +
    theme_bw() + theme(text=element_text(size=16))
    #theme_bw() + theme(text=element_text(size=16, family='Sans'))

ggsave('img/fig_3areas_lateral_H.pdf', p, width=12, height=6)


# C
colnames(zMC) = c('x', 'z', 'j')
dfMC = as.data.frame(zMC)

dfMC$j = as.factor(dfMC$j)


p = ggplot(data=dfMC, aes(x, z, color=j, fill=j)) + geom_line() + 
    geom_polygon(aes(fill=j), alpha=0.5) +
    scale_color_discrete(name = "k", labels = noise_pts) +
    scale_fill_discrete(name = "k", labels = noise_pts) +
    xlab('Statistical Complexity') +
    ylab('Probability') +
    theme_bw() + theme(text=element_text(size=16))
    #theme_bw() + theme(text=element_text(size=16, family='Sans'))

ggsave('img/fig_3areas_lateral_C.pdf', p, width=12, height=6)


#### testing

p2 = gplot.ccep(D=4, xlim=range(km$x), ylim=range(km$y))

ix <- findInterval(ds_i$H, km$x)
iy <- findInterval(ds_i$C, km$y)

ii <- cbind(ix, iy)

dens = km$z[ii]

p2 + geom_point(data=ds_i, aes(H, C, color = dens))

#p2 + geom_density2d_filled(data=ds_i, aes(H, C))

p2 + stat_density2d_filled(data=ds_i, aes(H, C, fill=..level.., alpha=..level..),
                           geom='polygon',colour='black') + 
    scale_fill_continuous(low="green",high="red")

+
    geom_smooth(method=lm,linetype=2,colour="red",se=F) 

stat_density2d(aes(fill=..level..,alpha=..level..),geom='polygon',colour='black') + 
  scale_fill_continuous(low="green",high="red") +
  geom_smooth(method=lm,linetype=2,colour="red",se=F) + 


dev.off()




p = qplot(x=km$x,y=z_v,geom="line")

p
> p + geom_segment()
Error: geom_segment requires the following missing aesthetics: xend and yend
Run `rlang::last_error()` to see where the error occurred.
> p + geom_polygon()
> p + geom_polygon(alpha=0.2)
> p + geom_polygon(alpha=0.2, col=2)
> p + geom_polygon(alpha=0.2, fill=2)
> p + geom_polygon(alpha=0.2, fill=2)
>



#m <- ggplot(ds1, aes(x = H, y = C)) +
#    geom_density_2d(aes(colour = Class))
#
#    geom_density_2d_filled(alpha = 0.5)
#
#m <- ggplot() + 
#    #geom_density_2d_filled(data=ds, aes(x = H, y = C)) +
#    geom_density_2d(data=ds1, aes(x = H, y = C)) +
#    geom_density_2d(data=ds2, aes(x = H, y = C)) +
#    geom_density_2d(data=ds3, aes(x = H, y = C))
#
#    geom_density_2d(aes(colour = Class))
#
# geom_point() 
#
# xlim(0.5, 6) +
# ylim(40, 110)
#
## contour lines
#m + geom_density_2d()
#
#m + geom_density_2d(aes(colour = Class))
#
#m + geom_density_2d_filled(alpha = 0.5)




# NOTE:

# converting the density to probability
if (sum(km$z) != 0)
{
    km$z = km$z/sum(km$z)
}

# first filtering to have only the values with non-zero probability


#the_z = quantile(bivn.kde$z[bivn.kde$z!=0])

prob_lim_i = quantile(km$z[km$z!=0], probs=c(1-alpha_qt))

# making the cut
km$z[km$z < prob_lim_i] = 0


plot(km$x, apply(km$z, 1, max), type='l')

# the vector with the high values for each col
z_v = rep(0,num_kde)

for(i in 1:num_kde)
{
    z_v[i] = 
}


# filtering data for the skinny-dip and KDE2

#mvx = cbind(x.df$H, x.df$SC)

# filtering or not?
#skres = skinnyDipClusteringFullSpace(mvx,significanceLevel=alpha_sk)





#            # number of clusters
#            numclus = length(unique(skres[skres>0]))
#            skres[skres == 0] = NA
#            x.df_1$Cluster = as.factor(skres)
#
#            # filtering to remove worst points
#            x.df_2 = x.df_1[is.na(x.df_1$Cluster) == FALSE,]
#
#            # only the clustered
#            x.df_i = x.df_2





quit()





# <-  <-  <-  <-  <-  <-  <- 

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

