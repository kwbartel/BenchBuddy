import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math

file = "curl/katie_curl1.csv"

vars = [' RAccelX', ' LAccelX', ' RAccelY', ' LAccelY', ' RAccelZ' , ' LAccelZ']
axis_labels = ['ax', 'ay', 'az']
df1 = pd.read_csv(file)
plt.suptitle(file)

plot_rows = 3
plot_cols = 1

# Get values from csv, transpose so each row is different axis, subtract mean
raw_values = df1[vars].as_matrix().T
accel_values = raw_values - np.matrix(raw_values.mean(axis=1)).T
n, t = accel_values.shape
times = np.array(range(t))

# Plot accel values, 3 plots (x, y, z) each with corresponding L/R values
for i in range(0, n/2):
    plt.subplot(plot_rows, plot_cols, i+1)
    plt.plot(times, np.array(accel_values[2*i].T), times, np.array(accel_values[2*i + 1].T))
    plt.ylabel(axis_labels[i])

plt.show()
