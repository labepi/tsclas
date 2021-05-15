#
# script for analysing the resulting classification
#

library(ggplot2)
library(RColorBrewer)


# times
x = read.table('res_partial_time_interpolate.txt')

x = as.data.frame(x)

labnames = c('Method', 'span', 'int', 'time')
colnames(x) = labnames

x$Method = factor(x$Method, 
                levels=c('linear', 'polynomial', 'spline'),
                labels=c('Linear', 'Polynomial', 'Spline'))

x$span = factor(x$span, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))

x$int = as.numeric(gsub('min', '', x$int))


for(span in unique(x$span))
{
    # filtering by span
    x_i = x[x$span == span,]

    # time
    p = ggplot(data=x_i, aes(x=int, y=time, color=Method, shape=Method)) + 
        geom_line() + geom_point(size=3) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_shape_manual(values=1:nlevels(x$Method)) +
        #ylim(0.45, 0.95) +
        #geom_errorbar(aes(ymin=time-ci_time, ymax=time+ci_time), width=.2) +
        theme(text=element_text(size=16)) +
        labs(color="Method", shape="Method", title=span) 
        #theme(text=element_text(size=16,  family='Sans')) 

    fname=paste('img/fig_time_interpolate_',
                gsub(' ', '', as.character(span)),'.pdf', sep='')
    ggsave(fname, p, width=10)
 
}


