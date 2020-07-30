# perform classification on airports with R tools

library(zoo)
#suppressMessages(library(RWeka))
#library(dplyr)
library(caret)

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
            
d_name='data/asos/1min/asos_2020_jan_1day_1min.csv'

Xall = read.csv(d_name, header=FALSE)

print('loaded')

# last column
y = Xall[,ncol(Xall)]

# all columns except last one
X = Xall[,-ncol(Xall)]


for (i in 1:nrow(X))
{
    X[i,] = na.fill(na.approx(X[i,], na.rm=FALSE), 'extend')
    #X[i,] = na.fill(na.spline(X[i,], na.rm=FALSE), 'extend')
}


set.seed(0)
id_train = createDataPartition(y=y, p=0.8, list=FALSE)

X_train = X[id_train,]
y_train = y[id_train]

X_test = X[-id_train,]
y_test = y[-id_train]

# scale data
trans = preProcess(X_train, method = c("center", "scale"))
X_train = predict(trans, X_train)
X_test = predict(trans, X_test)

# formating
X_train = as.data.frame(cbind(X_train, y_train))
X_train$y_train = as.factor(y_train)

# train
ctrl = trainControl(method="repeatedcv",repeats = 3) 
        #,classProbs=TRUE,summaryFunction = twoClassSummary)

clf = train(X_train, y_train, method = "knn", 
            trControl = ctrl, preProcess = c("center","scale"), tuneLength = 20)

#knnFit <- train(Direction ~ ., data = training, method = "knn", trControl = ctrl, preProcess = c("center","scale"), tuneLength = 20)

#clf = IBk(y_train ~ ., data=X_train, control=Weka_control(K=3))

# classify
res = predict(clf, X_test)

print(res)

myacc = sum(res == y_test)/length(y_test)

print(myacc)

