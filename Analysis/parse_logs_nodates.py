import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
import json

import datetime 
from dateutil.parser import parse

# Get values from csv, put into raw_values


testSubjectId = "7"

exerciseEndTimesPath = "TrainingData/" + testSubjectId + "/ExerciseEndTimes.json"
workoutPath = "TrainingData/" + testSubjectId + "/Workout.csv"

vars = [' RAccelX', ' LAccelX', ' RGyroX', ' LGyroX',
        ' RAccelY', ' LAccelY', ' RGyroY', ' LGyroY',
        ' RAccelZ', ' LAccelZ', ' RGyroZ', ' LGyroZ' ]

exerciseEndTimes = json.load(open(exerciseEndTimesPath))
parsedEndTimes = dict()

raw_data = pd.read_csv(workoutPath)

i, lastRow = next(raw_data.iterrows())
i, startExerciseRow = next(raw_data.iterrows())
currentExerciseId = 0

#Iterate over each row in workout, partitioning into seperate exercises 
for i, row in raw_data.iterrows():
  tdelta = parse(row['LTime'])  - parse(lastRow['LTime'])

  if tdelta > datetime.timedelta(seconds=1):
    print i, startExerciseRow['LTime'], row['LTime']
    df = raw_data.loc[raw_data['LTime'] >= startExerciseRow['LTime']]
    rawValuesForCurExercise = df.loc[df['LTime'] < row['LTime']]
    parsedEndTimes[currentExerciseId] = len(rawValuesForCurExercise)
    currentExerciseId += 1
    startExerciseRow = row

  lastRow = row
# for i in range(len(raw_data)):
#   r

print parsedEndTimes

