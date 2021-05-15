
library(ggplot2)
library(RColorBrewer)

# loading results
x = read.table('res_partial_asos_1hour.txt')

# converting to data.fram
x = as.data.frame(x)
colnames(x) = c('D', 'span', 'acc', 'sd')

x$span = as.factor(x$span)
x$span = factor(x$span, 
                levels=c('1month','2month','3month'),
                labels=c('1 month','2 months','3 months'))
#levels(x$span) = c('1 day', '1 month', '1 week', '2 weeks', '3 weeks')
#x$int = as.numeric(gsub('min', '', x$int))

#D=3

# length of computed features
N = 30

# source
# http://www.cookbook-r.com/Manipulating_data/Summarizing_data/

# Calculate standard error of the mean
# standard error
x$se = x$sd/sqrt(N)

# Confidence interval multiplier for standard error
conf.interval = 0.95
# Calculate t-statistic for confidence interval: 
# e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
ciMult = qt(conf.interval/2 + .5, N-1)
x$ci = x$se * ciMult


D_l=3:6

#for(D in D_l)
#{

#    # filtering by D
#    x_i = x[x$D == D,]

    p = ggplot(data=x, aes(x=D, y=acc, color=span, shape=span)) + 
        geom_line() + geom_point(size=3) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="D", breaks=c(3,4,5,6)) +
        scale_color_manual(values = rev(brewer.pal(9,'Blues'))) + 
        #geom_errorbar(aes(ymin=acc-sd, ymax=acc+sd), width=.2) +
        #geom_errorbar(aes(ymin=acc-se, ymax=acc+se), width=.2) +
        geom_errorbar(aes(ymin=acc-ci, ymax=acc+ci), width=.2) +
        theme(text=element_text(size=16)) +
        labs(color="Time span", shape="Time span") 
        #theme(text=element_text(size=16,  family='Sans')) 

    #p
    fname=paste('img/fig_accuracy_asos_1hour.pdf', sep='')
    ggsave(fname, p, width=10)

    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
#}




quit()

v = c(
0.676217765042980,
0.657593123209169,
0.657593123209169,
0.634670487106017,
0.641833810888252,
0.654727793696275,
0.656160458452722,
0.674785100286533,
0.666189111747851,
0.654727793696275,
0.657593123209169,
0.680515759312321,
0.651862464183381,
0.653295128939828,
0.687679083094556,
0.679083094555874,
0.664756446991404,
0.650429799426934,
0.512893982808023,
0.646131805157593,
0.671919770773639,
0.640401146131805,
0.653295128939828,
0.656160458452722,
0.653295128939828,
0.677650429799427,
0.671919770773639,
0.667621776504298,
0.677650429799427,
0.644699140401146
)
