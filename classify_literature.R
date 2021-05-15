# perform classification on airports with R tools

suppressMessages(library(zoo))
suppressMessages(library(caret))

#suppressMessages(library(RWeka))
#library(dplyr)

source('utils.R')

#ds_names = c(
#            'data/asos/1min/asos_2020_jan_1day_1min.csv'
#        'data/asos_1min_2020_fev_1day_spline.csv'
#        'data/asos_1min_2020_fev_1day_feats.csv'
#        'data/asos_1min_2020_fev_1day20hour_spline_feats.csv'
#        'data/asos_1min_2020_fev_20hour_spline.csv'
#        'data/asosau.csv'
#        'data/asosbr.csv',
#        'data/asosfi.csv',
#        'data/asosfr.csv',
#        'data/asosus.csv',
#        'data/asosca.csv'
#        )

#Xall = data.frame()

#for (d_name in ds_names)
#{
#    #print(d_name)
#    Xtmp = read.csv(d_name, header=FALSE)
#    Xall = rbind(Xall, Xtmp)
#}
            
#d_name='data/asos/1min/asos_2020_jan_1day_15min_spline.csv'
#d_name='data/asos/1min/asos_2020_jan_1day_10min.csv'
d_name='data/asos/1min/asos_2020_jan_1day_10min_spline.csv'
#d_name='data/asos/1min/gap/asos_2020_jan_1day_10min_gap10.csv'
#d_name='data/asos/1min/gap/asos_2020_jan_1day_10min_gap10_spline.csv'

Xall = read.csv(d_name, header=FALSE)

print('loaded')

####################

set.seed(1)

# try reducing the size of the samples

# original size of the dataset
N = nrow(Xall)

# reduce to 80%
#pct = 0.2
#pct = 0.8

#inds = sample(1:N, floor(N * pct))
#Xall = Xall[inds,]

# TODO: try to reduce the size according to the geographical location?


####################

# separating data from class

# first column
names = Xall[,1]

# last column
y = Xall[,ncol(Xall)]

# all columns except first and last one
#X = Xall[,-ncol(Xall)]
X = Xall[,-c(1,ncol(Xall))]

# converting to numeric
X = apply(X, 2, as.numeric)
#NOTE: this is necessary after the name addition

# converting some data

# temperature from fahrenheit to celsius
#FtoC = function(t)
#{
#    return( (t - 32) * 5/9)
#}
#
#inds_t = sample(which(y == 1), floor(nrow(X)/(5*2)))
#X[inds_t,] = dim(FtoC(X[inds_t,]))

######################
# interpolation of data

# TODO: check this
#for (i in 1:nrow(X))
#{
#    X[i,] = na.fill(na.approx(X[i,], na.rm=FALSE), 'extend')
#    #X[i,] = na.fill(na.spline(X[i,], na.rm=FALSE), 'extend')
#}
#
#print(dim(X))

id_train = createDataPartition(y=y, p=0.8, list=FALSE)

X_train = X[id_train,]
y_train = as.factor(y[id_train])
names_train = names[id_train]

X_test = X[-id_train,]
y_test = as.factor(y[-id_train])
names_test = names[-id_train]


# TODO: maybe this is the bias

# TODO: maybe using the conventional normalization is not ideal,
# because for time series, each point is not a feature, so its
# normalization must occur in rows, not columns

# scale data
#trans = preProcess(X_train, method = c("center", "scale"))
#X_train = predict(trans, X_train)
#X_test = predict(trans, X_test)

X_train = t(apply(X_train, 1, znorm))
X_test = t(apply(X_test, 1, znorm))

#print(dim(X_train))
#quit()

# formating
#X_train = as.data.frame(cbind(X_train, y_train))
#X_train$y_train = as.factor(y_train)

# train
ctrl = trainControl(method="repeatedcv",repeats = 3) 
        #,classProbs=TRUE,summaryFunction = twoClassSummary)

clf = train(X_train, y_train, method = "knn", trControl = ctrl) 

#clf = train(X_train, y_train, method = "knn", trControl = ctrl, 
#            preProcess = c("center","scale"), tuneLength = 20)

#knnFit <- train(Direction ~ ., data = training, method = "knn", trControl = ctrl, preProcess = c("center","scale"), tuneLength = 20)

#clf = IBk(y_train ~ ., data=X_train, control=Weka_control(K=3))

# classify
res = predict(clf, X_test)

print(res)

myacc = sum(res == y_test)/length(y_test)

print(myacc)




##########################################
#
# analysis of the time series that was misclassified
#

inds_ok = which(res == y_test)
inds_no = which(res != y_test)

names_test[inds_ok]

y_test[inds_ok]


par(mfrow=c(2,3), family='Sans')
for(i in 1:5)
{
    inds_i = y_test[inds_ok] == i
    matplot(t(X_test[inds_ok,][inds_i,]), pch=i, col=i, type='b')
}

