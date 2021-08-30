# Need here and R.utils
# For testing use tx_i  <- readLines(here("quizzes", "quiz_ch1.md"))

# This is functionalized but running like script for now till we decide where to put this:
# run by  pasting `Rscript scripts/coursera_quiz_conversion.R` in the terminal

library(R.utils)


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
  
  for(i in leanpub_quizzes){
    tx_i  <- readLines(paste0(path,"/", i))
   # hashtag <-tx_i[grepl(pattern = "^\\#", tx_i)] # maybe we will need to remove these?
    ### Remove attempts line
    tx_i <-tx_i[-grep(pattern = "attempts:", tx_i)]
    ### Remove instruction line # this is not general yet...or maybe ok if we specify this
    tx_i <-tx_i[-grep(pattern = "Choose the best answer", tx_i)]
    ### Now to replace type
    tx_i[grepl(pattern = "choose-answers:", tx_i)]<- c("- typeName: multipleChoice")
    ### Now to update question prompts
    tx_i <-gsub(pattern = "^\\?", replacement = "  prompt:", tx_i)
    Prompt_loc <- grep(pattern = "\\?", tx_i)
    tx_i <- insert(x = tx_i, ats = (Prompt_loc + 1), values = "  shuffleOptions: true") 
    Prompt_loc <- grep(pattern = "shuffleOptions", tx_i)
    tx_i <- insert(x = tx_i, ats = (Prompt_loc + 1), values = "  options:")
    #replace the ":" in prompts that have it
    tx_i[grep(pattern = "prompt:", tx_i)] <- gsub(tx_i[grep(pattern = "prompt:", tx_i)], pattern = ":", replacement = "?")
    # add back the ":" for "prompt:"
    tx_i[grep(pattern = "prompt?", tx_i)] <- gsub(tx_i[grep(pattern = "prompt?", tx_i)], pattern = "prompt\\?", replacement = "prompt:")
    #modify numbered lines for prompt so that they have spaces in front
    tx_i <- gsub(pattern = "^1.", replacement = "    1.", tx_i)
    tx_i <- gsub(pattern = "^2.", replacement = "    2.", tx_i)
    tx_i <- gsub(pattern = "^3.", replacement = "    3.", tx_i)
    tx_i <- gsub(pattern = "^4.", replacement = "    4.", tx_i)
    tx_i <- gsub(pattern = "^5.", replacement = "    5.", tx_i)
    tx_i <- gsub(pattern = "^6.", replacement = "    6.", tx_i)
    tx_i <- gsub(pattern = "^7.", replacement = "    7.", tx_i)
    tx_i <- gsub(pattern = "^8.", replacement = "    8.", tx_i)
    tx_i <- gsub(pattern = "^9.", replacement = "    9.", tx_i)
    # unlikely for more than 9 options!
    ### Now to remove empty line after options
    Opt_loc <-grep(pattern = "^  options:", tx_i)
    tx_i <-tx_i[-(Opt_loc+1)]
    ### Now to update correct answers - First remove half...(coursera only allows one per question)
    Correct_loc <-grep(pattern = "^C\\)", tx_i)
    Correct_loc_to_rem <- Correct_loc[Correct_loc %%2 =="1"] # find odd rows of correct answers to rem
    tx_i <-tx_i[-Correct_loc_to_rem]
    ### Now to update remaining correct answers
    Correct_loc <-grep(pattern = "^C\\)", tx_i) # updating location
    tx_i <- insert(x = tx_i, ats = (Correct_loc + 1), values = "      isCorrect: true")
    tx_i <- gsub(pattern = "^C\\)", replacement = "    - answer:", tx_i)
    ### Now to update mandatory incorrect answers
    Man_wrong_loc <-grep(pattern = "^m\\)", tx_i)
    tx_i <- insert(x = tx_i, ats = (Man_wrong_loc + 1), values = "      isCorrect: false")
    tx_i <- gsub(pattern = "^m\\)", replacement = "    - answer:", tx_i)
    ### Now to update optional incorrect answers
    Opt_wrong_loc <-grep(pattern = "^o\\)", tx_i)
    tx_i <- insert(x = tx_i, ats = (Opt_wrong_loc + 1), values = "      isCorrect: false")
    tx_i <- gsub(pattern = "^o\\)", replacement = "    - answer:", tx_i)
    ### Remove end quiz line
    tx_i <-tx_i[-grep(pattern = "/quiz", tx_i)]
    writeLines(tx_i, con=paste0(here("coursera"),"/", i, ".yml"))
  }
}

coursera_quizzes()

