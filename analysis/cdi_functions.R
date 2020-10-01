library(tidyverse)
library(here)
library(fs)

#accepts: path to directory of CDI data, either all WS or WG
#returns: df of CDI data from every file in the directory
readInWebCDI <- function(directory) {
  clean_data <- 
    directory %>% 
    map_df(~read_csv(., col_types = cols(.default = col_character()))) %>% #read in columns as a character
    mutate_at(
      .funs = ~case_when(
        str_detect(., "<") ~ 1, #get rid of entries that have 'less than' signs in them
        TRUE ~ as.numeric(.)
      ),
      .vars = vars(contains("Percentile"))
    ) %>% 
    mutate_at(
      .funs = ~as.numeric(.), #turn all the quantitative columns back into numeric
      .vars = 
        vars(
          which(colnames(.) == "benchmark age"):ncol(.), 
          contains("mother"), 
          contains("father"),
          contains("age")
        )
    ) 
  return(clean_data)
}

#accepts: df of CDI data
#returns: df of CDI data filtering out kids who don't meet birthweight or prematurity criteria
mutateBirthweight <- function(data) {
  clean_data <- 
    data %>% 
    mutate_at(
      .vars = c("due_date_diff", "birth_weight_lb", "birth_weight_kg"),
      .funs = ~as.numeric(.)
    ) %>% 
    mutate_at(
      .vars = c("due_date_diff"),
      .funs = ~case_when(
        is.na(.) ~ 0, #turn non-NA's in this column into zeros
        TRUE ~ .
      )
    ) %>% 
    mutate(premature = case_when(
      due_date_diff >= 4 & birth_weight_lb < 5.5 ~ TRUE,
      due_date_diff >= 4 & birth_weight_kg < 2.5 ~ TRUE,
      TRUE ~ FALSE
    ))
  return(clean_data)
}

filterBirthweight <- function(data) {
  filtered_data <- 
    data %>% 
    mutateBirthweight() %>% 
    filter(premature == FALSE)
  return(filtered_data)
}

#Filter out kids in multilingual environments
mutateMultilingual <- function(data) {
  clean_data <- 
    data %>% 
    mutate_at(
      .vars = c("language_days_per_week", "language_hours_per_day"),
      .funs = ~as.numeric(.)
    ) %>% 
    mutate(
      language_hours_per_week = language_days_per_week * language_hours_per_day
    )
  return(clean_data)
}

filterMultilingual <- function(data) {
  filtered_data <- 
    mutateMultilingual %>% 
    filter(is.na(language_hours_per_week) | language_hours_per_week <= 16)
  return(filtered_data)
}

#Filter out kids with vision or hearing loss

filterVision <- function(data) {
  clean_data <- 
    data %>% 
    filter(
      vision_exclude == 1 | is.na(vision_problems_boolean)
    )
  
  return(clean_data)
}

filterIllnesses <- function(data) {
  clean_data <- 
    data %>% 
    filter(illnesses_exclude != 1)
  
  return(clean_data)
}

filterHearing <- function(data) {
  clean_data <- 
    data %>% 
    filter(
      hearing_loss_boolean == "1" | is.na(hearing_loss_boolean)
    )
}

#Append a column with the completion interval on it
getCompletionInterval <- function(data) {
  clean_data <- 
    data %>% 
    mutate(
      completion_interval = lubridate::interval(created_date, last_modified),
      completion_time = completion_interval / lubridate::minutes()
    )
  
  return(clean_data)
}

#Ethnicity numbers from Fenson et al (2007)
old_ethnicity_numbers <- 
  tibble(
    ethnicity = c("Asian", "Black", "Mixed/other", "White"),
    `2007 manual` = c(.069, .105, .063, .733)
  )

#Add a boolean column for each ethnicity, 
#and mutate the ethnicity column into desired categories
getEthnicities <- function(data) {
  clean_data <- 
    data %>% 
    mutate( #get rid of brackets in ethnicity column
      child_ethnicity = str_replace_all(child_ethnicity, "[^[:upper:]]", "")
    ) %>% 
    mutate(
      ethnicity_white = str_detect(child_ethnicity, "W"),
      ethnicity_black = str_detect(child_ethnicity, "B"),
      ethnicity_asian = str_detect(child_ethnicity, "A"),
      ethnicity_native = str_detect(child_ethnicity, "N"),
      ethnicity_other = str_detect(child_ethnicity, "O"),
      ethnicity_mixed = str_length(child_ethnicity) > 1
    )
  clean_data <- 
    clean_data %>% 
    mutate( #get rid of brackets in ethnicity column
      child_ethnicity = str_replace_all(child_ethnicity, "[^[:upper:]]", "")
    ) %>%
    mutate(
      ethnicity = case_when(
        str_length(child_ethnicity) > 1 ~ "mixed",
        child_ethnicity != "A" & child_ethnicity != "B" & child_ethnicity != "W" ~ "other" ,
        TRUE ~ child_ethnicity
      ) %>% fct_recode(
        Asian = "A",
        Black = "B",
        `Mixed/other` = "mixed",
        White = "W",
        `Mixed/other` = "other"
      )
    ) 
  return(clean_data)
}

#Get an ethnicity cummary table
getEthnicitySummary <- function(data) {
  data %>% 
    count(ethnicity)
}

#Change the maternal education column into desired bins
getMaternalEd <- function(data) {
  clean_data <- 
    data %>% 
    mutate(
      maternal_ed = case_when(
        mother_education <= 11 ~ "Some high school or less",
        mother_education == 12 ~ "High school diploma",
        mother_education %in% seq.int(13, 15) ~ 
          "Some college education",
        mother_education >= 16 ~ "College diploma or more"
      )
    ) %>% 
    mutate(
      maternal_ed = fct_relevel(
        maternal_ed,
        "Some high school or less",
        "High school diploma",
        "Some college education",
        "College diploma or more"
      )
    )
}

old_momed_numbers <- 
  tibble(
    maternal_ed = c(
      "Some high school or less",
      "High school diploma",
      "Some college education",
      "College diploma or more"
    ),
    `2007 manual` = c(.075, .2385, .248, .4385)
  )

