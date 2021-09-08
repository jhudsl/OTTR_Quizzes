# Need here and R.utils
# For testing use quiz_lines  <- readLines(here::here("quizzes", "quiz_ch1.md"))

# This is functionalized but running like script for now till we decide where to put this:
# run by  pasting `Rscript scripts/coursera_quiz_conversion.R` in the terminal


find_end_of_prompt <- function(start_prompt_index, type_vector) {
  # Given an index of the start of a prompt, find the end of it. The end of the prompt is identified by finding the beginning of the answers
  # Given a vector of what type of line something is, look for the end of the prompt for a given index
  #
  # Args:
  #   start_prompt_index: a single index to start the search at (the beginning of the prompt)
  #   type_vector: A vector indicating the type of line -- will look for "answer" to indicate that the prompt has ended.
  #
  # Returns:
  #   The index of the end of the prompt

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
  return(end_prompt_index)
}

convert_quiz <- function(quiz_path, output_dir, verbose = TRUE) {
  # Make a leanpub formatted md file quiz into a coursera yaml file quiz
  #
  # Args:
  #   quiz_path: a path to a quiz .md file
  #   output_dir: an existing folder where you would like the new version of the quiz to be saved
  #   verbose: would you like the progress messages?
  #
  # Returns:
  #   a coursera ready quiz saved to the output directory specified

  # Print out which quiz we're converting
  message(paste("Converting quiz:", quiz))

  ### First read lines for each quiz
  # Put it as a data.frame:
  quiz_lines_df <- data.frame(quiz_lines = readLines(file.path(path, quiz))) %>%
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
    dplyr::filter(!(type %in% c("empty", "tag")))

  ###### Find extended prompts
  # Get the starts of prompts
  start_prompt_indices <- which(quiz_lines_df$type == "prompt")

  # Find the line which the footnote ends at
  end_prompt_indices <- sapply(start_prompt_indices,
    find_end_of_prompt,
    type_vector = quiz_lines_df$type
  )

  # Rename "other" as also part of prompts
  for (index in 1:length(start_prompt_indices)) {
    if (start_prompt_indices[index] != end_prompt_indices[index]) {
      quiz_lines_df$type[(start_prompt_indices[index] + 1):(end_prompt_indices[index] - 1)] <- "extended_prompt"
    }
  }

  quiz_lines_df <- quiz_lines_df %>%
    # Now for updating based on type!
    dplyr::mutate(updated_line = dplyr::case_when(
      type == "prompt" ~ stringr::str_replace(quiz_lines, "^\\?", "prompt:"),
      type == "extended_prompt" ~ paste0("    ", quiz_lines),
      grepl("answer", type) ~ stringr::str_replace(quiz_lines, "^[[:alpha:]]\\)", "    - answer:"),
      TRUE ~ quiz_lines
    ))

  # Turn updated lines into a named vector
  updated_quiz_lines <- quiz_lines_df$updated_line
  names(updated_quiz_lines) <- quiz_lines_df$type


  ### Add "  options:" before beginning of answer options
  updated_quiz_lines <- R.utils::insert(updated_quiz_lines, ats = end_prompt_indices + 1, values = "  options:")

  ### Add specs for coursera
  # Add typeName before prompt starts:
  updated_quiz_lines <- R.utils::insert(updated_quiz_lines,
    ats = which(names(updated_quiz_lines) == "prompt") - 1,
    values = "- typeName: multipleChoice"
  )

  # Add shuffleoptions: true after prompt ends
  updated_quiz_lines <- R.utils::insert(updated_quiz_lines,
    ats = which(names(updated_quiz_lines) == "prompt") + 1,
    values = "  shuffleOptions: true"
  )

  # Need to add "isCorrect: true" one line below correct value lines
  updated_quiz_lines <- R.utils::insert(updated_quiz_lines,
    ats = which(names(updated_quiz_lines) == "correct_answer"),
    values = "      isCorrect: true"
  )
  # Need to add "isCorrect: false" one line below incorrect value lines
  updated_quiz_lines <- R.utils::insert(updated_quiz_lines,
    ats = which(names(updated_quiz_lines) == "wrong_answer"),
    values = "      isCorrect: false"
  )

  ### Write new file with .yml at end of file name and put in coursera dir
  writeLines(updated_quiz_lines, con = file.path(output_dir, paste0(quiz, ".yml")))

  # Put message
  message(paste("Converted quiz saved to:", file.path(output_dir, paste0(quiz, ".yml"))))
}

convert_coursera_quizzes <- function(quiz_path = "quizzes",
                                     output_dir = "coursera_quizzes",
                                     verbose = TRUE) {

  # Given a directory of Leanpub quiz md files, convert all quizzes to Coursera compatible quizzes
  # by passing them to `convert_quiz`.
  #
  # Args:
  #   quiz_path: a path to a directory of leanpub formatted quiz md files
  #   output_dir: a folder (existing or not) that the new coursera converted quizzes should be saved to.
  #   verbose: would you like the progress messages?
  #
  # Returns:
  #   a coursera ready quiz saved to the output directory specified

  # Need magrittr
  `%>%` <- dplyr::`%>%`

  # Create directory if it is not yet created
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # List quiz paths
  leanpub_quizzes <- list.files(
    pattern = (".md"),
    ignore.case = TRUE,
    path = path,
    full.names = FALSE
  )

  if (length(leanpub_quizzes) < 1) {
    stop(paste0("No quiz .md files found in your specified path dir of: ", path))
  }

  # Run the thing!
  lapply(leanpub_quizzes,
         convert_quiz,
         verbose = verbose,
         output_dir = output_dir)
}
