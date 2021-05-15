# original data
x = read.csv('data/asos/1min/asos_2020_jan_1week_1min.csv', header=F, stringsAsFactors=F)

# truncate data for memory issues
rows = 1:10
x = x[rows,-1]

# methods
xl = read.csv('data/asos/1min/asos_2020_jan_1week_1min_linear.csv', 
              header=F, stringsAsFactors=F)
xl = xl[rows,-1]

xs = read.csv('data/asos/1min/asos_2020_jan_1week_1min_spline.csv', 
             header=F, stringsAsFactors=F)
xs = xs[rows,-1]

xp = read.csv('data/asos/1min/asos_2020_jan_1week_1min_polynomial.csv', 
             header=F, stringsAsFactors=F)
xp = xp[rows,-1]

xc = read.csv('data/asos/1min/asos_2020_jan_1week_1min_pchip.csv', 
             header=F, stringsAsFactors=F)
xc = xc[rows,-1]


# gaps

rows = 1:1000

# original data
x = read.csv('data/asos/1min/asos_2020_jan_1week_1min.csv', header=F, stringsAsFactors=F)
x = x[rows,-1]
#gap
xg = read.csv('data/asos/1min/gap/asos_2020_jan_1week_1min_gap10.csv', 
             header=F, stringsAsFactors=F)
xg = xg[rows,-1]
xl = read.csv('data/asos/1min/gap/asos_2020_jan_1week_1min_gap10_linear.csv', 
              header=F, stringsAsFactors=F)
xl = xl[rows,-1]
xs = read.csv('data/asos/1min/gap/asos_2020_jan_1week_1min_gap10_spline.csv', 
             header=F, stringsAsFactors=F)
xs = xs[rows,-1]
xp = read.csv('data/asos/1min/gap/asos_2020_jan_1week_1min_gap10_polynomial.csv', 
             header=F, stringsAsFactors=F)
xp = xp[rows,-1]
xc = read.csv('data/asos/1min/gap/asos_2020_jan_1week_1min_gap10_pchip.csv', 
             header=F, stringsAsFactors=F)
xc = xc[rows,-1]

x = apply(x, 2, as.numeric)
xg = apply(xg, 2, as.numeric)
xl = apply(xl, 2, as.numeric)
xs = apply(xs, 2, as.numeric)
xp = apply(xp, 2, as.numeric)
xc = apply(xc, 2, as.numeric)


# plotting lines
int=8000:10000
par(mfrow=c(6,1),family='Sans')
plot(x[1,int], type='p', main='original', pch=19)
plot(xg[1,int], type='p', main='original gap', pch=19)
plot(xl[1,int], type='p', main='linear', pch=19, col=2)
plot(xs[1,int], type='p', main='spline', pch=19, col=3)
plot(xp[1,int], type='p', main='polynomial', pch=19, col=4)
plot(xc[1,int], type='p', main='pchip', pch=19, col=5)


# now, analysis of the gaps

# correlation
cor(x[1,int], xl[1,int])
cor(x[1,int], xs[1,int])
cor(x[1,int], xp[1,int])
cor(x[1,int], xc[1,int])

m = matrix(0, nr=length(rows), nc=4)

for (i in rows)
{
    inds = !is.na(x[i,])
    m[i,1] = cor(x[i,inds], xl[i,inds])
    m[i,2] = cor(x[i,inds], xs[i,inds])
    m[i,3] = cor(x[i,inds], xp[i,inds])
    m[i,4] = cor(x[i,inds], xc[i,inds])
}

cat('linear:',mean(m[,1]),'\n')
cat('spline:',mean(m[,2]),'\n')
cat('polynomial:',mean(m[,3]),'\n')
cat('pchip:',mean(m[,4]),'\n')

