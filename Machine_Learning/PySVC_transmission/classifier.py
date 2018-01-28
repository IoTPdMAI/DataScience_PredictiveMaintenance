# Transmission SVC
import sys
from datetime import datetime, timedelta
import numpy as np
import math

# import additional scripts containing functions
sys.path.append('../Global_SVC_Scripts')
import ODBC
import Variables
import ASV_DSV
import Store_Load as SL

SL.make_data_dir() # create __cached_data__ directory, interrupt if error
    

##################################### Global Variables
SERVERNAME = 'localhost'
DATABASE_NAME = 'ConcertoDb_TIF_WA6358_59_b9500bbf-f52a-474a-92c5-b863ed31d004'  #TIF Database
VEHICLE_NUMBER = '2' 
DEFINITIONNUMBER_EVENT = '41' # consult SQL-query "get_DefinitionNumber_and_respective_DinGroup" to find the correct DefinitionNumber
DEFINITIONNUMBER_ASV = '6'
NUMBER_ASV_POSITIONS = 7 # only the first NUMBER_ASV_POSITIONS positions of ASV string are relevant
START_EVENTS_FORMATTED = datetime.strptime( '2017-01-17', "%Y-%m-%d") # point of time of very first event AND event ASV
TIMEFRAME_EVENT_ASV = 3*24 # hours
TIME_AFTER_LAST_EVENT = 10*24 # hours (no_event values start at that point of time)
TIMEFRAME_NO_EVENT_ASV = 6*24 # hours 

FRACTION_TRAIN = 0.7 # fraction of examples that will be train data (1-fraction is test data)

SQL_PART_ROUTINE =  Variables.get_sql_join(DATABASE_NAME, VEHICLE_NUMBER) # SQL query that executes relevant joins, not containing SELECT statement
#####################################







print('-----------------------\nSVM on Concerto Data\napproach: TRANSMISSION\n-----------------------')

# TODO ask whether to connect to DB and load values or to use stored ones
'''
SL.store_list(event_times,'event_times')
a, b, c = SL.load_list('event_times', readtype='time')
'''

##################################### connect to ms sql server
cursor = ODBC.connect_to_DB(SERVERNAME, DATABASE_NAME)
#####################################

##################################### grab and format event time stamps
event_times, event_time_first, event_time_last = ASV_DSV.get_event_time_stamps(cursor, SQL_PART_ROUTINE, DEFINITIONNUMBER_EVENT, start_events=START_EVENTS_FORMATTED)
##################################### 

##################################### grab event AnalogSignalValues
print('start collecting event ASV')
prior_event_time = 0
event_ASV = [] # array containing event ASV tupels
display_count = 0 # counter for command line output

for event_time in event_times:
    # calculate relevant time period before event
    relevant_period_start = event_time - timedelta(hours=TIMEFRAME_EVENT_ASV)
    if prior_event_time != 0 and prior_event_time >= relevant_period_start: # less than TIMEFRAME_EVENT_ASV hours between two events
        relevant_period_start = prior_event_time

    if relevant_period_start < START_EVENTS_FORMATTED: # values before START_EVENTS_FORMATTED are corrupted
        relevant_period_start = START_EVENTS_FORMATTED
    
    # select values in relevant event time period -> LABEL = 1
    event_ASV_unformatted = cursor.execute("""SELECT EnvironmentDataSet.AnalogSignalValues """+SQL_PART_ROUTINE+
                                           """ AND DiagnosticDataSetDefinition.DefinitionNumber = """+DEFINITIONNUMBER_ASV+
                                           """ AND StartDateTime >= ? 
                                           AND StartDateTime < ?""", (relevant_period_start, event_time)
                                           ).fetchall()
    for row in event_ASV_unformatted:
        event_ASV.append( [ *( float(i) for i in row[0].split(';')[:NUMBER_ASV_POSITIONS] ) ] )
    
    # preparing for next loop iteration
    prior_event_time = event_time
    display_count += len(event_ASV_unformatted)
    sys.stdout.write("\r#event ASV tupels collected: %i" % display_count)
    sys.stdout.flush()
#####################################


##################################### grab no_event AnalogSignalValues
print('\nstart collecting no_event ASV')
no_event_ASV = []
no_event_period_start = event_time_last + timedelta(hours=TIME_AFTER_LAST_EVENT) 
no_event_period_end = no_event_period_start + timedelta(hours=TIMEFRAME_NO_EVENT_ASV)
# select values in relevant no_event time period -> LABEL = 0
no_event_ASV_unformatted = cursor.execute("""SELECT EnvironmentDataSet.AnalogSignalValues """+SQL_PART_ROUTINE+
                                       """ AND DiagnosticDataSetDefinition.DefinitionNumber = """+DEFINITIONNUMBER_ASV+
                                       """ AND StartDateTime >= ? 
                                       AND StartDateTime < ?""", (no_event_period_start, no_event_period_end)
                                       ).fetchall()
for row in no_event_ASV_unformatted:
        no_event_ASV.append( [ *( float(i) for i in row[0].split(';')[:NUMBER_ASV_POSITIONS] ) ] )
print('#no_event ASV tupels collected:', len(no_event_ASV))
print( 'ranging from %s to %s' % (no_event_period_start.strftime('%Y/%m/%d %H:%M'), no_event_period_end.strftime('%Y/%m/%d %H:%M')) )
print('--%--')
#####################################




##################################### prepare training and test data
from sklearn.model_selection import train_test_split

