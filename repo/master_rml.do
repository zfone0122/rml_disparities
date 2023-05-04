**********************************************************
*name: master_rml.do
*author: Zach Fone (U.S. Air Force Academy)
*description: This file runs all the progrmas needed to 
*             i) clean and compile the data used in the analaysis,
*             and ii) create the tables and figures included in 
*             the draft.
**********************************************************
clear
global path "C:\Users\Zachary.Fone\Dropbox\RESEARCH\RML project\empirical"

/* commands to install 

ssc install synth, replace all
net install synth_runner, from(https://raw.github.com/bquistorff/synth_runner/master/) replace

*/

********************************************************************************
*CLEANING/COMPILING DATA USED FOR ANALYSIS
********************************************************************************
**SEER data
do "$path\source_data\programs\SEER data for RML project.do" 

**UCR Data 
do "$path\source_data\programs\UCR data for RML project.do"
do "$path\source_data\programs\UCR data for RML project_agency-year.do"

**Covariates
do "$path\source_data\programs\Policy data for RML project.do"

**Combining into analysis data file
do "$path\source_data\programs\UCR Analysis data for RML project.do"
do "$path\source_data\programs\UCR Analysis data for RML project_agency-year.do" 
do "$path\source_data\programs\prepping data for CS in R.do"


********************************************************************************
*MAIN FIGURES
********************************************************************************
do "$path\analysis\programs\Figure 1.do"
do "$path\analysis\programs\Figure 3.do"
*  "$path\analysis\programs\Figures 1-3_CS.R"  //<-need to run this in R
do "$path\analysis\programs\Figures 1-3_CS_clean R output.do"


********************************************************************************
*MAIN TABLES
********************************************************************************
do "$path\analysis\programs\Table 1.do"
do "$path\analysis\programs\Table 2.do"
do "$path\analysis\programs\Table 3.do"
do "$path\analysis\programs\Table 4.do"
do "$path\analysis\programs\Table 5.do"
do "$path\analysis\programs\Table 6.do"
do "$path\analysis\programs\Table 7.do"
do "$path\analysis\programs\Table 8.do"


********************************************************************************
*APPENDIX FIGURES
********************************************************************************
do "$path\analysis\programs\Appendix Figure 1.do"


********************************************************************************
*APPENDIX TABLES
********************************************************************************
do "$path\analysis\programs\Appendix Table 1.do"
do "$path\analysis\programs\Appendix Table 2.do"
do "$path\analysis\programs\Appendix Table 3.do"
do "$path\analysis\programs\Appendix Table 4.do"
do "$path\analysis\programs\Appendix Table 5.do"


********************************************************************************
*FOOTNOTES
********************************************************************************
do "$path\analysis\footnotes\Lag between MML-RML and RML-RML Sales.do"


********************************************************************************
*BACK OF THE ENVELOPE CALCULATIONS
********************************************************************************
do "$path\analysis\BOE\BOE CALC.do"


