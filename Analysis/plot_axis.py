import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math

file = "bench/kwame_bench.csv"

vars = [' RAccelX',' RAccelY',' RAccelZ']
df1 = pd.read_csv(file)
acs = {}
font = {'family' : 'Helvetica',
        'size'   : 12}
plt.rc('font', **font)

plt.suptitle(file)

numplots = 1
curplot = 1

#plot magnitude
a = df1[vars].as_matrix()
ax = a[:, 0] - np.mean([a[:, 0]])
ay = a[:, 1] - np.mean([a[:, 1]])
az = a[:, 2] - np.mean([a[:, 2]])
filtered_ax = filter(lambda ax: not math.isnan(ax), ax)
filtered_ay = filter(lambda ay: not math.isnan(ay), ay)
filtered_az = filter(lambda az: not math.isnan(az), az)


plt.subplot(3,numplots,curplot)
plt.plot(filtered_ax)
plt.ylabel('filtered_ax')

plt.subplot(3,numplots,curplot+1)
plt.plot(filtered_ay)
plt.ylabel('filtered_ay')

plt.subplot(3,numplots,curplot+2)
plt.plot(filtered_az)
plt.ylabel('filtered_az')

plt.show()
