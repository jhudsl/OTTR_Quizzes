# Need here and R.utils
# For testing use quiz_lines  <- readLines(here::here("quizzes", "quiz_ch1.md"))

# This is functionalized but running like script for now till we decide where to put this:
# run by  pasting `Rscript scripts/coursera_quiz_conversion.R` in the terminal

coursera_quizzes <- function(path= here::here("quizzes"), # we might want to update to manuscript
                             verbose = TRUE) {
  leanpub_quizzes = list.files(
    pattern = (".md"),
    ignore.case = TRUE,
    path = path,
    full.names = FALSE)
  if (length(leanpub_quizzes) < 1) {
    warning("You need quiz files in your specified path dir")
  }
  print(leanpub_quizzes)

  for(quiz in leanpub_quizzes){
    ### First read lines for each quiz
    quiz_lines  <- readLines(file.path(path, quiz))
    ### Remove attempts line and final line and instruction line about choosing the best answer (this requires people following leanpub template)
    quiz_lines <-quiz_lines[-grep(pattern = "attempts:|Choose the best answer|/quiz", quiz_lines)]
    ### Now to replace type
    quiz_lines[grepl(pattern = "choose-answers:", quiz_lines)]<- c("- typeName: multipleChoice")
    ### Now to update question prompts
    # Replace question mark at beginning with the "  prompt:"
    quiz_lines <- gsub(pattern = "^\\?", replacement = "  prompt:", quiz_lines)
    # Find lines with question marks
    Prompt_loc <- grep(pattern = "\\?", quiz_lines)
    # Add "  shuffleOptions: true" to the line after question prompts (the lines with ? - may be after the line with prompt:)
    quiz_lines <-R.utils::insert(x = quiz_lines, ats = (Prompt_loc + 1), values = "  shuffleOptions: true")
    # Find the location of the lines just added
    Prompt_loc <- grep(pattern = "shuffleOptions", quiz_lines)
    # Add "  options:" in the line after those just added
    quiz_lines <-R.utils::insert(x = quiz_lines, ats = (Prompt_loc + 1), values = "  options:")
    # Replace the ":" in prompts that have it
    quiz_lines[grep(pattern = "prompt:", quiz_lines)] <- gsub(quiz_lines[grep(pattern = "prompt:", quiz_lines)], pattern = ":", replacement = "?")
    # Add back the ":" for "prompt:" - got removed in last step of code
    quiz_lines[grep(pattern = "prompt?", quiz_lines)] <- gsub(quiz_lines[grep(pattern = "prompt?", quiz_lines)], pattern = "prompt\\?", replacement = "prompt:")
    # Modify lines that start with number for prompt so that they have 4 spaces in front
    quiz_lines[grep("^[1-9].", quiz_lines)] <-paste0("    ", quiz_lines[grep("^[1-9].", quiz_lines)])
    ### Now to remove empty line after options
    # First find lines that start with "  options:"
    Opt_loc <-grep(pattern = "^  options:", quiz_lines)
    # Remove these lines after those containing options:
    quiz_lines <-quiz_lines[-(Opt_loc+1)]
    ### Now to update correct answers - First remove half...(coursera only allows one per question)
    # Find all correct answer lines (those that start with "C)")
    Correct_loc <-grep(pattern = "^C\\)", quiz_lines)
    # Of the correct answer lines find odd rows (when divided by 2 there is a remainder)
    Correct_loc_to_rem <- Correct_loc[Correct_loc %%2 =="1"] # find odd rows of correct answers to rem
    # Remove the odd rows of correct answers
    quiz_lines <-quiz_lines[-Correct_loc_to_rem]
    ### Now to update remaining correct answers
    # First need to update location of correct answer lines (since we removed lines)
    Correct_loc <-grep(pattern = "^C\\)", quiz_lines)
    # Need to add "isCorrect: true" one line below correct value lines
    quiz_lines <-R.utils::insert(x = quiz_lines, ats = (Correct_loc + 1), values = "      isCorrect: true")
    # Change the correct answer lines to start with "    - answer:" instead of "C)"
    quiz_lines <- gsub(pattern = "^C\\)", replacement = "    - answer:", quiz_lines)
    ### Now to update Leanpub mandatory and optional incorrect answers
    # First find the location of lines that start with "m)" or "o)"
    Wrong_loc <- grep(pattern = "^m\\)|^o\\)", quiz_lines)
    # Need to add "isCorrect: false" one line below incorrect value lines
    quiz_lines <-R.utils::insert(x = quiz_lines, ats = (Wrong_loc + 1), values = "      isCorrect: false")
    # Replace "m)" with "    - answer:" at the start of the lines with the mandatory incorrect answers
    quiz_lines <- gsub(pattern = "^m\\)|^o\\)", replacement = "    - answer:", quiz_lines)
    ### Write new file with .yml at end of file name and put in coursera dir
    writeLines(quiz_lines, con=file.path(here::here("coursera"), paste0(quiz, ".yml")))
  }
}

### Run function
coursera_quizzes()

