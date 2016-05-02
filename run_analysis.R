# R script called run_analysis.R that does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average
# of each variable for each activity and each subject.

# Load packages
# If packages don't exist, install
if (!require('data.table')) {
  install.packages('data.table')
}

library('data.table')

if (!require('reshape2')) {
  install.packages('reshape2')
}

library('reshape2')

# Set filepath for data upload
input <- 'UCI HAR Dataset/'

# Load activity labels
activity_labels <- read.table(paste0(input,'activity_labels.txt'))[,2]

# Load features
features <- read.table(paste0(input, 'features.txt'))[,2]

# Select measurements on the mean and standard deviation
features_extract <- grepl('mean|std', features)

# Load test data
subject_test <- read.table(paste0(input, 'test/subject_test.txt'))
names(subject_test) <- 'subject'

X_test <- read.table(paste0(input, 'test/X_test.txt'))
names(X_test) <- features
X_test_extract <- X_test[, features_extract]

y_test <- read.table(paste0(input, 'test/y_test.txt'))
y_test[,2] <- activity_labels[y_test[,1]]
names(y_test) <- c('activity_id', 'activity_label')

# Bind test datasets
test <- cbind(as.data.table(subject_test), y_test, X_test_extract)

# Load training data
subject_train <- read.table(paste0(input, 'train/subject_train.txt'))
names(subject_train) <- 'subject'

X_train <- read.table(paste0(input, 'train/X_train.txt'))
names(X_train) <- features
X_train_extract <- X_train[, features_extract]

y_train <- read.table(paste0(input, 'train/y_train.txt'))
y_train[,2] <- activity_labels[y_train[,1]]
names(y_train) <- c('activity_id', 'activity_label')

# Bind training datasets
training <- cbind(as.data.table(subject_train), y_train, X_train_extract)

# Merge training and test datasets
data <- rbind(training, test)

# Collapse dataset
id_cols <- c('subject', 'activity_id', 'activity_label')
data_long <- melt(data, id = id_cols, measure.vars = setdiff(colnames(data), id_cols))

# Create tidy dataset
# Calculate average of each variable by activity and subject
data_tidy <- dcast(data_long, subject + activity_label ~ variable, mean)

# Export dataset
write.table(data_tidy, 'data_tidy_assignment_week4.txt')

