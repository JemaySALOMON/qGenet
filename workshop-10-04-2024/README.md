# Overview

## workshop 10/04/2024

This workshop is intended to be taught in two parts:

   a) Linear Mixed Model  
   b)  Phenomic Selection

## Agenda for the Workshop

Lecture 1 : Linear Mixed Models  
Lecture 2 : Phenomic Selection  
TD1       : Linear Mixed Models  
TD2       : Phenomic-genomic Selection  

The data and slides for the Phenomic Selection Workshop are sourced from the "atelier-prediction-genomique" repository, available at: https://github.com/JemaySALOMON/atelier-prediction-genomique. All contents within this repository are licensed under the Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0). Consequently, this license extends to all works associated with this workshop. Please review for compliance


# Description of the files :

* phenomicSelection_Workshop.pdf : The slides for the lectures 1 & 2
* GenotypicData_subset.csv : the genotyping file (224 varieties, 10533 SNP)

* NIRS_Dry.Rds :  The NIRS file: NIRS measured on the grains in the reference environment

* Adjmeans_Final.csv : The adjusted means for grain yield in each environment (224 varieties, 
			8 environments: 1 with NIRS = the reference environment, and 7 without NIRS)

* phenomicSelection_Workshop.Rmd: The Rmd file containing the scripts for phenomicSelection_Workshop along with a description.

* phenomicSelection_Workshop.html: The output of phenomicSelection_Workshop.Rmd.

* lmm.Rmd: The Rmd file containing the scripts for simulating and estimating parameters from linear mixed models.

* lmm.html: The output of lmm.Rmd.

* Utils.R: This file contains utility functions used in the two Rmds

NB :  Please be aware that the Rmd and html files are in French.



# IMPORTANT

## Logiciels to install :

1) [R](https://www.r-project.org/) (version $\geq$ 3)
2) [RStudio](https://www.rstudio.com/products/rstudio/) (version $\geq$ 1)




## Packages to install : 

- knitr
- prospectr
- signal
- rrBLUP
- MM4LMM
- lme4
- rmarkdown

* Install via command R/Rstudio :

command R/RStudio :  install.packages()  

1) install.packages("knitr") for knitr   
2) install.packages("prospectr") for prospectr  
3) .... do the same for the other packages   


* Install via loop in R/Rstudio If it does not work, use the method above (Install via command R/Rstudio)  

```{r}
## check if these packages are not already installed
## if not, install them
packages <- c("knitr", "prospectr", "signal", "rrBLUP", "MM4LMM", "rmarkdown", "lme4")  
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}
```