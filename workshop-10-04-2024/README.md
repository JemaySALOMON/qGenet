
Description of the files :

-phenomicSelection_Workshop.pdf : The slides for the presentation

- GenotypicData_subset.csv : the genotyping file (224 varieties, 10533 SNP)
- NIRS_Dry.Rds :  The NIRS file: NIRS measured on the grains in the reference environment
- Adjmeans_Final.csv : The adjusted means for grain yield in each environment (224 varieties, 
			8 environments: 1 with NIRS = the reference environment, and 7 without NIRS)

- phenomicSelection_Workshop.Rmd: The Rmd file containing the scripts for phenomicSelection_Workshop along with a description.
- phenomicSelection_Workshop.html: The output of phenomicSelection_Workshop.Rmd.

- lmm.Rmd: The Rmd file containing the scripts for simulating and estimating parameters from linear mixed models.
- lmm.html: The output of lmm.Rmd.

- Utils.R: This file contains utility functions used in the Rmd



- IMPORTANT!!!!!

Logiciels to install :

1) [R](https://www.r-project.org/) (version $\geq$ 3)
2) [RStudio](https://www.rstudio.com/products/rstudio/) (version $\geq$ 1)




Packages to install : "knitr", "prospectr", "signal", "rrBLUP", "MM4LMM", "lme4", "rmarkdown"

Install via command R/Rstudio
command R/RStudio : Eg. for lme4 : install.packages("lme4")
									install.packages("rrBLUP")
									.....



-> Install via loop in R/Rstudio If it does not work, use the method above

1) packages <- c("knitr", "prospectr", "signal", "rrBLUP", "MM4LMM", "rmarkdown", "lme4")

# Installer packages s'ils ne sont pas déjà installés
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
  suppressPackageStartupMessages(library(package, character.only = TRUE))
}