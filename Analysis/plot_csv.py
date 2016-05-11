import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
import json

good_csv = "FormData/good.csv"
bad_csv = "FormData/leftlag.csv"

files = [good_csv, bad_csv]

vars = [' RAccelX', ' LAccelX', ' RGyroX', ' LGyroX',
        ' RAccelY', ' LAccelY', ' RGyroY', ' LGyroY',
        ' RAccelZ', ' LAccelZ', ' RGyroZ', ' LGyroZ' ]

# just plot y accel for both
plot_rows = 1
plot_cols = 2
axis_labels = ['ax', 'gx', 'ay', 'gy', 'az', 'gz']

for i in range(2):
  plt.suptitle(files[i])
  path = files[i]
  raw_values = pd.read_csv(path)
  raw_values = raw_values[vars].as_matrix()
  mean = np.matrix(raw_values.mean(axis=0))
  accel_values = raw_values - mean
  t, n = accel_values.shape
  times = range(t)
  plt.subplot(plot_rows, plot_cols, i+1)

  right = np.array(accel_values[:, 4])[:, 0]
  left = np.array(accel_values[:, 5])[:, 0]

  print files[i], np.correlate(left, right)

  plt.plot(times, right, times, left)
  plt.ylabel(files[i])

plt.show()