print('start preparing training and test data')
n_event_ASV = len(event_ASV)
n_no_event_ASV = len(no_event_ASV)
data_tuples = np.array(event_ASV)
data_tuples = np.append(data_tuples, no_event_ASV ,axis=0)

labels = np.ones(n_event_ASV)
labels = np.append(labels, np.zeros(n_no_event_ASV), axis=0)

data_train, data_test, labels_train, labels_test = train_test_split(data_tuples,labels,test_size=(1-FRACTION_TRAIN)) # randomize training and test data sets

print('data preparation finished:')
print('training data: %i (event ASV: %i | no_event ASV: %i)' % (len(data_train), sum(labels_train), len(labels_train)-sum(labels_train) ) )
print('test data: %i (event ASV: %i | no_event ASV: %i)' % (len(data_test), sum(labels_test), len(labels_test)-sum(labels_test) ) )
print('--%--')
#####################################



##################################### implement SVM
from sklearn.svm import LinearSVC
from sklearn.svm import SVC
from sklearn import metrics
import matplotlib.pyplot as plt
# linear
print('start LinearSVC training')
lin_classifier = LinearSVC(dual=False, C=1)
lin_classifier.fit(data_train, labels_train)
prediction_lin_classifier = lin_classifier.predict(data_test)
print('--LinearSVC training finished')

# rbf
print('start rbf SVC training (duration approx 10 min)')
rbf_classifier = SVC(cache_size=1000) # increase memory available for this classifier (default: 200MB)
rbf_classifier.fit(data_train, labels_train)
prediction_rbf_classifier = rbf_classifier.predict(data_test)
print('--rbf SVC training finished')
n_sv = rbf_classifier.n_support_
print('Nbr. of support vectors of respective classes (available only for nonlinear SVC):\nevent values: %i vectors; no_event values: %i vectors' %(n_sv[1], n_sv[0]))
print('--%--\n')
##################################### 



##################################### evaluation of results
print('evaluation metrics:\n')
## linear ##
score_lin_classifier = lin_classifier.score(data_test, labels_test) # precision
print('LINEAR CLASSIFIER\nscore on test data:',score_lin_classifier)

cfm1 = metrics.confusion_matrix(labels_test, prediction_lin_classifier)
#True negative
tn = cfm1[0][0]
#False positive
fp = cfm1[0][1]
#False negative
fn = cfm1[1][0] 
#True positive
tp = cfm1[1][1]
print('confusion matrix:', cfm1, sep='\n')

tpr = tp/(tp+fn)
print('true positive rate:', tpr)
fpr = fp/(fp+tn)
print('false positive rate:', fpr)
classification_error = (fp + fn)/(tp+fp+tn+fn)
print('classification error: ', classification_error)

# Error on Training data
prediction_lin_classifier_train = lin_classifier.predict(data_train)
classification_error_train_lin = 1.0 - metrics.accuracy_score(labels_train, prediction_lin_classifier_train, normalize=True)
print('(classification error on training data: %0.12f)' % classification_error_train_lin)

# ROC curve lin_classifier
print('ROC curve will be shown in a separate window - in order to proceed with the evaluation report, please CLOSE the ROC curve window!\n')
y_score = lin_classifier.decision_function(data_train)
fpr, tpr, threshold = metrics.roc_curve(labels_train, y_score)
roc_auc = metrics.auc(fpr, tpr)
plt.title('Receiver Operating Characteristic Linear Classifier')
plt.plot(fpr, tpr, 'b', label = 'AUC = %0.2f' % roc_auc)
plt.legend(loc = 'lower right')
plt.plot([0, 1], [0, 1],'r--')
plt.xlim([0, 1])
plt.ylim([0, 1])
plt.ylabel('True Positive Rate')
plt.xlabel('False Positive Rate')
plt.show()


## rbf ##
score_rbf_classifier = rbf_classifier.score(data_test, labels_test)
print('RBF CLASSIFIER\nscore on test data:',score_rbf_classifier)

cfm2 = metrics.confusion_matrix(labels_test, prediction_rbf_classifier)
tn = cfm2[0][0]
fp = cfm2[0][1]
fn = cfm2[1][0] 
tp = cfm2[1][1]
print('confusion matrix:', cfm2, sep='\n')

tpr = tp/(tp+fn)
print('true positive rate:', tpr)
fpr = fp/(fp+tn)
print('false positive rate:', fpr)
classification_error = (fp + fn)/(tp+fp+tn+fn)
print('classification error: ', classification_error)

# Error on Training data
prediction_rbf_classifier_train = rbf_classifier.predict(data_train)
classification_error_train_rbf = 1.0 - metrics.accuracy_score(labels_train, prediction_rbf_classifier_train, normalize=True)
print('(classification error on training data: %0.12f)' % classification_error_train_rbf)

# ROC curve rbf_classifier
print('ROC curve will be shown in a separate window - in order to proceed with the evaluation report, please CLOSE the ROC curve window!\n')
y_score = rbf_classifier.decision_function(data_train)
fpr, tpr, threshold = metrics.roc_curve(labels_train, y_score)
roc_auc = metrics.auc(fpr, tpr)
plt.title('Receiver Operating Characteristic RBF Classifier')
plt.plot(fpr, tpr, 'b', label = 'AUC = %0.2f' % roc_auc)
plt.legend(loc = 'lower right')
plt.plot([0, 1], [0, 1],'r--')
plt.xlim([0, 1])
plt.ylim([0, 1])
plt.ylabel('True Positive Rate')
plt.xlabel('False Positive Rate')
plt.show()
#####################################