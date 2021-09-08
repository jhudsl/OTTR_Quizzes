# Need here and R.utils
# For testing use quiz_lines  <- readLines(here::here("quizzes", "quiz_ch1.md"))

# This is functionalized but running like script for now till we decide where to put this:
# run by  pasting `Rscript scripts/coursera_quiz_conversion.R` in the terminal

coursera_quizzes <- function(path = file.path("quizzes"), # we might want to update to manuscript
                             verbose = TRUE) {
  # Need magrittr
  `%>%` <- dplyr::`%>%`

  # List quiz paths
  leanpub_quizzes = list.files(
    pattern = (".md"),
    ignore.case = TRUE,
    path = path,
    full.names = FALSE)

  if (length(leanpub_quizzes) < 1) {
    stop(paste0("No quiz .md files found in your specified path dir of: ", path))
  }

  for(quiz in leanpub_quizzes){

    # Print out which quiz we're converting
    message(paste("Converting quiz:", quiz))

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
    %>%
      # Now for updating based on type!
      dplyr::mutate(updated_line = dplyr::case_when(
        type == "prompt" ~ stringr::str_replace(quiz_lines, "^\\?", "prompt:"),
        grepl(type, "answer") ~ stringr::str_replace(quiz_lines, "^[[:alpha:]]\\)", "    - answer:"),
        TRUE ~ quiz_lines
      ))

    ###### Find extended prompts
    # Get the starts of prompts
    start_prompt_indices <- which(quiz_lines_df$type == "prompt")

    # Find the line which the footnote ends at
    end_prompt_indices <- sapply(start_prompt_indices,
                                 find_end_of_prompt,
                                 type_vector = quiz_lines_df$type)

    # Rename "other" as also part of prompts
    for (index in 1:length(start_prompt_indices)) {
      if (start_prompt_indices[index] != end_prompt_indices[index]) {
      quiz_lines_df$type[(start_prompt_indices[index] + 1):(end_prompt_indices[index] - 1)] <- "extended_prompt"
      }
    }

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


# Given an index of the start of a prompt, find the end of it.
# The end of the prompt is identified by finding the beginning of the answers
find_end_of_prompt <- function(start_prompt_index, type_vector) {

  # We want to see if the next line is where the answers start
  end_prompt_index <- start_prompt_index + 1

  # See if the end of the prompt is in the same line
  end_prompt <- grepl("answer", type_vector[end_prompt_index])

  # Keep looking in each next line until we find it.
  if (end_prompt == FALSE) {
    while (end_prompt == FALSE) {
      # Add one
      end_prompt_index <- end_prompt_index + 1

      # Look in next line
      end_prompt <- grepl("answer", type_vector[end_prompt_index])

      if (end_prompt_index == length(type_vector) && end_prompt == FALSE) {
        stop(paste("Searched end of file and could not find end of prompt that starts at line:", start_prompt_index))
      }
    }
  } else {
    end_prompt_index <- start_prompt_index
  }
  return(end_prompt_index - 1)
}
