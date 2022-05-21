#Link to the data for the project
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Downloading project data
library(downloader)
download(url, dest = "./gcd_project/data.zip")

#unzipping data from the zip file into the directory project_data
dir.create("./gcd_project/project_data")
unzip("./gcd_project/data.zip", exdir = "./gcd_project/project_data")

#reading in data and and assigning data from each file to a variable
setwd("./gcd_project/project_data")
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("num", "functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activities"))
train_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subjects")
test_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subjects")
train_data <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
test_data <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
train_data_labels <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")
test_data_labels <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")

#merging training and test datasets to create one dataset
library(dplyr)
data <- bind_rows(train_data, test_data)
subjects <- bind_rows(train_subjects, test_subjects)
labels <- bind_rows(train_data_labels, test_data_labels)
data_set <- bind_cols(subjects,labels, data)

#Extracting only the measurements on the mean and standard deviation for each measurement. 
mean_std_data <- select(data_set, subjects, code, contains("mean"), contains("std"))

#Using descriptive activity names to name the activities in the data set
activity_names <- gsub("1", "WALKING", activity_codes)
activity_names <- gsub("2", "WALKING_UPSTAIRS", activity_names)
activity_names <- gsub("3", "WALKING_DOWNSTAIRS", activity_names)
activity_names <- gsub("4", "SITTING", activity_names)
activity_names <- gsub("5", "STANDING", activity_names)
activity_names <- gsub("6", "LAYING", activity_names)
mean_std_data <- mutate(mean_std_data, code = activity_names)

#appropriately labeling the data set with descriptive variable names
names(mean_std_data) <- gsub("code", "activity", names(mean_std_data))
names(mean_std_data) <- gsub("Acc", "Accelerometer", names(mean_std_data))
names(mean_std_data) <- gsub("Gyro", "Gyroscope", names(mean_std_data))
names(mean_std_data) <- gsub("BodyBody", "Body", names(mean_std_data))
names(mean_std_data) <- gsub("Mag", "Magnitude", names(mean_std_data))
names(mean_std_data) <- gsub("^t", "Time", names(mean_std_data))
names(mean_std_data) <- gsub("^f", "Frequency", names(mean_std_data))
names(mean_std_data)<- gsub("tBody", "TimeBody", names(mean_std_data))
names(mean_std_data)<- gsub("-mean()", "Mean", names(mean_std_data), ignore.case = TRUE)
names(mean_std_data) <- gsub("-std()", "STD", names(mean_std_data), ignore.case = TRUE)
names(mean_std_data) <- gsub("-freq()", "Frequency", names(mean_std_data), ignore.case = TRUE)
names(mean_std_data) <- gsub("angle", "Angle", names(mean_std_data))
names(mean_std_data) <- gsub("gravity", "Gravity", names(mean_std_data))

#From the data set mean_std_data, creating a second, independent tidy data set with the average of each variable for each activity and each subject and saving it in a file named tidy_data.txt

grouped_data <- group_by(mean_std_data, subjects, activity)
averages <- summarize_all(grouped_data, mean)
tidy_dataset <- averages
write.table(tidy_dataset, "tidy_dataset.txt", row.name = F)
