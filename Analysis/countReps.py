import numpy as np
from scipy.signal import butter, lfilter, freqz
import matplotlib.pyplot as plt
import pandas as pd


subjectId = '1'
filePath = 'TrainingData/' + subjectId + '/BenchMedium.csv'

def butter_lowpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    return b, a

def butter_lowpass_filter(data, cutoff, fs, order=5):
    b, a = butter_lowpass(cutoff, fs, order=order)
    y = lfilter(b, a, data)
    return y

df1 = pd.read_csv(filePath)[' RAccelX']
data = df1.values


# Filter requirements.
order = 6
fs = 10     # sample rate, Hz
cutoff = 1   # desired cutoff frequency of the filter, Hz

y = butter_lowpass_filter(data, cutoff, fs, order)

plt.plot(y)
plt.show()