#################################################################
###### simulate characteristics of group for 1 experiment #######
#################################################################

rm(list = ls())

library(tidyverse)

# Simulate age of 500 participants (range: 18-99)
# store in an object called: age_vector

age_vector <- sample(18:99, 
                     size = 500, 
                     replace = TRUE)


# Randomly assign each individual to an experimental group
# store in an object called: random_assign
# experimental groups are called: "treatment" vs. "control"

condition <- c("control", "treatment")

random_assign <- sample(condition, 
                        size = 500, 
                        replace = TRUE)



# Put these two vectors into a dataset (tibble) 
# call this dataset: assignment_tibble

assignment_tibble <- tibble(age_vector, 
                            random_assign)

# Calculate mean for each experimental group 

assignment_tibble %>%
  group_by(random_assign) %>%
  summarise(mean = mean(age_vector))


#################################################################
### simulate characteristics of group for 100,000 experiments ###
#################################################################

# create container in which we will store each of the 100,000 average age of control
control_container <- rep(NA, 100000)

# create container in which we will store each of the 100,000 average age of treatment
treatment_container <- rep(NA, 100000)

# write for loop

for (i in 1:100000){
  
  age_vector <- sample(18:99, 
                       size = 500, 
                       replace = TRUE)
  
  random_assign <- sample(c("control", "treatment"), 
                          size = 500, 
                          replace = TRUE)
  
  control_container[i] <- mean(age_vector[random_assign == "control"])
  
  treatment_container[i] <- mean(age_vector[random_assign == "treatment"])
  
}

mean(control_container)

mean(treatment_container)
