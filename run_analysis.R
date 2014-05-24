setwd("F:/Projects/Coursera/Stats/GettingAndCleaningData/Project")
# name of the directory containing the data
basePath <- "UCI HAR Dataset"

# load the activity label data
activityLabels <- read.table(file.path(basePath, "activity_labels.txt"))
names(activityLabels) <- c("id","activity.label")

# load the feature label data
featureLabels <- read.table(file.path(basePath,"features.txt"))
names(featureLabels) <- c("id","feature.label")

# transform the labels so the adhere to the rules of http://google-styleguide.googlecode.com/svn/trunk/Rguide.xml
# The preferred form for variable names is all lower case letters and words separated with dots (variable.name),
# but variableName is also accepted
featureLabels$feature.label <- gsub("\\(\\)-",".",featureLabels$feature.label)
featureLabels$feature.label <-  gsub("\\(\\)$","",featureLabels$feature.label)
featureLabels$feature.label <-  gsub("\\(\\)(?=[1-9])",".",featureLabels$feature.label,perl=T)
featureLabels$feature.label <-  gsub("\\)$","",featureLabels$feature.label)
featureLabels$feature.label <-  gsub("-",".",featureLabels$feature.label)
featureLabels$feature.label <-  gsub(",",".",featureLabels$feature.label)
featureLabels$feature.label <- gsub("\\(",".",featureLabels$feature.label)
featureLabels$feature.label <- gsub("\\)","",featureLabels$feature.label)

# function which reads and combines into one data frame from either test or train data sets
# set can be either train or test
ReadAndCombine <- function(set)
{
  # read test set data and add the row number as a variable for merging
  subjects <- read.table(file.path(basePath, set, paste("subject_",set,".txt",sep="")))
  names(subjects) <- c("subject.id")
  subjects$subject.id <- as.factor(subjects$subject.id)
  subjects$row.number <- rownames(subjects)
  activities <- read.table(file.path(basePath, set, paste("y_",set,".txt", sep="")))
  names(activities) <- c("activity.id")
  activities$activity.id <- as.factor(activities$activity.id)
  activities$row.number <- rownames(activities)
  features <- read.table(file.path(basePath, set, paste("x_",set,".txt",sep="")))
  names(features) <- featureLabels$feature.label
  features$row.number <- rownames(features)
  
  #combine the data
  require(plyr)
  all <- join_all(list(subjects, activities, features))
  
  # remove the row number column
  all <- all[,c(-2)]
  
  all
}

testData <- ReadAndCombine("test")
trainData <- ReadAndCombine("train")

#combine the data sets
allData <- rbind(testData, trainData)

# get the indexes of the columns containing the mead and std
requiredColumns <- grep("mean|std|Mean",names(allData))
requiredColumns <- c(1,2,requiredColumns)

# keep only the required columns
allData <- allData[,requiredColumns]

# add activity descriptive names
allData$activity.name <- activityLabels$activity.label[allData$activity.id]

summaryData <- unique(data.frame(subject = allData$subject.id, activity = allData$activity.name))
rownames(summaryData) <- 1:nrow(summaryData)
numberOfFeatures <- ncol(allData)-3 # there are 3 columns which aren't features
numberOfRows <- nrow(summaryData)
featureMeanPlaceholders <- matrix(rep(0,numberOfFeatures * numberOfRows),nrow=numberOfRows, ncol = numberOfFeatures)
summaryData <- cbind(summaryData, featureMeanPlaceholders)
names(summaryData) <- c("subject", "activity", names(allData)[c(-1,-2,-ncol(allData))])

currentRow = 1
while(currentRow<=numberOfRows)
{
  # subset the data to contain only the rows with the current subject and activity
  dataSubset <- subset(allData, allData$subject.id == summaryData$subject[currentRow] & allData$activity.name == summaryData$activity[currentRow])

  currentFeature = 1
  while(currentFeature<=numberOfFeatures)
  {
    summaryData[currentRow, currentFeature + 2] <- mean(dataSubset[,currentFeature+2])
    currentFeature <- currentFeature + 1
  }
  currentRow <- currentRow + 1
}

write.table(summaryData, "summaryData.txt")
View(summaryData)
