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
  fs::path(project_root, "data/full_dataset/raw/webcdi_ws1_screened.csv")

all_data_ws2_path <- 
  fs::path(project_root, "data/full_dataset/raw/webcdi_ws2_screened.csv")

all_data_wg_path <- 
  fs::path(project_root, "data/full_dataset/raw/webcdi_wg_screened.csv")

##Unfiltered data
wg_unfiltered_path <- 
  fs::path(
    project_root, 
    "data", 
    "full_dataset", 
    "unfiltered", 
    "wg_unfiltered.RData"
  )

ws_unfiltered_path <- 
  fs::path(
    project_root, 
    "data", 
    "full_dataset", 
    "unfiltered", 
    "ws_unfiltered.RData"
  )

wg_filtered_path <- 
  fs::path(
    project_root, 
    "data", 
    "full_dataset", 
    "filtered", 
    "wg_filtered.RData"
  )

##Filtered data
ws_filtered_path <- 
  fs::path(
    project_root, 
    "data", 
    "full_dataset", 
    "filtered", 
    "ws_filtered.RData"
  )

##SES data - unfiltered

wg_unfiltered_ses_path <- 
  fs::path(
    project_root, 
    "data", 
    "ses_norming", 
    "unfiltered", 
    "wg_unfiltered_ses.RData"
  )

ws_unfiltered_ses_path <- 
  fs::path(
    project_root, 
    "data", 
    "ses_norming", 
    "unfiltered", 
    "ws_unfiltered_ses.RData"
  )

##SES data - filtered

wg_filtered_ses_path <- 
  fs::path(
    project_root, 
    "data", 
    "ses_norming", 
    "filtered", 
    "wg_filtered_ses.RData"
  )

ws_filtered_ses_path <- 
  fs::path(
    project_root, 
    "data", 
    "ses_norming", 
    "filtered", 
    "ws_filtered_ses.RData"
  )

##figures

fig_directory <- 
  fs::path(
    project_root,
    "paper",
    "figs"
  )

##exclusion tables

full_sample_exclusions <- 
  fs::path(
    project_root,
    "data",
    "exclusion_tables",
    "full_sample_norming_exclusions",
    ext = "RData"
  )

ses_sample_exclusions <- 
  fs::path(
    project_root,
    "data",
    "exclusion_tables",
    "ses_norming_exclusions",
    ext = "RData"
  )

wg_cutoffs_path <- 
  fs::path(
    project_root, 
    "data", 
    "cutoffs", 
    "wg_cutoffs.RData"
  )

ws_cutoffs_path <- 
  fs::path(
    project_root, 
    "data", 
    "cutoffs", 
    "ws_cutoffs.RData"
  )

