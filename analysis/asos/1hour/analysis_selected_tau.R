
library(ggplot2)
library(RColorBrewer)

# loading results
x = read.table('res_partial_asos_1hour_selected_tau.txt', stringsAsFactors=F)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'mean', 'sd', 'num')

#x$span = factor(x$span, 
#                levels=c("1month", "2month", "3month", "4month", "5month", "6month"),
#                labels=c("1-month", "2-months", "3-months", "4-months", "5-months", "6-months"))
x$alg = factor(x$alg, 
                levels=c('3', '4', '5', '6'),
                labels=c('D=3', 'D=4', 'D=5', 'D=6'))

x$span = as.numeric(gsub('month', '', x$span))

#D=3

# length of computed features
N = 30
#N = 10

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

#print(x)
#quit()

#for(span in unique(x$span))
#{
    # filtering by span
    #x_i = x[x$span == span,]

    # accuracy
    p = ggplot(data=x, aes(x=span, y=mean, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time span (months)", breaks=c(1,2,3,4,5,6)) +
        scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0, 30) +
        geom_errorbar(aes(ymin=mean-ci, ymax=mean+ci), size=0.8, width=0.4) +
        theme(text=element_text(size=26)) +
        labs(color="Alg", shape="Alg", linetype="Alg") 
    
    fname=paste('img/fig_selected_tau_asos_1hour_.pdf', sep='')
    ggsave(fname, p, width=10)

#}

