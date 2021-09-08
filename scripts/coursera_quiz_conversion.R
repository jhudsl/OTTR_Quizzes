# Need here and R.utils
# For testing use quiz_lines  <- readLines(here::here("quizzes", "quiz_ch1.md"))

# This is functionalized but running like script for now till we decide where to put this:
# run by  pasting `Rscript scripts/coursera_quiz_conversion.R` in the terminal

coursera_quizzes <- function(path= here::here("ITCR_Cancer_Research_Leadership_Leanpub/quizzes"), # we might want to update to manuscript
                             verbose = TRUE) {
  leanpub_quizzes = list.files(
    pattern = (".md"),
    ignore.case = TRUE,
    path = path,
    full.names = FALSE)
  if (length(leanpub_quizzes) < 1) {
    stop(paste0("No quiz .md files found in your specified path dir of: ", path))
  }
  print(leanpub_quizzes)

  for(quiz in leanpub_quizzes){

    `%>%` <- dplyr::`%>%`

    ### First read lines for each quiz
    quiz_lines  <- readLines(file.path(path, quiz))

    # Put it as a data.frame:
    quiz_lines_df <- data.frame(quiz_lines) %>%
      dplyr::mutate(type = dplyr::case_when(
        # Find starts to questions:
        grepl("^\\?", quiz_lines) ~ "prompt",
        # Find which lines are the wrong answer options
        grepl("^[[:lower:]]{1}\\)", quiz_lines) ~ "wrong_answer",
        # Find which lines are the correct answer options
        grepl("^[[:upper:]]{1}\\)", quiz_lines) ~ "correct_answer",
        # Find the tags
        grepl("^\\{", quiz_lines) ~ "tag",
        # Mark empty lines
        nchar(quiz_lines) == 0 ~ "empty",
        # Mark everything else as "other
        TRUE ~ "other"
      )) %>%
      # Remove empty lines
        dplyr::filter(type != "empty")

    grep("answer", quiz_lines_df$type)
    # Find extended prompts:
    which(quiz_lines_df$type == "prompt"):grep("answer", quiz_lines_df$type)


      # Now for updating based on type!
      dplyr::mutate(updated_line = dplyr::case_when(
        type == "prompt" ~ stringr::str_replace(quiz_lines, "^\\?", "prompt:"),
        grepl(type, "answer") ~ stringr::str_replace(quiz_lines, "^[[:alpha:]]\\)", "    - answer:"),

        TRUE ~ quiz_lines
      ))

    ### Now to update question prompts
    prompt_loc <- which(quiz_lines_df$type == "prompt")

    # Start each question with this type:
    quiz_lines <- R.utils::insert(quiz_lines, ats = (prompt_loc + 1), values = "- typeName: multipleChoice")

    # Add "  shuffleoptions: true" to the line after question prompts (the lines with ? - may be after the line with prompt:)
    quiz_lines <- R.utils::insert(quiz_lines, ats = (prompt_loc + 1), values = "  shuffleOptions: true")

    # Add "  options:" in the line after those just added
    quiz_lines <- R.utils::insert(quiz_lines, ats = (prompt_loc + 2), values = "  options:")

    # Modify lines that start with number for prompt so that they have 4 spaces in front
    quiz_lines[grep("^[1-9].", quiz_lines)] <- paste0("    ", quiz_lines[grep("^[1-9].", quiz_lines)])

    # Need to add "isCorrect: true" one line below correct value lines
    quiz_lines <-R.utils::insert(quiz_lines, ats = (Correct_loc + 1), values = "      isCorrect: true")

    # Need to add "isCorrect: false" one line below incorrect value lines
    quiz_lines <- R.utils::insert(quiz_lines, ats = (Wrong_loc + 1), values = "      isCorrect: false")

    ### Write new file with .yml at end of file name and put in coursera dir
    writeLines(quiz_lines, con=file.path(here::here("coursera"), paste0(quiz, ".yml")))
  }
}

### Run function
coursera_quizzes()

