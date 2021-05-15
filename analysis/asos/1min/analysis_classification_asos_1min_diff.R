
library(ggplot2)
library(RColorBrewer)


# getting command line args
#args = commandArgs(trailingOnly = TRUE)
#
#if (length(args) == 0)
#{
#    print('method not informed: linear/polynomial/[spline]')
#    method='linear'
#    #quit()
#} else {
#    method=args[1]
#}


# loading results
x = read.table('res_partial_asos_1min_diff.txt', stringsAsFactors=F)

# joining the two spans
x[,2] = paste(x[,2], x[,3], sep='-')

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'span2', 'int', 
                'acc', 'sd_acc', 
                'time_train', 'sd_time_train', 
                'time_test', 'sd_time_test', 'num')

# formatting columns
x$span = factor(x$span, 
                levels=c('2week-1week', '2week-1day','1week-1day'),
                labels=c('2 Weeks - 1 Week', '2 Weeks - 1 Day','1 Week - 1 Day'))
x$span2 = factor(x$span2, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))
x$alg = factor(x$alg, 
                levels=c('3', '4', '5', '6', 'knn','randf','tsf','rise'),
                labels=c('D=3', 'D=4', 'D=5', 'D=6', 'Knn','RandF','TSF','RISE'))

x$int = as.numeric(gsub('min', '', x$int))

# length of computed features
N = 30

# source
# http://www.cookbook-r.com/Manipulating_data/Summarizing_data/

# Calculate standard error of the mean
# standard error
x$se_acc = x$sd_acc/sqrt(x$num)
x$se_time_train = x$sd_time_train/sqrt(x$num)
x$se_time_test = x$sd_time_test/sqrt(x$num)


# Confidence interval multiplier for standard error
conf.interval = 0.95
# Calculate t-statistic for confidence interval: 
# e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
ciMult = qt(conf.interval/2 + .5, N-1)
x$ci_acc = x$se_acc * ciMult
x$ci_time_train = x$se_time_train * ciMult
x$ci_time_test = x$se_time_test * ciMult

#print(head(x))
#quit()

for(span in unique(x$span))
{
    # filtering by span
    x_i = x[x$span == span,]

    # accuracy
    p = ggplot(data=x_i, aes(x=int, y=acc, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0.45, 0.95) +
        geom_errorbar(aes(ymin=acc-ci_acc, ymax=acc+ci_acc), size=0.8, width=0.4) +
        theme(text=element_text(size=26)) +
        labs(color="Alg", shape="Alg", linetype="Alg", title=span) 
        #theme(text=element_text(size=16,  family='Sans')) 
    
    fname=paste('img/fig_accuracy_asos_1min_',
                gsub(' ', '', as.character(span)),'_diff.pdf', sep='')
    ggsave(fname, p, width=10)

    # time train
    p = ggplot(data=x_i, aes(x=int, y=time_train, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0.45, 0.95) +
        geom_errorbar(aes(ymin=time_train-ci_time_train, ymax=time_train+ci_time_train), size=1, width=.4) +
        theme(text=element_text(size=26)) +
        labs(color="Alg", shape="Alg", linetype="Alg", title=span) 

    fname=paste('img/fig_time_asos_1min_',
                gsub(' ', '', as.character(span)),'_diff_train.pdf', sep='')
    ggsave(fname, p, width=10)
 
    # time test
    p = ggplot(data=x_i, aes(x=int, y=time_test, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0.45, 0.95) +
        geom_errorbar(aes(ymin=time_test-ci_time_test, ymax=time_test+ci_time_test), size=1, width=.4) +
        theme(text=element_text(size=26)) +
        labs(color="Alg", shape="Alg", linetype="Alg", title=span) 

    fname=paste('img/fig_time_asos_1min_',
                gsub(' ', '', as.character(span)),'_diff_test.pdf', sep='')
    ggsave(fname, p, width=10)
 
    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
}



