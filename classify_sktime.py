
# for testing the classification using the sktime library

import numpy as np
import pandas as pd

import sys
import time

# classifiers
#from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
#from sklearn.tree import DecisionTreeClassifier
#from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import RandomForestClassifier
#from sklearn.linear_model import SGDClassifier
#from sklearn.gaussian_process import GaussianProcessClassifier
#from sklearn.neural_network import MLPClassifier
#from sklearn.ensemble import AdaBoostClassifier
#from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis
#from sklearn.ensemble import GradientBoostingClassifier
#from sklearn.linear_model import LogisticRegression

# sktime classifiers
from sktime.classification.distance_based import KNeighborsTimeSeriesClassifier
from sktime.classification.compose import TimeSeriesForestClassifier
from sktime.classification.shapelet_based import ShapeletTransformClassifier
from sktime.classification.dictionary_based import BOSSEnsemble
from sktime.classification.frequency_based import RandomIntervalSpectralForest

# utils
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import VotingClassifier
from sklearn.model_selection import GridSearchCV, LeaveOneOut

#import impyute as impy

# - knn
# https://sktime.org/modules/auto_generated/sktime.classification.distance_based.KNeighborsTimeSeriesClassifier.html
# - randf
# https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html
# - tsf
# https://sktime.org/modules/auto_generated/sktime.classification.interval_based.TimeSeriesForest.html
# - rise
# https://sktime.org/modules/auto_generated/sktime.classification.frequency_based.RandomIntervalSpectralForest.html
# - boss
# https://sktime.org/modules/auto_generated/sktime.classification.dictionary_based.BOSSEnsemble.html
# - st
# https://sktime.org/modules/auto_generated/sktime.classification.shapelet_based.ShapeletTransformClassifier.html

# used only for the sktime algorithms
def from_table_to_data(x):
    instance_list = []
    instance_list.append([])
    
    x_data = pd.DataFrame(dtype=np.float32)
    
    for i in range(len(x.index)):
        instance_list[0].append(pd.Series(x.iloc[i]))
    
    # only dim_0 for univariate time series
    for dim in range(len(instance_list)):
        x_data['dim_' + str(dim)] = instance_list[dim]
    
    return x_data

if (len(sys.argv) != 6):
    quit('Error on arguments')

# RAW time series

# jan 2020
d_path = 'data/asos/1min' 
d_name = 'asos_2020_jan_1day_1min' 
seed=1
impute_method='linear'
algorithm='randf'

# getting arguments
d_path=sys.argv[1]
d_name=sys.argv[2]
seed=int(sys.argv[3])
impute_method=sys.argv[4]
algorithm=sys.argv[5]

# percent to split train/test
train_pct=0.8

# loading data
X = pd.read_csv(d_path+'/'+d_name+'.csv', header=None)

# removing the label column
names = X.iloc[:,0] # asos names (first column)
y = X.iloc[:,-1] # last column
X = X.loc[:, X.columns != 0] # removing names
X = X.iloc[:,:-1] # all columns except last

##########################
## SPLITING TRAIN/TEST
##########################
X_train, X_test, y_train, y_test = train_test_split(X, y,
        train_size=train_pct, random_state=seed)
X_train = pd.DataFrame(X_train)
X_test = pd.DataFrame(X_test)


##########################
## PRE-PROCESSING
##########################

# performing imputation (filling NA values)
# train
t = time.process_time()
X_train.interpolate(method=impute_method, axis=1, inplace=True, limit_direction='both')
t_impute_train = time.process_time() - t
# test
t = time.process_time()
X_test.interpolate(method=impute_method, axis=1, inplace=True, limit_direction='both')
t_impute_test = time.process_time() - t

# standardization of time series data
# NOTE: since time series points can not be considered features, the
# standardization must occur by rows, not columns
# train
t = time.process_time()
scaler = StandardScaler()
X_train = pd.DataFrame(scaler.fit_transform(X_train.values.transpose()).transpose(), 
        index=X_train.index, columns=X_train.columns)
t_scale_train = time.process_time() - t
# test
t = time.process_time()
scaler = StandardScaler()
X_test = pd.DataFrame(scaler.fit_transform(X_test.values.transpose()).transpose(), 
        index=X_test.index, columns=X_test.columns)
t_scale_test = time.process_time() - t

# converting to sktime format
X_train2 = from_table_to_data(X_train)
X_test2 = from_table_to_data(X_test)
y_train2 = np.asarray(y_train)
y_test2 = np.asarray(y_test)


##########################
## TRAINING
##########################

t = time.process_time()

# classifiers
if algorithm == 'knn':
    clf = KNeighborsTimeSeriesClassifier(n_neighbors=1, metric="dtw")
elif algorithm == 'randf':
    clf = RandomForestClassifier(n_estimators=200, 
                                 criterion='entropy',
                                 min_samples_split=2,
                                 random_state=seed)
elif algorithm == 'tsf':
    clf = TimeSeriesForestClassifier(n_estimators=200, 
                                     criterion='entropy', 
                                     min_samples_split=2,
                                     random_state=seed)
elif algorithm == 'rise':
    clf = RandomIntervalSpectralForest(n_estimators=200,
                                       #min_interval=16, 
                                       #acf_lag=100, 
                                       #acf_min_values=4,
                                       random_state=seed)
elif algorithm == 'boss':
    clf = BOSSEnsemble()
elif algorithm == 'st':
    clf = ShapeletTransformClassifier()

# randf is the unique from sklearn
if algorithm == 'randf':
    clf.fit(X_train, y_train)
else:
    clf.fit(X_train2, y_train2)

t_train = time.process_time() - t

##########################
## TESTING
##########################

t = time.process_time()

if algorithm == 'randf':
    y_pred = clf.predict(X_test)
else:
    y_pred = clf.predict(X_test2)

t_test = time.process_time() - t

# computing accuracy
acc = accuracy_score(y_test, y_pred)

# printing string y_test-y_pred
print(d_name+' '+algorithm+' PREDICTED ' + \
      ','.join(str(a)+'-'+str(b) for a,b in zip(y_test,y_pred)), 
      flush=True)

print(d_name+' '+algorithm+' TIME_TRAIN' + \
     ' impute: '+str(t_impute_train) + \
     ' scale: '+str(t_scale_train) + \
     ' train: '+str(t_train), flush=True)

print(d_name+' '+algorithm+' TIME_TEST' + \
     ' impute: '+str(t_impute_test) + \
     ' scale: '+str(t_scale_test) + \
     ' test: '+str(t_test), flush=True)

print(d_name+' '+algorithm, end=' ', flush=True)
print('FINAL_ACC '+str(acc), flush=True)


