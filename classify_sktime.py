
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


if (len(sys.argv) != 4):
    quit('Error on arguments')

# getting arguments
d_path=sys.argv[1]
d_name=sys.argv[2]
seed=int(sys.argv[3])

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

# number of runs
#numtotal = 30
#numtotal = 1
#startseq = 1

# RAW time series

# jan 2020
d_path = 'data/asos/1min' 
#d_name = 'asos_2020_jan_1day_15min' 
d_name = 'asos_2020_jan_1day_15min_spline' 

# loading data
X = pd.read_csv(d_path+'/'+d_name+'.csv', header=None)

# removing the label column
y = X.iloc[:,-1] # last column
X = X.iloc[:,:-1] # all columns except last one

#print(X.shape)

# looping for each simulation
#for seed in range(startseq,startseq+numtotal):

print(d_name, end=' ', flush=True)

# spliting train/test
X_train, X_test, y_train, y_test = train_test_split(X, y, 
        test_size=0.2, random_state=seed)

# scaling data
scaler = StandardScaler()
scaler.fit(X_train)
scaler.transform(X_train)
scaler.transform(X_test)

# converting to sktime format
X_train2 = from_table_to_data(X_train)
X_test2 = from_table_to_data(X_test)
y_train2 = np.asarray(y_train)
y_test2 = np.asarray(y_test)

# classifiers

# knn
t = time.process_time()
knn = KNeighborsTimeSeriesClassifier(metric="dtw")
knn.fit(X_train2, y_train2) # ignore the FutureWarning from sklearn
y_pred = knn.predict(X_test2)
acc = accuracy_score(y_test, y_pred)
lap = time.process_time() - t
print('knn: '+str(acc)+' '+str(lap), end=' ', flush=True)

# randf
t = time.process_time()
randf = RandomForestClassifier(random_state=seed)
randf.fit(X_train, y_train)
y_pred = randf.predict(X_test)
acc = accuracy_score(y_test, y_pred)
lap = time.process_time() - t
print('randf: '+str(acc)+' '+str(lap), end=' ', flush=True)

# tsf
t = time.process_time()
tsf = TimeSeriesForestClassifier(random_state=seed)
tsf.fit(X_train2, y_train2)
y_pred = tsf.predict(X_test2)
acc = accuracy_score(y_test, y_pred)
lap = time.process_time() - t
print('tsf: '+str(acc)+' '+str(lap), end=' ', flush=True)

# rise
t = time.process_time()
rise = RandomIntervalSpectralForest(random_state=seed)
rise.fit(X_train2, y_train2)
y_pred = rise.predict(X_test2)
acc = accuracy_score(y_test, y_pred)
lap = time.process_time() - t
print('rise: '+str(acc)+' '+str(lap), end=' ', flush=True)

#t = time.process_time()
#st = ShapeletTransformClassifier()
#st.fit(X_train2, y_train2)
#acc = st.score(X_test2, y_test2)
#lap = time.process_time() - t
#print('st: '+str(acc)+' '+str(lap), end=' ', flush=True)

# TODO: check if remove boss for less i's
#if i >= 15:
##if i >= 0:
#    print('boss: 0 0', flush=True)
#else:
#    t = time.process_time()
#    boss = BOSSEnsemble()
#    boss.fit(X_train2, y_train2)
#    y_pred = boss.predict(X_test2)
#    acc = accuracy_score(y_test, y_pred)
#    lap = time.process_time() - t
#    print('boss: '+str(acc)+' '+str(lap), flush=True)

print(' ', flush=True)

