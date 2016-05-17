Each numbered folder contains the triple access accelerometer and gyroscope data collected from a single study subject.

Each subject completed a workout consisting of three sets of 5 repetitions of: squat, bench press, bent over rows, bicep curls, tricep extensions. The first set was with a very low weight, the second set with a slightly-difficult weight, and the third set with a more difficult weight.

Within each folder, there are three types of files:
1) Workout.csv - unsegmented data of the entire workout 
2) ExerciseTimes.json - time stamps used to partition Workout.csv into each exercise
3) {Squat, Bench, Row, Curl, TricepExtension}{Low, Medium, High}.csv - contains the segmented data of a single workout at a single intensity (e.g. BenchLow.csv contains data for Bench Press with a Low intensity weight)