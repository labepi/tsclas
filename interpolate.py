# script to preprocess: interpolate and save datasets

import numpy as np
import pandas as pd

import sys
import time

#d_name = 'data/asos/1min/asos_2020_jan_1day_15min.csv' # jan/2020
#dsname = 'data/asos/1min/asos_2020_jan_1day_15min_spline.csv' # jan/2020


# the path and name of the file to interpolate
d_name = sys.argv[1]
#dsname = d_name.replace(".csv", "_spline.csv")

# getting the interpolation method as argument
method = sys.argv[2]
#method='linear'
#method='polynomial'
#method='spline'

# the file to save
dsname = d_name.replace(".csv", "_"+method+".csv")

#print(d_name)
#print(dsname)

#quit()

X = pd.read_csv(d_name, header=None)

#print('loaded')

names = X.iloc[:,0] # asos names (first column)
y = X.iloc[:,-1] # last column
X = X.loc[:, X.columns != 0]
X = X.iloc[:,:-1] # all columns except last

# starting time
startTotal = time.time()

## filling NA values
#X.interpolate(method='linear', axis=1, inplace=True,limit_direction='both')
#X.interpolate(method='polynomial', order=3,axis=1,inplace=True,limit_direction='both')
#X.interpolate(method='spline', order=3, axis=1, inplace=True,limit_direction='both')
X.interpolate(method=method, order=3, axis=1, inplace=True,limit_direction='both')
X.fillna(0, inplace=True) # for filling the sides

# end time
endTotal = time.time()

# total time taken
print("TOTAL TIME:", method,' ',endTotal - startTotal)

# returning names and y columns
X.insert(0, 'names', names)
X['y'] = y

# saving dataset imputed
X.to_csv(dsname,header=False, index=False)


