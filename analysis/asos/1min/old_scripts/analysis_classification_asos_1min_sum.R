
library(ggplot2)
library(RColorBrewer)

# getting command line args
args = commandArgs(trailingOnly = TRUE)


if (length(args) == 0)
{
    print('method not informed: linear/polynomial/[spline]')
    method='spline'
    #quit()
} else {
    method=args[1]
}

# loading results
x1 = read.table('res_partial_asos_1min.txt', stringsAsFactors=F)
print('Loaded own res')
x2 = read.table(paste('res_partial_asos_1min_literature_',method,'.txt', sep=''), 
                stringsAsFactors=F)
print('Loaded lit res')
 
#print(head(x1))
#print(head(x2))
#quit()

colnames(x1) = c('alg', 'span', 'int', 'acc', 'sd_acc', 'time', 'sd_time', 'num')
colnames(x2) = c('alg', 'span', 'int', 'acc', 'sd_acc', 'time', 'sd_time', 'num')

# TODO: fix this to sum up the time
### adjusting time by the interpolation of spline
##
### loading absolute times of interpolation
##xint = read.table('res_partial_time_interpolate.txt')
##colnames(xint) = c('Method', 'span', 'int', 'time')
##
###method='spline'
##
### summing up the interpolation time, per method, in the time column
##for(span in unique(x2$span))
##{
##    for(int in unique(x2$int))
##    {
##        addtime = xint[xint$Method == method & xint$span == span & xint$int == int,'time']
##        x2[x2$span == span & x2$int == int,'time'] = 
##            x2[x2$span == span & x2$int == int,'time'] + addtime
##    }
##}

#
x = rbind(x1, x2)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'int', 'acc', 'sd_acc', 'time', 'sd_time', 'num')

x$span = factor(x$span, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))
x$alg = factor(x$alg, 
                levels=c('3', '4', '5', '6', 'knn','randf','tsf','rise'),
                labels=c('D=3', 'D=4', 'D=5', 'D=6', 'Knn','RandF','TSF','RISE'))

x$int = as.numeric(gsub('min', '', x$int))


#D=3

# length of computed features
N = 30
#N = 10

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
        geom_line() + geom_point(size=6) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0.45, 0.95) +
        geom_errorbar(aes(ymin=acc-ci_acc, ymax=acc+ci_acc), width=.2) +
        theme(text=element_text(size=30)) +
        labs(color="Alg", shape="Alg", title=span) 
        #theme(text=element_text(size=16,  family='Sans')) 
    
    fname=paste('img/fig_accuracy_asos_1min_',
                gsub(' ', '', as.character(span)),'_sum.pdf', sep='')
    ggsave(fname, p, width=10)

    # time
    p = ggplot(data=x_i, aes(x=int, y=time, color=alg, shape=alg)) + 
        geom_line() + geom_point(size=6) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0.45, 0.95) +
        geom_errorbar(aes(ymin=time-ci_time, ymax=time+ci_time), width=.2) +
        theme(text=element_text(size=30)) +
        labs(color="Alg", shape="Alg", title=span) 
        #theme(text=element_text(size=16,  family='Sans')) 

    fname=paste('img/fig_time_asos_1min_',
                gsub(' ', '', as.character(span)),'_sum.pdf', sep='')
    ggsave(fname, p, width=10)
 
    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
}




