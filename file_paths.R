library(tidyverse)
library(fs)
library(here)

#set project root
project_root <- here::here()

#pilot 1 data
pilot_1_data_path <- 
  fs::path(project_root, "data", "prolific_may_20_summary.csv")

#pilot 2 data
pilot_2_data_path <- 
  fs::path(project_root, "data", "prolific_june_5_summary.csv")

#directory of all data
data_directory <- 
  fs::dir_ls(fs::path(project_root, "data"))

#directory of only prolific data
prolific_data_directory <- 
  fs::dir_ls(fs::path(project_root, "data", "prolific"))

#directory of only facebook data
facebook_data_directory <- 
  fs::dir_ls(fs::path(project_root, "data", "facebook"))

#directory of only fb wg data
fb_wg_directory <- 
  fs::dir_ls(fs::path(project_root, "data", "facebook", "wg"))

#directory of only fb ws data
fb_ws_directory <- 
  fs::dir_ls(fs::path(project_root, "data", "facebook", "ws"))

#functions that are useful for Web-CDI data processing
functions_script <- 
  fs::path(project_root, "analysis", "cdi_functions.R")

##All data

##All data WS1
all_data_ws1_path <- 
  fs::path(project_root, "data/full_dataset/webcdi_ws1.csv")

all_data_ws2_path <- 
  fs::path(project_root, "data/full_dataset/webcdi_ws2.csv")

all_data_wg_path <- 
  fs::path(project_root, "data/full_dataset/webcdi_wg.csv")