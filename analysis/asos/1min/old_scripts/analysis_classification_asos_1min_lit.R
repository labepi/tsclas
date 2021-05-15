
library(ggplot2)
library(RColorBrewer)

# loading results
x = read.table('res_partial_asos_1min_literature.txt', stringsAsFactors=F)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'int', 'acc', 'sd_acc', 'time', 'sd_time', 'num')

x$span = factor(x$span, 
                levels=c('1day','1week','2week','3week','1month'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks','1 Month'))
x$alg = factor(x$alg, 
                levels=c('knn','randf','tsf','rise'),
                labels=c('Knn','RandF','TSF','RISE'))

x$int = as.numeric(gsub('min', '', x$int))

#D=3

# length of computed features
#N = 30
N = 10

# source
# http://www.cookbook-r.com/Manipulating_data/Summarizing_data/

# Calculate standard error of the mean
# standard error
x$se_acc = x$sd_acc/sqrt(N)

# Confidence interval multiplier for standard error
conf.interval = 0.95
# Calculate t-statistic for confidence interval: 
# e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
ciMult = qt(conf.interval/2 + .5, N-1)
x$ci_acc = x$se_acc * ciMult

for(span in unique(x$span))
{
    # filtering by D
    x_i = x[x$span == span,]

    p = ggplot(data=x_i, aes(x=int, y=acc, color=alg, shape=alg)) + 
        geom_line() + geom_point(size=3) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(9,'Blues'))) + 
        #geom_errorbar(aes(ymin=acc-sd, ymax=acc+sd), width=.2) +
        #geom_errorbar(aes(ymin=acc-se, ymax=acc+se), width=.2) +
        geom_errorbar(aes(ymin=acc-ci_acc, ymax=acc+ci_acc), width=.2) +
        theme(text=element_text(size=16)) +
        labs(color="Alg", shape="Alg", title=span) +
        theme(text=element_text(size=16,  family='Sans')) 
    
    fname=paste('img/fig_accuracy_asos_1min_D',D,'.pdf', sep='')
    ggsave(fname, p, width=10)

    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
}



