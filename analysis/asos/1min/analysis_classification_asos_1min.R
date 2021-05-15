
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
x1 = read.table('res_partial_asos_1min.txt', stringsAsFactors=F)
x2 = read.table(paste('res_partial_asos_1min_literature_',method,'.txt', sep=''), 
                stringsAsFactors=F)
x = rbind(x1, x2)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'int', 'acc', 'sd_acc', 
                'time_train', 'sd_time_train', 
                'time_test', 'sd_time_test', 'num')

# formatting columns
x$span = factor(x$span, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))
x$alg = factor(x$alg, 
                levels=c('3', '4', '5', '6', 'knn','randf','tsf','rise'),
                labels=c('D=3', 'D=4', 'D=5', 'D=6', 'KNN','RANDF','TSF','RISE'))

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

# The palette with grey:
#cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
          #"#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbp1 <- c("#888888", "#E69F00", "#56B4E9", "#009E73",
          "#661100", "#0072B2", "#D55E00", "#CC79A7")
#cbp1 = rev(cbp1)

# The palette with black:
cbp2 <- c("#D55E00", "#E69F00", "#56B4E9", "#009E73",
          "#CC79A7", "#0072B2", "#999999", "#000000")
          #"#F0E442", "#0072B2", "#D55E00", "#CC79A7")

cbp3 <- c("#88CCEE", "#CC6677", "#DDCC77", "#117733", "#332288", "#AA4499", 
          "#44AA99", "#999933", "#882255", "#661100", "#6699CC", "#888888")

# to join all accuracy plots (for each span)
p_acc = list()

# to join all times plots (for each span)
p_times = list()

# to save the legend
mylegIn = NULL

# the position of the plot
i_num = 0

for(span in unique(x$span))
{
    # TODO: just to simply remove this span
    if (span == '3 Weeks')
        next

    i_num = i_num + 1

    # filtering by span
    x_i = x[x$span == span,]

    #print(range(x_i$acc))

    myspan = gsub(' ', '-', span)
    myspan = gsub('s', '', myspan)
    myspan = tolower(myspan)
    mytitle = paste('(',letters[i_num], ') ', myspan,' time span.', sep='')
    #paste('^',maps_num[i,1],'-',sep=''), 
    #                        paste(maps_num[i,2],'-',sep=''), 
    #                        labs)


    #### accuracy ####

    p = ggplot(data=x_i, aes(x=int, y=acc, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Accuracy') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = cbp3) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0.5, 0.99) +
        geom_errorbar(aes(ymin=acc-ci_acc, ymax=acc+ci_acc), size=0.8, width=0.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Algorithms:", shape="Algorithms:", linetype="Algorithms:",
             title=mytitle) +
        #labs(color="Alg", shape="Alg", linetype="Alg", title=span) 
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
                gsub(' ', '', as.character(span)),'.pdf', sep='')
    ggsave(fname, p, width=10)


    #### time train ####
    
    mytitle = paste('(',letters[i_num], ') ', myspan,' training time.', sep='')

    p = ggplot(data=x_i, aes(x=int, y=time_train, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0, 5000) +
        geom_errorbar(aes(ymin=time_train-ci_time_train, ymax=time_train+ci_time_train), size=1, width=.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Algorithms", shape="Algorithms", linetype="Algorithms",
             title=mytitle) +
        #labs(color="Alg", shape="Alg", linetype="Alg", title=span) 
        theme(plot.title=element_text(hjust=0.5), 
              #legend.position="bottom", legend.box = "horizontal") +
              legend.position="none")

    # inserting in the same list
    p_times[[i_num]] = p

    fname=paste('img/fig_time_asos_1min_',
                gsub(' ', '', as.character(span)),'_train.pdf', sep='')
    ggsave(fname, p, width=10)
 
    #### time test ####
    
    mytitle = paste('(',letters[i_num+3], ') ', myspan,' prediction time.', sep='')
    
    p = ggplot(data=x_i, aes(x=int, y=time_test, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + geom_point(size=6, stroke=1) + theme_bw() + ylab('Time (s)') +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) + 
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0, 1300) +
        geom_errorbar(aes(ymin=time_test-ci_time_test, ymax=time_test+ci_time_test), size=1, width=.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Alg", shape="Alg", linetype="Alg",
             title=mytitle) +
        #labs(color="Alg", shape="Alg", linetype="Alg", title=span) 
        theme(plot.title=element_text(hjust=0.5), 
              #legend.position="bottom", legend.box = "horizontal") +
              legend.position="none")
    
    # inserting in the same list
    p_times[[i_num+3]] = p

    fname=paste('img/fig_time_asos_1min_',
                gsub(' ', '', as.character(span)),'_test.pdf', sep='')
    ggsave(fname, p, width=10)
 
    #scale_shape_discrete(labels=c('a','b','c','d','e')) +
}

# saving all accuracies together
pall_acc = grid.arrange(arrangeGrob(grobs=p_acc, ncol=3),  
                            mylegIn,
                            heights=c(15,2))
fname='img/fig_accuracy_asos_1min_ALL.pdf'
ggsave(fname, plot=pall_acc, width=20, height=6, dpi=600)
#ggsave(fname, plot=pall, width=10, height=6, device=Cairo_ps, dpi=600)

#ggsave(paste('img/fig_joint_',lab,'-pst.eps', sep=''), plot=pall, 
 
# saving all times together
pall_times = grid.arrange(arrangeGrob(grobs=p_times, ncol=3),  
                            mylegIn,
                            heights=c(15,2))
fname='img/fig_time_asos_1min_ALL.pdf'
ggsave(fname, plot=pall_times, width=20, height=12, dpi=600)

