# script to preprocess: interpolate and save datasets

import numpy as np
import pandas as pd
import matplotlib.pyplot as plot

#d_name = 'data/asos_1min_2020_fev_1day.csv' # fev/2020
#d_name = 'data/asos_1min_2020_fev_1week.csv' # fev/2020
d_name = 'data/asos/1min/asos_2020_jan_1day_15min.csv' # fev/2020

dsname = 'data/asos/1min/asos_2020_jan_1day_15min_spline.csv' # fev/2020

X = pd.read_csv(d_name, header=None)

print('loaded')

y = X.iloc[:,-1] # 8736
X = X.iloc[:,:-1] # all columns except last one

## filling NA values
#X.interpolate(method='linear', axis=1, inplace=True,limit_direction='both')
#X.interpolate(method='polynomial', order=3,axis=1,inplace=True,limit_direction='both')
X.interpolate(method='spline', order=3, axis=1, inplace=True,limit_direction='both')
X.fillna(0, inplace=True) # for filling the sides

# returning y column
X['y'] = y

# saving dataset imputed
X.to_csv(dsname,header=False, index=False)


