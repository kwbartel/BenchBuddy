import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
import json


testSubjectId = "3"

exerciseEndTimesPath = "TrainingData/" + testSubjectId + "/ExerciseEndTimes.json"
exerciseEndTimes = json.load(open(exerciseEndTimesPath))

exercisePathPrefix = "TrainingData/"

vars = [' RAccelX', ' LAccelX', ' RGyroX', ' LGyroX',
        ' RAccelY', ' LAccelY', ' RGyroY', ' LGyroY',
        ' RAccelZ', ' LAccelZ', ' RGyroZ', ' LGyroZ' ]

axis_labels = ['ax', 'gx', 'ay', 'gy', 'az', 'gz']

for exercise in exerciseEndTimes.keys():
  # Set up plotting variables
  print exercise
  raw_values = pd.read_csv(exercisePathPrefix + testSubjectId + "/" + exercise + ".csv")
  raw_values = raw_values[vars].as_matrix()

  plt.suptitle(exercise)
  plot_rows = 3
  plot_cols = 2

  #Prepare csv data for plotting (subtract mean)
  accel_values = raw_values - np.matrix(raw_values.mean(axis=0))

  t, n = accel_values.shape
  times = np.array(range(t))

  #Plot accel values, 6 plots: 3 axes, A/G
  for i in range(0, n/2):
      plt.subplot(plot_rows, plot_cols, i+1)
      plt.plot(times, np.array(accel_values[:, 2*i]), times, np.array(accel_values[:, 2*i + 1]))
      plt.ylabel(axis_labels[i])

  plt.show()