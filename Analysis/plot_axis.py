import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math

file = "curl/katie_curl1.csv"

vars = [' RAccelX', ' LAccelX', ' RGyroX', ' LGyroX',
        ' RAccelY', ' LAccelY', ' RGyroY', ' LGyroY',
        ' RAccelZ', ' LAccelZ', ' RGyroZ', ' LGyroZ', ]
axis_labels = ['ax', 'gx', 'ay', 'gy', 'az', 'gz']
df1 = pd.read_csv(file)
plt.suptitle(file)

plot_rows = 3
plot_cols = 2

# Get values from csv, subtract mean
raw_values = df1[vars].as_matrix()
accel_values = raw_values - np.matrix(raw_values.mean(axis=0))
t, n = accel_values.shape
times = np.array(range(t))

# Plot accel values, 3 plots (x, y, z) each with corresponding L/R values
for i in range(0, n/2):
    plt.subplot(plot_rows, plot_cols, i+1)
    plt.plot(times, np.array(accel_values[:, 2*i]), times, np.array(accel_values[:, 2*i + 1]))
    plt.ylabel(axis_labels[i])

plt.show()