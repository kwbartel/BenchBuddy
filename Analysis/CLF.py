import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import confusion_matrix
import sklearn.tree as tree
from os import listdir
from os.path import isfile, join
from random import shuffle

# Names of exercises, list of what subject numbers to take data from
class_names = ["Squat", "Bench", "Row", "Curl", "Tricep"]
subjects = range(5)

# Collect all files and corresponding labels from desired subjects folders
files = []
labels = []
for subject_id in subjects:
    # Get list of all files in subject's folder
    path = join('./TrainingData/', str(subject_id))
    subject_files = [f for f in listdir(path) if isfile(join(path, f))]
    for f in subject_files:
        for c in class_names:
            if f.find(c) > -1:
                files.append(join(path, f))
                labels.append(class_names.index(c))

# Shuffle file lists in random order
files_shuf = []
labels_shuf = []
index_shuf = range(len(files))
shuffle(index_shuf)
for i in index_shuf:
    files_shuf.append(files[i])
    labels_shuf.append(labels[i])

# Split data into train and test
print len(files), "data files"
split = .7 # Fraction of data set to use as training
split_idx = int(len(files) * split)
print split_idx, "used for training"
train_files = files_shuf[:split_idx]
train_classes = labels_shuf[:split_idx]
test_files = files_shuf[split_idx:]
test_classes = labels_shuf[split_idx:]

def make_features(csv_files, save_graphs=False):
    idx = 0
    metrics = []
    for file in csv_files:
        met = []

        # Load variables
        vars = [' RAccelX', ' LAccelX', ' RGyroX', ' LGyroX',
        ' RAccelY', ' LAccelY', ' RGyroY', ' LGyroY',
        ' RAccelZ', ' LAccelZ', ' RGyroZ', ' LGyroZ' ]
        raw_values = pd.read_csv(file)
        raw_values = raw_values[vars]

        raw_values = np.matrix(raw_values).T

        for i in range(raw_values.shape[0]):
            # Remove mean from raw row
            row = raw_values[i]
            mean = np.mean(row)
            mag = row - mean

            #plot power spectrum of magnitude
            numplots = 1#len(vars)+1
            curplot = 1

            plt.subplot(3,numplots,curplot+2)
            (power,freq) = plt.psd(mag, 512, 20,detrend=plt.mlab.detrend_none)


            #label power spectrum graph
            meanpower = np.mean(power)

            # record a bunch of metrics of magnitude
            met.append(mean)  #mean of accel
            #met.append(plt.mlab.entropy(power, 20)) #entropy of power, binned into 20 bins
            #met.append(meanpower)  #average of power
            met.append(np.std(power)) #std dev of power
            #met.append(np.max(power))  #maximum power
            #met.append(freq[np.argmax(power)])  #maximum frequency
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

# get features for training set, train CLF on features
train_features = make_features(train_files)
clf = DecisionTreeClassifier(random_state=0,max_depth=3)
clf.fit(train_features, train_classes)

# get test set features and predictions
test_features = make_features(test_files)
predictions = clf.predict(test_features)
correct = np.sum(np.equal(test_classes, predictions)) / float(len(test_classes))
print correct, "accuracy rate"

# confusion matrix
cm = confusion_matrix(test_classes, predictions)
print cm

# save CLF tree
with open('graph.dot', 'w') as file:
    tree.export_graphviz(clf, out_file = file)


