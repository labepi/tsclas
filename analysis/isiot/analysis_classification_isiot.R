#
# script for analysing the resulting classification
#

library(ggplot2)

# feats
x = read.table('res_partial_isiot.txt')

x[x[,2] == 'raw',2] = 'Raw'
x[x[,2] == 'spline',2] = 'Spline'

df = as.data.frame(x)

labnames = c('D', 'type', 'acc', 'sd')
colnames(df) = labnames

df$D = as.factor(df$D)
df$type = as.factor(df$type)
df$acc = as.numeric(df$acc)
df$sd = as.numeric(df$sd)

N = 30

# Calculate standard error of the mean
# standard error
df$se = df$sd/sqrt(N)

# Confidence interval multiplier for standard error
conf.interval = 0.95
# Calculate t-statistic for confidence interval: 
# e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
ciMult = qt(conf.interval/2 + .5, N-1)
df$ci = df$se * ciMult



#dfraw = df[df$type==3,]
#dffilter = df[df$type==5,]


p = ggplot(data=df, aes(x=D, y=acc, fill=type)) +
    geom_bar(stat="identity", position=position_dodge(), color='black') +
    #geom_errorbar(aes(ymin=acc-sd, ymax=acc+sd), 
    geom_errorbar(aes(ymin=acc-ci, ymax=acc+ci), 
                width=.2, position=position_dodge(.9)) +
    theme_bw() + scale_fill_brewer(palette="Blues") + #scale_fill_grey()
    coord_cartesian(ylim=c(0.7,1.0)) +
    geom_hline(yintercept=0.93, col=2, linetype=2, size=2) +
    geom_hline(yintercept=0.75, col=2, size=2) +
    theme(text=element_text(size=16), legend.title=element_blank()) +
    ylab('Accuracy') +
    annotate("text", label="0.75", x=0.8, y=0.76, size=8, colour="red") +
    annotate("text", label="0.93", x=0.8, y=0.94, size=8, colour="red") 

ggsave('img/fig_barplot_isiot.pdf', p, width=10)


quit()


#coord_cartesian(xlim = c(0, 4), ylim=c(0.7,1.0), clip = "off")

