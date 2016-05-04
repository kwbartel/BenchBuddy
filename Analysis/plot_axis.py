import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
import json

import datetime 
from dateutil.parser import parse

# Get values from csv, put into raw_values
file = "curl/katie_curl1.csv"
exerciseEndTimesPath = "TrainingData/2/ExerciseEndTimes.json"
workoutPath = "TrainingData/2/Workout.csv"

vars = [' RAccelX', ' LAccelX', ' RGyroX', ' LGyroX',
        ' RAccelY', ' LAccelY', ' RGyroY', ' LGyroY',
        ' RAccelZ', ' LAccelZ', ' RGyroZ', ' LGyroZ' ]

exerciseEndTimes = json.load(open(exerciseEndTimesPath))
parsedEndTimes = dict()

# raw_data = pd.read_csv(workoutPath)


# i, lastRow = next(raw_data.iterrows())
# i, startExerciseRow = next(raw_data.iterrows())

# currentExerciseId = 0
# #Iterate over each row in workout, partitioning into seperate exercises 
# for i, row in raw_data.iterrows():
#   tdelta = parse(row['LTime'])  - parse(lastRow['LTime'])
#   if tdelta > datetime.timedelta(seconds=1):
#     df = raw_data.loc[raw_data['LTime'] >= startExerciseRow['LTime']]
#     rawValuesForCurExercise = df.loc[df['LTime'] < row['LTime']]
#     parsedEndTimes[currentExerciseId] = len(rawValuesForCurExercise)
#     currentExerciseId += 1

#   lastRow = row
#   startExerciseRow = row
# # for i in range(len(raw_data)):
# #   r

# print parsedEndTimes

for exercise in exerciseEndTimes.keys():
  parsedEndTimes[exercise] = str(parse(exerciseEndTimes[exercise]) + datetime.timedelta(hours=4))

# Ex.  [('SquatLow', DateTime), ('SquatMedium', DateTime), ...]
sortedExerciseEndTimes = sorted(parsedEndTimes.items(), key=lambda x:x[1])

df1 = pd.read_csv(workoutPath)
print len(df1)
exerciseRawValueMap = dict()

#For each exercise, create dataframe with elements before the corresponding end time
#curExercise = sortedExerciseEndTimes.keys()[0]

startTime = df1['LTime'][0]

print sortedExerciseEndTimes
for exerciseTimePair in sortedExerciseEndTimes:
  exercise = exerciseTimePair[0]
  endTime = exerciseTimePair[1]
  df =  df1.loc[df1['LTime'] >= startTime]
  queriedRawValues = df.loc[df['LTime'] <= endTime]
  print  startTime, endTime, len(queriedRawValues)
  exerciseRawValueMap[exercise] = queriedRawValues

  #startTime = str(parse(endTime) + datetime.timedelta(seconds=1))
  startTime = endTime

raw_values = df1[vars].as_matrix()

sum = 0 
for exercise in exerciseRawValueMap.keys():
  sum += len(exerciseRawValueMap[exercise])

#print exerciseRawValueMap['TricepExtensionsLow']

# # Set up plotting variables
# daxis_labels = ['ax', 'gx', 'ay', 'gy', 'az', 'gz']
# plt.suptitle(file)
# plot_rows = 3
# plot_cols = 2

# #Prepare csv data for plotting (subtract mean)
# accel_values = raw_values - np.matrix(raw_values.mean(axis=0))

# t, n = accel_values.shape
# times = np.array(range(t))

# #Plot accel values, 6 plots: 3 axes, A/G
# for i in range(0, n/2):
#     plt.subplot(plot_rows, plot_cols, i+1)
#     plt.plot(times, np.array(accel_values[:, 2*i]), times, np.array(accel_values[:, 2*i + 1]))
#     plt.ylabel(axis_labels[i])

# plt.show()
