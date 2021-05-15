
library(ggplot2)
library(RColorBrewer)
suppressMessages(library(ggforce))
suppressMessages(library(grid))
suppressMessages(library(gridExtra))
suppressMessages(library(factoextra))


# getting command line args
args = commandArgs(trailingOnly = TRUE)

if (length(args) == 0)
{
    print('method not informed: [linear]/polynomial/spline')
    method='linear'
    #quit()
} else {
    method=args[1]
}


# loading results
x1 = read.table('res_partial_asos_1hour4.txt', stringsAsFactors=F)
x2 = read.table(paste('res_partial_asos_1hour4_literature_',method,'.txt', sep=''), 
                stringsAsFactors=F)
x = rbind(x1, x2)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'acc', 'sd_acc', 
                'time_train', 'sd_time_train', 
                'time_test', 'sd_time_test', 'num')

# formatting columns
#x$span = factor(x$span, 
#                levels=c('1month','2month','3month','4month','5month','6month'),
#                labels=c('1-month','2-months','3-months','4-months','5-months','6months'))
x$alg = factor(x$alg, 
                levels=c('3', '4', '5', '6', 'knn','randf','tsf','rise'),
                labels=c('D=3', 'D=4', 'D=5', 'D=6', 'KNN','RANDF','TSF','RISE'))

x$span = as.numeric(gsub('month', '', x$span))

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

#print(x)
#print(head(x))
#quit()

# The palette with grey:
#cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
#          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbp1 <- c("#888888", "#E69F00", "#56B4E9", "#009E73",
          "#661100", "#0072B2", "#D55E00", "#CC79A7")
#cbp1 = rev(cbp1)

# The palette with black:
cbp2 <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
          "#999999", "#0072B2", "#D55E00", "#CC79A7")
          #"#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# to join all accuracy plots (for each span)
p_l = list()

# to save the legend
mylegIn = NULL



#for(span in unique(x$span))
#{
    # filtering by span
    #x_i = x[x$span == span,]

    #print(range(x_i$acc))

    # accuracy
    
    p = ggplot(data=x, aes(x=span, y=acc, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time span (months)", breaks=c(1,2,3,4,5,6)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) +
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0.5, 0.99) +
        geom_errorbar(aes(ymin=acc-ci_acc, ymax=acc+ci_acc), size=0.8, width=0.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 24)) +
        labs(color="Algorithms:", shape="Algorithms:", linetype="Algorithms:",
             title='(a) Classification accuracy.') +
        #labs(color="Alg", shape="Alg", linetype="Alg", title=span) 
        #theme(text=element_text(size=16,  family='Sans')) 
        theme(plot.title=element_text(hjust=0.5), legend.position="bottom", legend.box = "horizontal") +
        guides(color = guide_legend(nrow = 1))
 
 
    p_l[[1]] = p

    if (is.null(mylegIn))
    {
        # extracting the legend
        tmp = ggplot_gtable(ggplot_build(p_l[[1]]))
        leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
        mylegIn = tmp$grobs[[leg]]
    }

    p_l[[1]] = p_l[[1]] + theme(legend.position='none')
    
    fname=paste('img/fig_accuracy_asos_1hour4.pdf', sep='')
    #fname=paste('img/fig_accuracy_asos_1hour_',
    #            gsub(' ', '', as.character(span)),'.pdf', sep='')
    ggsave(fname, p, width=10)

    # time train
    p = ggplot(data=x, aes(x=span, y=time_train, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time span (months)", breaks=c(1,2,3,4,5,6)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) +
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0, 5000) +
        geom_errorbar(aes(ymin=time_train-ci_time_train, ymax=time_train+ci_time_train), size=1, width=.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 24)) +
        labs(color="Alg", shape="Alg", linetype="Alg", title='(b) Training time.') +
        #labs(color="Alg", shape="Alg", linetype="Alg", title=span) 
        theme(plot.title=element_text(hjust=0.5), 
              #legend.position="bottom", legend.box = "horizontal") +
              legend.position="none")


    p_l[[2]] = p


    fname=paste('img/fig_time_asos_1hour4_train.pdf', sep='')
    #fname=paste('img/fig_time_asos_1hour_',
    #            gsub(' ', '', as.character(span)),'_train.pdf', sep='')
    ggsave(fname, p, width=10)
 
    
    # time test
    p = ggplot(data=x, aes(x=span, y=time_test, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time span (months)", breaks=c(1,2,3,4,5,6)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) +
        scale_shape_manual(values=1:nlevels(x$alg)) +
        #ylim(0, 1300) +
        geom_errorbar(aes(ymin=time_test-ci_time_test, ymax=time_test+ci_time_test), size=1, width=.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Alg", shape="Alg", linetype="Alg", title='(c) Testing time.') +
        #labs(color="Alg", shape="Alg", linetype="Alg", title=span) 
        theme(plot.title=element_text(hjust=0.5), 
              #legend.position="bottom", legend.box = "horizontal") +
              legend.position="none")



    p_l[[3]] = p

    fname=paste('img/fig_time_asos_1hour4_test.pdf', sep='')
    #fname=paste('img/fig_time_asos_1hour_',
    #            gsub(' ', '', as.character(span)),'_test.pdf', sep='')
    ggsave(fname, p, width=10)
 
    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
#}


# saving all accuracies together
pall = grid.arrange(arrangeGrob(grobs=p_l, ncol=3),  
                            mylegIn,
                            heights=c(15,2))
fname='img/fig_accuracy_asos_1hour4_ALL.pdf'
ggsave(fname, plot=pall, width=20, height=6, dpi=600)

