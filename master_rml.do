**********************************************************
*name: master_rml.do
*author: Zach Fone (U.S. Air Force Academy)
*description: This file runs all the progrmas needed to 
*             i) clean and compile the data used in the analaysis,
*             and ii) create the tables and figures included in 
*             the draft.
**********************************************************
clear
global path "C:\Users\Zachary.Fone\Desktop\rml_disparities" //<----SET YOUR PATH HERE

**packages needed 
cap ssc install estout
cap ssc install statastates
cap ssc install coefplot
cap ssc install drdid 
cap ssc install csdid 
cap net install gtools >=  1.10.1, from("https://github.com/mcaceresb/stata-gtools/raw/master/build/")
cap net install ftools >= 2.49.1 , from ("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
cap net install reghdfe >= 6.12.3, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
cap net install ppmlhdfe >= 2.3.0, from("https://raw.githubusercontent.com/sergiocorreia/ppmlhdfe/master/src/")
cap net install synth_runner >= 1.6.0 , from("https://raw.github.com/bquistorff/synth_runner/master/")

********************************************************************************
*CLEANING/COMPILING DATA USED FOR ANALYSIS
********************************************************************************
**SEER data
do "$path\data\ucr\programs\SEER data for RML project.do" 

**UCR Data 
do "$path\data\ucr\programs\UCR data for RML project.do"
do "$path\data\ucr\programs\UCR data for RML project_agency-year.do"

**Covariates
do "$path\data\ucr\programs\Policy data for RML project.do"

**Combining into analysis data file
do "$path\data\ucr\programs\UCR Analysis data for RML project.do"
do "$path\data\ucr\programs\UCR Analysis data for RML project_agency-year.do" 
do "$path\data\ucr\programs\prepping data for CS in R.do"


********************************************************************************
*MAIN FIGURES
********************************************************************************
// Figure 1. Event-Study Analyses of RMLs and Marijuana Arrests, UCR
// Figure 2. Trends in Black and White Marijuana Arrests in Event time around Adoption Year
// Figure 3. Event-Study Analyses of RMLs and Non-Marijuana Drug Arrests, UCR
// Figure 4. Event-Study Analyses of RMLs and Property and Violent Crime Arrests, UCR
do "$path\analysis\ucr\programs\Figure 1.do"
do "$path\analysis\ucr\programs\Figure 2.do"
do "$path\analysis\ucr\programs\Figure 3.do"
do "$path\analysis\ucr\programs\Figure 4.do"


********************************************************************************
*MAIN TABLES
********************************************************************************
// Table 1. Estimated Effect of RML Adoption on Marijuana Arrests per 100,000 Persons
// Table 2. Exploring Heterogeneity in Effects of RML Adoption on Marijuana Possession vs Sales Arrests per 100,000 persons
// Table 3. Estimated Effects of RML Adoption on Non-Marijuana Drug Arrests per 100,000 persons
// Table 4. Estimated Effect of Recreational Marijuana Laws on Arrests for Part I Offenses per 100,000 persons
// Table 5. Exploration of Heterogeneity in the Effects of RMLs on Arrests per 100,000 persons by Whether a Recreational Dispensary is Allowed
do "$path\analysis\ucr\programs\Table 1.do"
do "$path\analysis\ucr\programs\Table 2.do"
do "$path\analysis\ucr\programs\Table 3.do"
do "$path\analysis\ucr\programs\Table 4.do"
do "$path\analysis\ucr\programs\Table 5.do"


********************************************************************************
*APPENDIX FIGURES
********************************************************************************
// Appendix Figure 1. Event-Study Analyses of RMLs and Marijuana Arrests, Using Callaway and Sant'Anna Estimates
// Appendix Figure 2. Synthetic Control Estimates, Marijuana Arrest Rate per 100,000 persons
// Appendix Figure 3. Event-Study Analyses of RMLs and Non-Marijuana Drug Arrests, Using Callaway and Sanr'Anna Estimates
// Appendix Figure 4. Event-Study Analyses of RMLs and Property and Violent Crime Arrests, Using Callaway and Sant'Anna Estimates
// Appendix Figure 5. Event Study Analysis of RML Adoption and Black Adult Arrests
* RUN THIS R FILE BEFORE .do FILES BELOW: "$path\analysis\ucr\programs\CS estimates.R"
do "$path\analysis\ucr\programs\Appendix Figure 1.do"
do "$path\analysis\ucr\programs\Appendix Figure 2.do"
do "$path\analysis\ucr\programs\Appendix Figure 3.do"
do "$path\analysis\ucr\programs\Appendix Figure 4.do"
do "$path\analysis\ucr\programs\Appendix Figure 5.do"


********************************************************************************
*APPENDIX TABLES
********************************************************************************
// Appendix Table 1. Descriptive Statistics
// Appendix Table 2. Recreational Marijuana Law Enactment Dates and Dates Recreational Sales of Marijuana Legalized, 2000-2019
// Appendix Table 3. Sensitivity of Arrest Estimates to Inclusion of State-Specific Linear Time Trends and Census Region-Year Fixed Effects
// Appendix Table 4. Callaway and Sant'Anna Estimates of Effect of RML Adoption on Black/White Marijuana Arrests, Non-Marijuana Drug Arrests and Part I Arrests 
// Appendix Table 5. Effect of Recreational Marijuana Laws on Drinking and Delinquency-Related Part II Arrests
// Appendix Table 6. Effect of Recreational Marijuana Laws on Black Adult Arrests
// Appendix Table 7. Sensitivity of Estimated Arrest Effects to UCR Data Quality Checks and Using Unweighted Estimates
// Appendix Table 8. Sensitivity of Estimated Drug Arrest Effects to Use of the Drug Arrest Ratio as the Dependent Variable
// Appendix Table 9. Robustness of Arrest Findings to Spillovers from Border State RMLs
// Appendix Table 10. Exploration of Heterogeneity in the Effects of RMLs on Arrests per 100,000 persons by Whether a Recreational Dispensary is Allowed, Callaway and Sant'Anna Estimates
do "$path\analysis\ucr\programs\Appendix Table 1.do"
do "$path\analysis\ucr\programs\Appendix Table 2.do"
do "$path\analysis\ucr\programs\Appendix Table 3.do"
do "$path\analysis\ucr\programs\Appendix Table 4.do"
do "$path\analysis\ucr\programs\Appendix Table 5.do"
do "$path\analysis\ucr\programs\Appendix Table 6.do"
do "$path\analysis\ucr\programs\Appendix Table 7.do"
do "$path\analysis\ucr\programs\Appendix Table 8.do"
do "$path\analysis\ucr\programs\Appendix Table 9.do"
do "$path\analysis\ucr\programs\Appendix Table 10.do"


********************************************************************************
*NVSS ANALYSIS
********************************************************************************
// Figure 5. Event-Study Analysis of RML Adoption and Deaths of Despair, NVSS 
// Table 6. Estimated Effect of RML Adoption on Deaths of Despair per 100,000 persons
// Appendix Figure 6. Event-Study Analyses of RML Adoption and Deaths of Despair, Using Callaway and Sant'Anna Estimates
// Appendix Table 11. Racial Disparities in the Effects of RMLs on Suicides and Drug-Related Mortality, by Race and Ethnicity, NVSS
// Appendix Table 12. TWFE Estimates of Effect of RMLs on Suicides and Drug-Related Mortality, by Race/Ethnicity and Age, NVSS
// Appendix Table 13. Sensitivity of Estimated Mortality Effects to State-Specific Linear Time Trends and Census Region-Specific Year Fixed Effects, NVSS
do "$path\analysis\nvss\Replication NVSS.do"


********************************************************************************
*BACK OF THE ENVELOPE CALCULATIONS
********************************************************************************
do "$path\analysis\ucr\BOE\boe calc.do"



