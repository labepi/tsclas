
library(ggplot2)
library(RColorBrewer)

# loading results
x = read.table('res_partial_asos_1min_literature_methods.txt', stringsAsFactors=F)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'method', 'span', 'int', 'acc', 'sd_acc', 'time', 'sd_time', 'num')

x$span = factor(x$span, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))
x$alg = as.factor(x$alg)
#x$alg = factor(x$alg, 
#                levels=c('3', '4', '5', '6', 'knn','randf','tsf','rise'),
#                labels=c('D=3', 'D=4', 'D=5', 'D=6', 'Knn','RandF','TSF','RISE'))
x$int = as.numeric(gsub('min', '', x$int))

# loading absolute times of interpolation
xint = read.table('res_partial_time_interpolate.txt')
labnames = c('Method', 'span', 'int', 'time')
colnames(xint) = labnames
xint$span = factor(xint$span, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))
xint$int = as.numeric(gsub('min', '', xint$int))

# summing up the interpolation time, per method, in the time column
for(method in unique(x$method))
{
    for(span in unique(x$span))
    {
        for(int in unique(x$int))
        {
            addtime = xint[xint$Method == method & xint$span == span & xint$int == int,'time']
            x[x$method == method & x$span == span & x$int == int,'time'] = 
                x[x$method == method & x$span == span & x$int == int,'time'] + addtime
        }
    }
}

#D=3

# length of computed features
#N = 30
N = 10

# source
# http://www.cookbook-r.com/Manipulating_data/Summarizing_data/

# Calculate standard error of the mean
# standard error
x$se_acc = x$sd_acc/sqrt(N)
x$se_time = x$sd_time/sqrt(N)

# Confidence interval multiplier for standard error
conf.interval = 0.95
# Calculate t-statistic for confidence interval: 
# e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
ciMult = qt(conf.interval/2 + .5, N-1)
x$ci_acc = x$se_acc * ciMult
x$ci_time = x$se_time * ciMult



for(span in unique(x$span))
{
    # filtering by span
    x_i = x[x$span == span,]

    # accuracy
    p = ggplot(data=x_i, aes(x=int, y=acc, color=alg, shape=alg)) + 
        geom_line() + geom_point(size=3) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(12,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0.45, 0.95) +
        geom_errorbar(aes(ymin=acc-ci_acc, ymax=acc+ci_acc), width=.2) +
        theme(text=element_text(size=16)) +
        labs(color="Alg", shape="Alg", title=span) 
        #theme(text=element_text(size=16,  family='Sans')) 
    
    fname=paste('img/fig_accuracy_asos_1min_methods_',
                gsub(' ', '', as.character(span)),'.pdf', sep='')
    ggsave(fname, p, width=10)

    # time
    p = ggplot(data=x_i, aes(x=int, y=time, color=alg, shape=alg)) + 
        geom_line() + geom_point(size=3) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(12,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0.45, 0.95) +
        geom_errorbar(aes(ymin=time-ci_time, ymax=time+ci_time), width=.2) +
        theme(text=element_text(size=16)) +
        labs(color="Alg", shape="Alg", title=span) 
        #theme(text=element_text(size=16,  family='Sans')) 

    fname=paste('img/fig_time_asos_1min_methods_sum_',
                gsub(' ', '', as.character(span)),'.pdf', sep='')
    ggsave(fname, p, width=10)
 
    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
}


