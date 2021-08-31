# cdi_prolific
Data and analytic code for article introducing Web-CDI and analyzing the full dataset and more recent work using Facebook and Prolific to recruit.

*To reproduce the final paper:*
- open cdi_prolific.Rroj
- in "Files" pane, select `paper` > `webcdi_paper.Rmd` and knit (note that installation of a LaTeX engine is necessary beforehand). 

*Data and figure preparation:*
- Dataset 1 (and accompanying exclusion table) in the paper is prepped in `analysis` > `full_dataset_analysis` > `full_dataset_prep.Rmd`
- Dataset 2 (and accompanying exclusion table) in the paper is prepped in `analysis` > `all_norming_analysis.Rmd`
- Figures were workshopped in the above two files but chunk settings for figure workshopping are set to `eval = FALSE`; all figures are generated independently in `webcdi_paper.Rmd`

Edit on 8/31/2021: couple of entries were taken out of the dataset post-publication (2 out of about ~3500).
