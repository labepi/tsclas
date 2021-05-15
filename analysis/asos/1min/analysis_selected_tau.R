
library(ggplot2)
library(RColorBrewer)
suppressMessages(library(ggforce))
suppressMessages(library(grid))
suppressMessages(library(gridExtra))
suppressMessages(library(factoextra))


# loading results
x = read.table('res_partial_asos_1min_selected_tau.txt', stringsAsFactors=F)

# converting to data.frame
x = as.data.frame(x)
colnames(x) = c('alg', 'span', 'int', 'mean', 'sd', 'num')

x$span = factor(x$span, 
                levels=c('1day','1week','2week','3week'),
                labels=c('1 Day','1 Week','2 Weeks','3 Weeks'))
x$alg = factor(x$alg, 
                levels=c('3', '4', '5', '6'),
                labels=c('D=3', 'D=4', 'D=5', 'D=6'))

x$int = as.numeric(gsub('min', '', x$int))

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

# The palette with grey:
#cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
#          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbp1 <- c("#888888", "#E69F00", "#56B4E9", "#009E73",
          "#661100", "#0072B2", "#D55E00", "#CC79A7")

# The palette with black:
cbp2 <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
          "#999999", "#0072B2", "#D55E00", "#CC79A7")
          #"#F0E442", "#0072B2", "#D55E00", "#CC79A7")


# to join all times plots (for each span)
p_l = list()

# to save the legend
mylegIn = NULL

# the position of the plot
i_num = 0

for(span in unique(x$span))
{
    # TODO: just to simply remove this span
    if (span == '3 Weeks')
        next

    # filtering by span
    x_i = x[x$span == span,]

    i_num = i_num + 1

    myspan = gsub(' ', '-', span)
    myspan = gsub('s', '', myspan)
    myspan = tolower(myspan)
    mytitle = paste('(',letters[i_num], ') ', myspan,' time span.', sep='')

    # accuracy
    p = ggplot(data=x_i, aes(x=int, y=mean, color=alg, shape=alg)) + 
        geom_line(aes(linetype=alg), size=1) + 
        geom_point(size=6, stroke=1) + theme_bw() + 
        #ylab('Accuracy') +
        ylab(expression(paste(tau,"*", sep=''))) +
        scale_x_continuous(name ="Time intervals (min)", breaks=c(1,5,10,15)) +
        #scale_x_continuous(name=expression(tau^"*"), breaks=c(1,5,10,15)) +
        #scale_color_manual(values = rev(brewer.pal(8,'Paired'))) + 
        scale_color_manual(values = cbp1) + 
        #scale_color_manual(values = brewer.pal(8, 'Dark2')) +
        scale_shape_manual(values=1:nlevels(x$alg)) +
        ylim(0, 30) +
        geom_errorbar(aes(ymin=mean-ci, ymax=mean+ci), size=0.8, width=0.4) +
        theme(text=element_text(size=26), plot.title=element_text(size = 26)) +
        labs(color="Algorithms:", shape="Algorithms:", linetype="Algorithms:",
            title=mytitle) +
        theme(plot.title=element_text(hjust=0.5), 
                legend.position="bottom", legend.box = "horizontal") +
        guides(color = guide_legend(nrow = 1))
 

    p_l[[i_num]] = p

    if (is.null(mylegIn))
    {
        # extracting the legend
        tmp = ggplot_gtable(ggplot_build(p_l[[i_num]]))
        leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
        mylegIn = tmp$grobs[[leg]]
    }

    p_l[[i_num]] = p_l[[i_num]] + theme(legend.position='none')
    

    fname=paste('img/fig_selected_tau_asos_1min_',
                gsub(' ', '', as.character(span)),'.pdf', sep='')
    ggsave(fname, p, width=10)

}

# saving all plots together
p_all = grid.arrange(arrangeGrob(grobs=p_l, ncol=3),  
                            mylegIn,
                            heights=c(15,2))
fname='img/fig_selected_tau_asos_1min_ALL.pdf'
ggsave(fname, plot=p_all, width=20, height=6, dpi=600)

