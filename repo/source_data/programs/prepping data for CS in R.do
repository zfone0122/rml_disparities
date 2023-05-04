**********************************************************
*name: prepping data for CS in R.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Data to load into R for CS analysis
**********************************************************
clear all 

use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta" 

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

gen t1=year-1999

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.

label var rml "RML"

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

gen race2="all"
replace race2="black" if race==2 
replace race2="white" if race==3

drop if race==1

drop agg_assault_1899-violent_1899 mml_tag-L3_rml t1

gen temp=year if rml>0 & rml!=.
egen g_rml=min(temp), by(fips)
replace g_rml=0 if g_rml==.
drop temp 

gen one=1
egen n=sum(one), by(fips race)
gen bpanel=n==20
drop one n

ren (rate_property_1899 rate_violent_1899) (rate_total_property_1899 rate_total_violent_1899)

preserve 

keep if race2=="black"
saveold "$path\source_data\data\analysis_files\rml_black.dta", replace

restore 

keep if race2=="white"
saveold "$path\source_data\data\analysis_files\rml_white.dta", replace
