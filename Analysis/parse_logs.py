import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
import json

import datetime 
from dateutil.parser import parse

# Get values from csv, put into raw_values


testSubjectId = "Test"

exerciseEndTimesPath = "TrainingData/" + testSubjectId + "/ExerciseEndTimes.json"
workoutPath = "TrainingData/" + testSubjectId + "/Workout.csv"

vars = [' RAccelX', ' LAccelX', ' RGyroX', ' LGyroX',
        ' RAccelY', ' LAccelY', ' RGyroY', ' LGyroY',
        ' RAccelZ', ' LAccelZ', ' RGyroZ', ' LGyroZ' ]

exerciseEndTimes = json.load(open(exerciseEndTimesPath))
parsedEndTimes = dict() 

raw_data = pd.read_csv(workoutPath)

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

sum = 0
for exercise in exerciseRawValueMap.keys():
  sum += len(exerciseRawValueMap[exercise])
print sum

axis_labels = ['ax', 'gx', 'ay', 'gy', 'az', 'gz']

#Create CSVs for each exercise and produce plots 
for exercise in exerciseRawValueMap.keys():
  savePath = "TrainingData/" + testSubjectId +"/" + exercise + ".csv"
  exerciseRawValueMap[exercise].to_csv(savePath)




