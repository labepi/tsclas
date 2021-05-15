
library(ggplot2)
library(RColorBrewer)
suppressMessages(library(ggforce))
suppressMessages(library(grid))
suppressMessages(library(gridExtra))
suppressMessages(library(factoextra))


# getting command line args
args = commandArgs(trailingOnly = TRUE)


if (length(args) != 2)
{
    print('method not informed: [linear]/polynomial/spline and gapnum')
    method='linear'
    gap=10
    #quit()
} else {
    method=args[1]
    gap=args[2]
}

# TODO: parei aqui
# - decidir como juntar todas as figuras em uma só
# - o problema é que pelo gap carrega os txt's diferentes, ver isso
# dentro do looping for

#span_labels=c('1 Day','1 Week','2 Weeks','3 Weeks')
span_labels=c('1 Day','1 Week','2 Weeks')
gaps_l = c(10,30,50)

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
p_acc = list()

# to join all times plots (for each span)
p_times = list()

# to save the legend
mylegIn = NULL

# the position of the plot
i_num = 0

i_num_time = 0


for(span in span_labels)
{
    for(gap in gaps_l)
    {
        
# loading results
x1 = read.table(paste('res_partial_asos_1min_gap',gap,'.txt', sep=''), stringsAsFactors=F)
print('Loaded own res')
x2 = read.table(paste('res_partial_asos_1min_literature_',method,'_gap',gap,'.txt', sep=''), 
                stringsAsFactors=F)
print('Loaded lit res')

x = rbind(x1, x2)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'int', 'acc', 'sd_acc', 
                'time_train', 'sd_time_train', 
                'time_test', 'sd_time_test', 'num')


#print(head(x2))

# formatting columns
x$span = factor(x$span, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))
x$alg = factor(x$alg, 
                levels=c('3', '4', '5', '6', 'knn','randf','tsf','rise'),
                labels=c('D=3', 'D=4', 'D=5', 'D=6', 'Knn','RandF','TSF','RISE'))

x$int = as.numeric(gsub('min', '', x$int))


# length of computed features
N = 30
#N = 10

#print(dim(x))
#print(head(x))
#print(tail(x))
#quit()

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


#for(span in unique(x$span))
#{
    # TODO: just to simply remove this span
    if (span == '3 Weeks')
        next

    i_num = i_num + 1

    # filtering by span
    x_i = x[x$span == span,]

    myspan = gsub(' ', '-', span)
    myspan = gsub('s', '', myspan)
    myspan = tolower(myspan)
    
    mytitle = paste('(',letters[i_num], ') ', myspan,' time span\nwith ',gap,'% gap size.', sep='')
 

    ### accuracy

    p = ggplot(data=x_i, aes(x=int, y=acc, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) +
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0.5, 1.0) +
        geom_errorbar(aes(ymin=acc-ci_acc, ymax=acc+ci_acc), size=0.8, width=0.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Algorithms:", shape="Algorithms:", linetype="Algorithms:",
             title=mytitle) +
        #theme(text=element_text(size=16,  family='Sans')) 
        theme(plot.title=element_text(hjust=0.5), legend.position="bottom", legend.box = "horizontal") +
        guides(color = guide_legend(nrow = 1))

    p_acc[[i_num]] = p

    if (is.null(mylegIn))
    {
        # extracting the legend
        tmp = ggplot_gtable(ggplot_build(p_acc[[i_num]]))
        leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
        mylegIn = tmp$grobs[[leg]]
    }

    p_acc[[i_num]] = p_acc[[i_num]] + theme(legend.position='none')
 
    fname=paste('img/fig_accuracy_asos_1min_',
                gsub(' ', '', as.character(span)),'_gap',gap,'.pdf', sep='')
    ggsave(fname, p, width=10)


    # time train

    if (gap == 50)
    {
        i_num_time = i_num_time + 1
    }

    mytitle = paste('(',letters[i_num_time], ') ', myspan,' training time\nwith ',gap,'% gap size.', sep='')

    p = ggplot(data=x_i, aes(x=int, y=time_train, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) +
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0, 6000) +
        geom_errorbar(aes(ymin=time_train-ci_time_train, ymax=time_train+ci_time_train), size=1, width=.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Alg", shape="Alg", linetype="Alg", title=mytitle) +
        theme(plot.title=element_text(hjust=0.5), 
                #legend.position="bottom", legend.box = "horizontal") +
                legend.position="none")

    if (gap == 50)
    {
        # inserting in the same list
        p_times[[i_num_time]] = p
    }

    fname=paste('img/fig_time_asos_1min_',
                gsub(' ', '', as.character(span)),'_gap',gap,'_train.pdf', sep='')
    ggsave(fname, p, width=10)
 
    # time test

    mytitle = paste('(',letters[i_num_time+3], ') ', myspan,' prediction time\nwith ',gap,'% gap size.', sep='')

    p = ggplot(data=x_i, aes(x=int, y=time_test, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) +
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0, 1500) +
        geom_errorbar(aes(ymin=time_test-ci_time_test, ymax=time_test+ci_time_test), size=1, width=.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Alg", shape="Alg", linetype="Alg", title=mytitle) +
        theme(plot.title=element_text(hjust=0.5), 
                #legend.position="bottom", legend.box = "horizontal") +
                legend.position="none")

    if (gap == 50)
    {
        # inserting in the same list
        p_times[[i_num_time+3]] = p
    }
    
    fname=paste('img/fig_time_asos_1min_',
                gsub(' ', '', as.character(span)),'_gap',gap,'_test.pdf', sep='')
    ggsave(fname, p, width=10)

    #quit()
    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
#}


    }
}

# saving all accuracies together
pall_acc = grid.arrange(arrangeGrob(grobs=p_acc, ncol=3),  
                            mylegIn,
                            heights=c(20,2))
fname='img/fig_accuracy_asos_1min_ALL_gap.pdf'
ggsave(fname, plot=pall_acc, width=20, height=20, dpi=600)

# saving all times together
pall_times = grid.arrange(arrangeGrob(grobs=p_times, ncol=3),  
                            mylegIn,
                            heights=c(15,2))
fname='img/fig_time_asos_1min_ALL_gap50.pdf'
ggsave(fname, plot=pall_times, width=20, height=12, dpi=600)

