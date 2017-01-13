# Individual Assignment 1 Jump-Start Code (Word Clouds Only)

# here we show how to make a word cloud for a set of text documents
# the documents should be plain text with UTF-8 encoding
# they should be given the extension .txt
# and stored under a directory/folder named text_documents

# you can execute this program from R by typing
# source("run_word_cloud_jump_start_v001.R")
# but first identify the computer environment 
# to begin identify the computer environment as windows versus max/linux
# comment out the system that does not apply
windows_system <- FALSE  # setting for Max and Linux
# windows_system <- TRUE  # setting for Windows

# set the workspace location to be the directory where
# this program resides, with text_documents as a subdirectory/folder

# ensure that wordcloud and tm packages have been installed into R  
# prior to executing these commands 
library(wordcloud)  # bring wordcloud package into workspace
library(tm)  # bring text analytics tools into workspace

# note. there may be other text analytics and text processing 
# packages to install in later jump-start examples

# much of the following code is associated with file manipulation
# the code is designed to work on either Mac/Linux or windows_system
# but we need to specify the type of computer system prior to execution
# locate yourself in working directory that has corpus directory
# and identify the directory labeled "corpus"
if (windows_system) 
    directory_location <- paste(getwd(), "\\text_documents\\", sep = "")

if(!windows_system)     
    directory_location <- paste(getwd(), "/text_documents/", sep = "")

# get file names in the corpus directory_location
file_names <- dir(directory_location)

# define data frame of words from files in directory_location
# words are associated with the file names in the text_documents directory
text_data_frame <- NULL
for (ifile in seq(along = file_names)) { # begin for-loop for text objects
    # define the file name within the directory text_documents
    this_file <- paste(paste(directory_location, file_names[ifile], sep = ""))
    # read the file and convert all to lowercase letters
    this_text <- tolower(scan(this_file, what = "char", sep = "\n"))
    # consider words only
    this_text_words <- unlist(strsplit(this_text, "\\W"))
    # words must be words
    this_text_vector <- this_text_words[which(nchar(this_text_words) > 0)]
    # create data frame with each row being one word
    this_data_frame <- data.frame(document = file_names[ifile], text = this_text_vector,
        stringsAsFactors = FALSE)
    text_data_frame <- rbind(text_data_frame, this_data_frame)
    }  # end for-loop for text objects

print(str(text_data_frame))  # show the structure of the data frame

# -----------------------------------
# word clouds
# -----------------------------------
# use loop to generate one word cloud for each text file
# plot that file to a pdf file 
for (ifile in seq(along = file_names)) { 
    this_file_label <- strsplit(file_names[ifile], ".txt", "")[[1]]
    # there will be a different pdf file for each file being displayed
    pdf(file = paste("word_cloud_", this_file_label, ".pdf", sep = ""),
        width = 8.5, height = 8.5)
    cat("\nPlotting ", this_file_label)    
    this_text_vector <- as.character(subset(text_data_frame, 
        subset = (document == file_names[ifile]), select = text))
        
    # the following is the core word cloud graphics code
    # we assume that this_text_vector is a character vector
    # of words to be displayed in the cloud
    # best practice for word clouds is horizontal text: rot.per = 0.0
    # explore by modifying the min.freq and max.words argument values
    wordcloud(this_text_vector, min.freq = 5,
        max.words = 150, 
        random.order = FALSE,
        random.color = FALSE,
        rot.per = 0.0, # all horizontal text
        colors = "black",
        ordered.colors = FALSE,
        use.r.layout = FALSE,
        fixed.asp = TRUE)
    dev.off()
    }  
        
# Do not be concerned about warning messages about incomplete
# lines in the input files. There are many blank lines on input.

cat("\n\n RUN COMPLETE")   