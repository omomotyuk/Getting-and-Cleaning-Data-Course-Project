##
## 1. Download and unzip data files:
##

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file( fileUrl,destfile="getdata_projectfiles_UCI HAR Dataset.zip" )

system( "unzip getdata_projectfiles_UCI\\ HAR\\ Dataset.zip" )

##
##  2. Merges the training and the test sets to create one data set:
##

X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")

data_set <- rbind( X_train,X_test )

##
## 3. Extracts only the measurements on the mean and standard deviation for each measurement:
##

features <- read.table("./UCI HAR Dataset/features.txt")
names( data_set ) <- features[ ,2 ]
data_set <- data_set[ grepl( "-mean\\(|-std\\(" ,names(data_set) ) ]

##
## 4. Uses descriptive activity names to name the activities in the data set and 
##    appropriately labels the data set with descriptive variable names:
##

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

subject_set <- rbind( subject_train,subject_test )

y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

y_set <- rbind( y_train,y_test )

subject_activity_set <- cbind( subject_set,y_set )
names( subject_activity_set ) <- c( "Subject","Activity" )

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
names( activity_labels ) <- c( "Activity","Activity.labels" )

subject_activity_set <- merge( subject_activity_set,activity_labels,by.x="Activity",by.y="Activity" )

data_set <- cbind( subject_activity_set,data_set )

##
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject:
##

library( dplyr )

data_tbl <- tbl_df( data_set )

data_tbl <- select( data_tbl,-Activity )
data_tbl <- rename( data_tbl,Activity = Activity.labels )

tidyData <- function( data ){
group_by( data, Subject, Activity ) %>%
   summarise_all( funs( mean ) )
}

tidyDataSet <- tidyData( data_tbl )

##
## 6. Writes tidy data set in tidyDataSet.csv file and prepares draft CodeBook.md file:
##

write.csv( tidyDataSet,file="tidyDataSet.csv",row.names = FALSE)
write.table( names(tidyDataSet),file="addToCodeBook.txt",quote = FALSE,sep = "\t" )

system( "cat ./UCI\\ HAR\\ Dataset/README.txt ./UCI\\ HAR\\ Dataset/features_info.txt ./UCI\\ HAR\\ Dataset/activity_labels.txt addToCodeBook.txt > CodeBook.md" )
