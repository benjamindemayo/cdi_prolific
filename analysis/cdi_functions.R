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
    data %>% 
    mutateMultilingual %>% 
    filter(is.na(language_hours_per_week) | language_hours_per_week <= 16)
  return(filtered_data)
}

#Filter out kids with vision or hearing loss

filterVision <- function(data) {
  clean_data <- 
    data %>% 
    mutate(
      vision_exclude = case_when(
        vision_exclude == "1" ~ 1,
        TRUE ~ 0
      )
    ) %>% 
    filter(vision_exclude == 0)
  
  return(clean_data)
  
}


filterIllnesses <- function(data) {
  clean_data <- 
    data %>% 
    mutate(
      illnesses_exclude = case_when(
         illnesses_exclude == "1" ~ 1,
        TRUE ~ 0
      )
    ) %>% 
    filter(illnesses_exclude == 0)

  return(clean_data)
}

filterHearing <- function(data) {
  clean_data <- 
    data %>% 
    filter(
      hearing_loss_boolean != "1" | is.na(hearing_loss_boolean)
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

census_ethnicity_numbers <- 
  tibble(
    ethnicity = c("Asian", "Black", "Mixed/other", "White"),
    `U.S. Census Estimates` = c(.059, .134, .102, .763)
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
      ethnicity = case_when(
        str_length(child_ethnicity) > 1 ~ "mixed",
        child_ethnicity != "A" & child_ethnicity != "B" & child_ethnicity != "W" ~ "other" ,
        is.na(child_ethnicity) ~ "no_report",
        TRUE ~ child_ethnicity
      ) %>% 
      fct_recode(
        Asian = "A",
        Black = "B",
        `Mixed/other` = "mixed",
        White = "W",
        `Mixed/other` = "other",
        `No ethnicity reported` = "no_report"
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
        #primary_caregiver_other == "Pre Form Filler Field" & 
          #mother_education == 0 ~ "Not reported",
        mother_education <= 11 ~ "Some high school or less",
        mother_education == 12 ~ "High school diploma",
        mother_education %in% seq.int(13, 15) ~ 
          "Some college education",
        mother_education >= 16 ~ "College diploma or more",
        is.na(mother_education) ~ "Not reported"
      )
    ) %>% 
    mutate(
      maternal_ed = fct_relevel(
        maternal_ed,
       "College diploma or more",
       "Some college education",
       "High school diploma",
       "Some high school or less",
       "Not reported"
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

census_momed_numbers <- 
  tibble(
    maternal_ed = c(
      "Some high school or less",
      "High school diploma",
      "Some college education",
      "College diploma or more"
    ),
    `U.S. Census Estimates` = c(.120, .271, .289, .320)
  )

get_narrative_responses <- function(data) {
  nar_responses <- 
    data %>% 
    select(
      subject_id,
      study_name,
      ear_infections,
      hearing_loss,
      vision_problems,
      illnesses,
      services,
      worried,
      learning_disability
    ) %>% 
    rowwise() %>% 
    mutate(
      all_na = all(is.na(c_across(!c(subject_id, study_name))))
    ) %>% 
    filter(!all_na)
  
  return(nar_responses)
}

filter_age_ws <- function(data) {
  clean_data <- 
    data %>% 
    filter(age >= 16 & age <= 30)
  return(clean_data)
} 

filter_age_wg <- function(data) {
  clean_data <- 
    data %>% 
    filter(age >= 8 & age <= 18)
  return(clean_data)
}

