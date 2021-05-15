
import subprocess

import sys

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# metrics from: https://scikit-learn.org/stable/modules/model_evaluation.html
from sklearn.metrics import *

if (len(sys.argv) < 2):
    quit('Error on arguments\nspan D')

span=sys.argv[1]
D=sys.argv[2]
#timeint=sys.argv[3]

# the command to get the results
cmd = 'cat ../../../results/asos/1hour/res_asos_2020_jan_'+span+'_D'+D+'.txt | grep PREDICTED'

# testing for 1-hour data
#cmd = 'cat ../../../results/asos/1hour/res_asos_2020_jan_3month_D3.txt | grep PREDICTED'

# running command and getting the output
output = subprocess.getoutput(cmd)

# splitting each round
res = output.split('\n')

# cumulated confusion matrix
cm = np.zeros(25).reshape(5,5)

# looping in the rounds
for i in range(len(res)):
    #i = 0
    
    resi = res[i]
    
    # removing initial text
    resi = resi.split('PREDICTED')[1]
    
    # removing extra spaces
    resi = resi.strip()
    
    y_test = []
    y_pred = []
    
    for z in resi.split(','):
        #print(z)
        zl = z.split('-')
        y_test.append(int(zl[0]))
        y_pred.append(int(zl[1]))
    
    # metrics
    acc = accuracy_score(y_test, y_pred)
    acc_bal = balanced_accuracy_score(y_test, y_pred)
    f1_micro = f1_score(y_test, y_pred, average='micro')
    f1_macro = f1_score(y_test, y_pred, average='macro')
    prec_micro = precision_score(y_test, y_pred, average='micro')
    prec_macro = precision_score(y_test, y_pred, average='macro')
    recall_micro = recall_score(y_test, y_pred, average='micro')
    recall_macro = recall_score(y_test, y_pred, average='macro')
    
    cm_i = confusion_matrix(y_test,y_pred)
    cm = cm + cm_i
    
    #print('\nacc:',acc)
    #print('acc_bal:',acc_bal)
    #print('f1_micro:',f1_micro)
    #print('f1_macro:',f1_macro)
    #print('prec_micro:',prec_micro)
    #print('prec_macro:',prec_macro)
    #print('recall_micro:',prec_micro)
    #print('recall_macro:',prec_macro)
    #print(cm_i)
    #print(classification_report(y_test, y_pred, digits=5))
    
    #exit()

    # TODO: sera que cabe fazer uma confusion matrix GERAl, de todos os
    # resultados? de todos os resamples?

#exit()

#cm = cm/cm.sum()
#cm = cm/cm.max()

# normalizando por coluna
for i in range(cm.shape[0]):
    cm[:,i] = cm[:,i]/cm[:,i].sum()

#labels = ['Temperature', 'Relative\nHumidity', 'Wind Direction', 'Wind Speed', 'Pressure']
labels = ['Temp.', 'Rel.\nHumidity', 'Wind\nDirection', 'Wind\nSpeed', 'Pressure']

plt.figure(figsize=(15,15))

sns.set(font_scale=3.5)

ax = sns.heatmap(cm, 
        linewidth=0.5, #1
        square=True, # make cells square
        #cbar=False,
        annot=True,
        fmt='.3f',
        cbar_kws={'fraction' : 0.04}, # shrink colour bar
        cmap='OrRd' # use orange/red colour map # Blues
        )

ax.set_xticklabels(labels, rotation=45, horizontalalignment='right') #, fontsize='x-large')
ax.set_yticklabels(labels, rotation=45, horizontalalignment='right') #, fontsize='x-large')

ax.set_xlabel('Actual')
ax.set_ylabel('Predicted')

plt.tight_layout()

#plt.show()




fname =  'img/fig_heat_'+span+'_D'+D+'.pdf'
plt.savefig(fname)



#cbar = ax.collections[0].colorbar
#cbar.set_ticks([0, .2, .75, 1])
#cbar.set_ticklabels(['low', '20%', '75%', '100%'])


#ax = sns.heatmap(cm, linewidth=0.5, cmap="Reds")
#plt.imshow(cm, cmap='hot', interpolation='nearest')

#plt.xticks(ticks, labels) #, rotation='vertical')
#plt.yticks(ticks, labels, rotation='horizontal')

#labels = [item.get_text() for item in ax.get_xticklabels()]
#labels[1] = 'Testing'


