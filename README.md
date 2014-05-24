# The task and input data
## The data provided
* A list of names for the measurements gathered (file: features.txt)
* A list of activity names (file: activity_labels.txt)
* The subject ids of the participants, activities performed and measirements, all divided into test and training sets (folders test and train).
  * subject ids (file: subject_test.txt)
  * activity ids (file:y_test.txt)
  * measurements (file:X_test.txt)

## The task
* Combine the data into one dataset, extract only the mean and standard deviation of the measurements and provide descriptive names for the columns of the data set
* Create a separate data set containg average values of the measurements for each combination of subjects and activities

# Description of the script used
First I load the common activity and measurement labels.

To make the measurement labels conform to R variable naming guidelines (http://google-styleguide.googlecode.com/svn/trunk/Rguide.xml) I remove all parenthesis and underscores and replace them with dots where appropriate.

Next the subject, activity and measurement data sets are loaded and descriptive names provided for the columns. The data sets are combined into one based on the row numbers.

After the training and test data sets are loaded and combined, the rows of both data sets are combined into one.

Next only the measurements containing mean and std values are extracted from the combined data set.

After that the descriptive names from the activity labels data are inserted into a separate column based on the activity id.

The summary data set is created by first making a data set with unique subject and activity columns and placeholder columns for each measurement from the final combined data. After that the average values of all the measurements are calculated by looping over every combination of subject / activity and filling in the corresponding cells in the summary data frame.