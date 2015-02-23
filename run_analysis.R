setup <- function(){

#create folder for project
dir.create("project1")

#change wd to created folder
wd <- getwd()
wd_new <- paste0(wd,"/project1")
setwd(wd_new)
}

download <- function(){
  
#download files to project1 dir
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile <- "raw_data.zip"
download.file(url,destfile)
unzip(destfile)

}

setup()
download()

##################
#LOAD RAW DATA
##################
  X_train <- read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE, sep="")
  y_train <- read.table("UCI HAR Dataset/train/y_train.txt", header=FALSE, sep="")
  subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep="")
  

  X_test <- read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE, sep="")
  y_test <- read.table("UCI HAR Dataset/test/y_test.txt", header=FALSE, sep="")
  subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header=FALSE, sep="")
  
###############################
## 1 MERGE TEST AND TRAINING DATA
###############################

#Merge TEST and TRAINING data
X_full <- rbind.data.frame(X_test,X_train)
y_full <- rbind.data.frame(y_test,y_train)
subject_full <- rbind.data.frame(subject_test,subject_train)



#########################################
## 2 Extract mean & std measurements
#########################################

#find the column numbers of X_full that contain mean or std
features <- read.table("UCI HAR Dataset/features.txt", header=FALSE, sep="")
features_mean_std <- (grepl("mean",features[,2]) | grepl("std",features[,2]))

#subset X_full so it contains only mean & std columns
X_simplified <- X_full[,features_mean_std]

#cbind subject_full, y_full and X_simplified
Data_simplified <- cbind.data.frame(subject_full,y_full,X_simplified)

#################################################################
## 3 use descriptive names to name the activities in the dataset
#################################################################
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING

Data_simplified[,2] <- as.factor(Data_simplified[,2])
levels(Data_simplified[,2]) <- c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")

###########################################################
## 4 Label dataset with appropriate descriptive variables
############################################################

#extract unformatted names from features vectors
names <- features[features_mean_std,2]
#use make.names function to format names to format features names to syntactically valid
#names without parenthesis, and dashes
valid_names <- make.names(names)

Names_simplified <- c("subject","activity",valid_names)

names(Data_simplified) <- Names_simplified

###########################################################
## 5 Avg of each var for each activity and subject
###########################################################
library(plyr)
Data_simplified[,1] <- as.factor(Data_simplified[,1])
means_data = ddply(Data_simplified,.(subject,activity),colwise(mean))

write.table(means_data,"tidy_dataset.txt")

