
# analysing the results from the classification

library(ggplot2)

# The accuracies

D_l = 3:6
#D_l = c(3)

labnames = c('label', 'acc', 'sdacc', 'D','hour')

df = data.frame()

for (D in D_l)
{
    x = read.table(paste('classification_1min_D',D,'.txt', sep=''))
    df = rbind(df, cbind(x, D, seq(1,nrow(x))))
}

colnames(df) = labnames

#xraw = read.table('analysis/classification_1min_RAW.txt')
xraw = read.table('../../classification/asos/analysis/classification_1min_RAW.txt')

for (i in c(2,8))#,14))
{
    #xraw_i = cbind(xraw[,c(1,i+1,i+2,i+1,i+2,i)], seq(1,nrow(xraw)))
    xraw_i = cbind(xraw[,c(1,i+1,i+2,i)], seq(1,nrow(xraw)))
    colnames(xraw_i) = labnames
    df = rbind(df, xraw_i)
}

# NOTE: removing the 1month samples
#df = df[df$hour != 26,]

df$D = as.factor(df$D)

# variance of accraw
df$sdacc2 = df$sdacc ^2
#df$sdaccfilter2 = df$sdaccfilter ^2


# TODO: fix the case for only one experiment for boss
#ids_boss = df$D == 'boss' & df$hour > 15

p = ggplot(df, aes(x=hour, y=acc, shape=D, color=D, fill=D)) +
    geom_point(size=3) + geom_line() + theme_bw() +
    #geom_errorbar(aes(ymin=acc-sdacc, ymax=acc+sdacc), 
    geom_errorbar(aes(ymin=acc-sdacc2, ymax=acc+sdacc2), 
                  width=1.0, position=position_dodge(0.05)) +
    scale_fill_brewer(palette="Blues") +
    theme(text=element_text(size=16,  family="Sans"))

#p2 = ggplot(df, aes(x=hour, y=accraw, shape=D, color=D, fill=D)) +
#    geom_point(size=3) + geom_line() + theme_bw() +
#    geom_errorbar(aes(ymin=accfilter-sdaccfilter2, ymax=accfilter+sdaccfilter2), 
#                  width=1.0, position=position_dodge(0.05)) +
#    scale_fill_brewer(palette="Blues") 


    scale_fill_grey()


# the execution time
# TODO: do it also for my strategy

df2 = data.frame()

labnames2 = c('label', 'alg', 'time', 'sdtime', 'hour')

for (i in c(2,8,14))
{
    xraw_i = cbind(xraw[,c(1,i,i+4,i+5)], seq(1,nrow(xraw)))
    colnames(xraw_i) = labnames2
    df2 = rbind(df2, xraw_i)
}


p2 = ggplot(df2, aes(x=hour, y=time, shape=alg, color=alg, fill=alg)) +
    geom_point() + geom_line() + theme_bw()

