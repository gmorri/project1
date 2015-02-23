# Project 1 - Getting and Cleaning Data

## Why is *tidy_dataset.txt* a "tidy dataset"?

The finished dataset has unique observations defined by the subject and activity.  There is one row per subject and activity leading to 180 rows (since there are 30 subjects and 6 activities).

Each variable in the finished dataset is contained within only one column.  These variables are given descriptive variable names so a user can understand their meaning with the help of the codebook.  The variables have also been converted to syntactically valid R variables so they can be easily used in analysis.

Finally, the activity variable has been converted from a numeric to factor variable.  This insures that the variable is descriptive in nature and even if the codebook is lost, a user would be able to tell which activity a row corresponds to.

## Summary of run_analysis.R

The code for this project is split into five main sections for each of the steps outlined on the project page.  

### Preparation

**setup()** function creates a "project1" directory within the current working directory.  Working directory is then set to "project1".

> setup <- function(){
>
>	#create folder for project
>		dir.create("project1")
>	#change wd to created folder

>		wd <- getwd()
>	wd_new <- paste0(wd,"/project1")
>	setwd(wd_new)
>}


**download()** function downloads and unzips the file from its url.

> download <- function(){
>	 #download files to project1 dir
>	url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
>	destfile <- "raw_data.zip"
>	download.file(url,destfile)
>	unzip(destfile)
> }


### Load Raw Data

Test and training data are loaded into one's R environment as data frames through the read.tables function. 

The three files for test and train data are X_%, y_%, and subject_% (where % represents a wildcard).

>  X_train <- read.table("UCI HAR Dataset/train/X_train.txt", header=FALSE, sep="")
>  y_train <- read.table("UCI HAR Dataset/train/y_train.txt", header=FALSE, sep="")
>  subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep="")
>  
>  X_test <- read.table("UCI HAR Dataset/test/X_test.txt", header=FALSE, sep="")
>  y_test <- read.table("UCI HAR Dataset/test/y_test.txt", header=FALSE, sep="")
>  subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header=FALSE, sep="")


Note, separator must be set to sep="" and not sep=" ".  When sep="", read.tables treats all white space such as one space or multiple spaces as separators.  

### Step 1 - Merge Test and Training Data

Each of the test and training data frames for X_%, y_%, and subject_% are merged using **rbind.data.frame()**.

>  X_full <- rbind.data.frame(X_test,X_train)
>  y_full <- rbind.data.frame(y_test,y_train)
>  subject_full <- rbind.data.frame(subject_test,subject_train)

The each of X_%, y_% and subject_% data frames are merged so that the training data is row binded to the bottom of the test data.

### Step 2 - Extract Mean & Std Measurements

The feature.txt file that contains variable descriptions is loaded.  The **grepl()** function then determines which elements of the features vector contain either the string "mean" or "std".

> features <- read.table("UCI HAR Dataset/features.txt", header=FALSE, sep="")
> features_mean_std <- (grepl("mean",features[,2]) | grepl("std",features[,2]))

The combined X dataframe is subsetted by column to create a simplified dataframe containing only mean and std variables.

> X_simplified <- X_full[,features_mean_std]

A complete data frame is created by column binding subject_full, y_full and X_simplified.

> Data_simplified <- cbind.data.frame(subject_full,y_full,X_simplified)

### Step 3 - Name Activities

The row in *Data_simplified* corresponding to *y_full* is converted to a factor.  The factor levels are then labeled.

> Data_simplified[,2] <- as.factor(Data_simplified[,2])
> levels(Data_simplified[,2]) <- c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")

### Step 4 - Label Variables with Appropriate Descriptive Variable Names

The names of the variables that remain in Data_simplified are extracted from the *features* vector.

> names <- features[features_mean_std,2]

**make.names()** is used to convert the descriptive variable names in appropriate, syntactically valid R names.  A syntactically valid name in R consists of letters, numbers and the dot or underline characters and it starts with a letter.

> valid_names <- make.names(names)

Column names are then set for *Data_simplified*.

> Names_simplified <- c("subject","activity",valid_names)
> names(Data_simplified) <- Names_simplified

### Step 5 - Average of each variable by subject and activity

The **plyr** package is loaded and the column corresponding to subjects is converted to a factor.

> library(plyr)
> Data_simplified[,1] <- as.factor(Data_simplified[,1])

**ddply()** is used to find the average of each column grouping by subject and activity:

> means_data = ddply(Data_simplified,.(subject,activity),colwise(mean))

The tidy dataset is then written to a text file.

> write.table(means_data,"tidy_dataset.txt")




