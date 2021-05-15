
x = read.table('analysis_texas.txt')

span_l =  c('1day', '1week', '2week') # 3week
int_l = c('1min', '5min', '10min', '15min')

xlab='Expected accuracy gain'
ylab='Actual accuracy gain'

lim_min=c(0.5,0.8,0.9)
lim_max=c(1.1,1.05,1.1)

for(k in 1:length(span_l))
{
    span = span_l[k]

    # filtering by time span
    xa = x[x[,2] == span,]

    fname = paste('img/fig_texas_',span,'.pdf', sep='')
    pdf(fname, width=12, height=12)
    
    par(mfrow=c(2,2))

    for(int in int_l)
    {
        
        # filtering by time interval
        xb = xa[xa[,3] == int,]

        #xb[,3] = as.factor(xb[,3])

        plot(NA, NA, xlim=c(lim_min[k], lim_max[k]), 
                     ylim=c(lim_min[k], lim_max[k]), 
                     main=int, xlab=xlab, ylab=ylab)
        abline(v=1, h=1)

        for(i in 1:nrow(xb))
        {
            xi = xb[i,]
            xi_l = unlist(strsplit(xi[,4], ';'))
            train_acc = as.numeric(unlist(strsplit(xi_l[1], ',')))
            test_acc = as.numeric(unlist(strsplit(xi_l[2], ',')))
            base_acc = as.numeric(xi_l[3])
            
            # check coloring by D or span, or min
            points(train_acc/base_acc, test_acc/base_acc, 
                   col=xi[,1]-2, pch=xi[,1]-2)

        }

    }

    dev.off()

}


# average version

for(k in 1:length(span_l))
{
    span = span_l[k]

    # filtering by time span
    xa = x[x[,2] == span,]

    fname = paste('img/fig_texas_',span,'_mean.pdf', sep='')
    pdf(fname, width=12, height=12)
    
    par(mfrow=c(2,2))

    for(int in int_l)
    {
        
        # filtering by time interval
        xb = xa[xa[,3] == int,]

        #xb[,3] = as.factor(xb[,3])

        plot(NA, NA, xlim=c(lim_min[k], lim_max[k]), 
                     ylim=c(lim_min[k], lim_max[k]), 
                     main=int, xlab=xlab, ylab=ylab)
        abline(v=1, h=1)

        for(i in 1:nrow(xb))
        {
            xi = xb[i,]
            xi_l = unlist(strsplit(xi[,4], ';'))
            train_acc = as.numeric(unlist(strsplit(xi_l[1], ',')))
            test_acc = as.numeric(unlist(strsplit(xi_l[2], ',')))
            base_acc = as.numeric(xi_l[3])
            
            # check coloring by D or span, or min
            points(mean(train_acc)/base_acc, mean(test_acc)/base_acc, 
                   col=xi[,1]-2, pch=xi[,1]-2)

        }

    }

    dev.off()

}


