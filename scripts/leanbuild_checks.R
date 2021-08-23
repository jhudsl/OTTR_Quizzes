#!/usr/bin/env Rscript

# Check over the formatting of the quizzes and chapters 
# after running leanbuild::bookdown_to_leanbuild()
# 
# C. Savonen 2021

library(optparse)

################################ Set up options ################################
# Set up optparse options
option_list <- list(
  make_option(
    opt_str = c("-q", "--quiz_path"), type = "character",
    default = "quizzes" ,
    help = "Path to a folder of Markua-formatted .md file quizzes. Default is to 
    look for a folder called 'quizzes' in the top of the repository.",
    metavar = "character"
  )
)

# Parse options
opt <- parse_args(OptionParser(option_list = option_list))

# Find .git root directory
root_dir <- rprojroot::find_root(rprojroot::has_dir(".git"))

########## Quiz Checking
# Declare path to quiz directory
opt$quiz_path <- file.path(root_dir, opt$quiz_path)

# Check quizzes
leanbuild::check_quizzes(opt$quiz_path)

# Get all file paths
quiz_paths <- file.path(opt$quiz_path, dir(opt$quiz_path))

run_all_quiz_checks <- function(file_path) {
  leanpub_check
  
  # Parse the quiz
  parsed_quiz <- leanbuild::parse_quiz(readLines(a_quiz))
  
  # Run all checks; store as a list
  checks <- list(
    quiz_attributes = leanbuild::check_quiz_attributes(parsed_quiz),
    quiz_question_attributes = leanbuild::check_quiz_question_attributes(parsed_quiz)
  )
}

########## Book and book.txt checking
# Check image and video links 
leanbuild::leanpub_check("manuscript")

########## Check references 

