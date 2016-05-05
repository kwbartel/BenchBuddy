import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import confusion_matrix
import sklearn.tree as tree

files = ["bench/kwame_bench.csv", "bench/katie_bench1.csv", "curl/kwame_curl.csv", "curl/katie_curl1.csv", "row/kwame_row.csv", "row/katie_row1.csv", "flye/kwame_flye.csv", "flye/katie_flye1.csv"]
classes = [0,0,1,1,2,2,3,3]
metrics = []

test_files = ["bench/katie_bench2.csv", "curl/katie_curl2.csv", "row/katie_row2.csv", "flye/katie_flye2.csv"]
test_classes = [0, 1, 2, 3]

def make_features(csv_files, save_graphs=False):
    idx = 0
    for file in files:
        met = []
        print file

        vars = [' RAccelX',' RAccelY',' RAccelZ']
        df1 = pd.read_csv(file)
        a = df1[vars]
        mag = np.linalg.norm(a, axis=1)

        #remove mean from mag
        mean = np.mean(mag)
        mag = mag - mean

        #plot power spectrum of magnitude
        numplots = 1#len(vars)+1
        curplot = 1

        plt.subplot(3,numplots,curplot+2)
        (power,freq) = plt.psd(mag, 512, 20,detrend=plt.mlab.detrend_none)


        #label power spectrum graph
        meanpower = np.mean(power)

        # record a bunch of metrics of magnitude
        met.append(mean)  #mean of accel
        met.append(plt.mlab.entropy(power, 20)) #entropy of power, binned into 20 bins
        met.append(meanpower)  #average of power
        met.append(np.std(power)) #std dev of power
        met.append(np.max(power))  #maximum power
        met.append(freq[np.argmax(power)])  #maximum frequency
        metrics.append(met)

        # Save graphs of features
        if save_graphs:
            font = {'family' : 'Helvetica',
                'size'   : 8}

            plt.rc('font', **font)

            yoff = 0

            #plot magnitude
            plt.subplot(3,numplots,curplot)
            plt.plot(mag)
            plt.ylabel('mag')

            #plot spectrogram of magnitude
            plt.subplot(3,numplots,curplot+1)
            plt.specgram(mag, 512, 20)
            plt.ylabel('')


            s = "mag mu = " + ("%.2f" % mean) + "\n"
            s = s + "psd e: " + ("%.2f" % plt.mlab.entropy(power, 20)) + "; mu = " + ("%.2f" % meanpower) + "\n"
            s = s + "psd std: " + ("%.2f" % np.std(power))
            axes = plt.gca()
            yl = axes.get_ylim()
            plt.text(2, yl[1] + (yl[0]-yl[1]) * .25, s, fontsize=8)

            plt.ylabel('')
            plt.suptitle(file)
            fig = plt.gcf()
            fig.set_size_inches(8,8)
            fig.savefig(repr(idx) + ".png", dpi=300)
            idx = idx + 1
            plt.close()
            plt.show(block=True)

    return metrics

train_features = make_features(files)

print ['mag_mean','mag_power_entropy','mag_power_mean', 'mag_power_std', 'mag_power_max', 'mag_power_max_freq']
for m in metrics:
    for v in m:
        print ("%.2f, " % v),
    print
print classes

#train decision tree classifier on data
clf = DecisionTreeClassifier(random_state=0,max_depth=3)

clf.fit(train_features, classes)
print clf

test_features = make_features(test_files)

print clf.predict(test_features)
print classes
cm = confusion_matrix(test_classes,clf.predict(metrics))
print cm

with open('graph.dot', 'w') as file:
    tree.export_graphviz(clf, out_file = file)


