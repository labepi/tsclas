
# for testing the classification using the sktime library

import numpy as np
import pandas as pd

import time

# classifiers
#from sklearn.neighbors import KNeighborsClassifier
#from sklearn.svm import SVC
#from sklearn.tree import DecisionTreeClassifier
#from sklearn.naive_bayes import GaussianNB
#from sklearn.ensemble import RandomForestClassifier
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

# utils
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import VotingClassifier
from sklearn.model_selection import GridSearchCV, LeaveOneOut

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
#numtotal = 10
numtotal = 10
startseq = 11

# looping for each time series cut
#for i in range(25):
#for i in range(26):
for i in range(1):
#for i in range(16,26):
#for i in range(15,25): # not month
    #if i == 23:
    #    name = '1day'
    #elif i == 24:
    #    name = '1week'
    #elif i == 25:
    #    name = '1month'
    #else:
    #    name = str(i+1)+'hour'
    #    #name = str(i+1+10)+'hour'
    
    # RAW time series
    
    # jan 2020
    #d_name = 'data/asos/1min/asos_2020_jan_1day_15min.csv' 
    d_name = 'data/asos/1min/asos_2020_jan_1day_15min_spline.csv' 
    
    # fev/2020
    #d_name = 'data/datasets/1min_2020_fev_raw/asos_1min_2020_fev_'+name+'_spline.csv' 
    #d_name = '../../../phenomena/sources/wunder_2015jan_spline.csv' 

    # FEATS
    #d_name = 'data/datasets/1min_2020_fev_feats/D3/asos_1min_2020_fev_'+name+'_spline_feats.csv' # fev/2020
    #d_name = 'data/datasets/1min_2020_fev_feats/D4/asos_1min_2020_fev_2hour_spline_feats.csv' # fev/2020
    #d_name = 'data/datasets/1min_2020_fev_feats/D5/asos_1min_2020_fev_2hour_spline_feats.csv' # fev/2020
    #d_name = 'data/datasets/1min_2020_fev_feats/D6/asos_1min_2020_fev_2hour_spline_feats.csv' # fev/2020
    
    # loading data
    X = pd.read_csv(d_name, header=None)
    #print('loaded')
    
    y = X.iloc[:,-1] # 8736
    X = X.iloc[:,:-1] # all columns except last one

    print(X.shape)
    
    # looping for each simulation
    for rstate in range(startseq,startseq+numtotal):
        
        print(d_name, end=' ', flush=True)

        # spliting train/test
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=rstate)
        
        # converting to sktime format
        X_train2 = from_table_to_data(X_train)
        X_test2 = from_table_to_data(X_test)
        y_train2 = np.asarray(y_train)
        y_test2 = np.asarray(y_test)

        ### TODO: here is the classification step
        ###   - check the algorithms in scikit learn
        ###   - check the cross-validation options
        ###   - do the ensemble here
        
        #start = time.time()
        t = time.process_time()
        knn = KNeighborsTimeSeriesClassifier(metric="dtw")
        knn.fit(X_train2, y_train2) # ignore the FutureWarning from sklearn
        y_pred = knn.predict(X_test2)
        acc = accuracy_score(y_test, y_pred)
        #end = time.time()
        #lap = 1 #(end - start)
        lap = time.process_time() - t
        print('knn: '+str(acc)+' '+str(lap), end=' ', flush=True)

        t = time.process_time()
        tsf = TimeSeriesForestClassifier()
        tsf.fit(X_train2, y_train2)
        acc = tsf.score(X_test2, y_test2)
        lap = time.process_time() - t
        print('tsf: '+str(acc)+' '+str(lap), end=' ', flush=True)

        #t = time.process_time()
        #st = ShapeletTransformClassifier()
        #st.fit(X_train2, y_train2)
        #acc = st.score(X_test2, y_test2)
        #lap = time.process_time() - t
        #print('st: '+str(acc)+' '+str(lap), end=' ', flush=True)
        
        # TODO: check if remove boss for less i's
        #if i >= 15:
        if i >= 0:
            print('boss: 0 0', flush=True)
        else:
            t = time.process_time()
            boss = BOSSEnsemble()
            boss.fit(X_train2, y_train2)
            y_pred = boss.predict(X_test2)
            acc = accuracy_score(y_test, y_pred)
            lap = time.process_time() - t
            print('boss: '+str(acc)+' '+str(lap), flush=True)


