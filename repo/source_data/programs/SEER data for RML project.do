**********************************************************
*name: SEER data for RML project.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Cleaning population data (SEER) for RML 
*             project
**********************************************************
clear all

*****
*Import Raw Data 
*****
*Download data from: https://seer.cancer.gov/popdata/download.html
*Under: County-Level Population Files - Single-year Age Groups
     *: 1969-2020, White, Black, Other
*Data dictionary: https://seer.cancer.gov/popdata/popdic.html
infix year 1-4 str state 5-6 stfips 7-8 countyfips 9-11 registry 12-13 race 14 origin 15 sex 16 age 17-18 population 19-26 using "$path\source_data\data\seer\raw\us.1969_2020.singleages.adjusted.txt"

compress

*****
*Data cleaning 
*****
/* Data needed:

Panel:
	State-level 
	2000-2019
	
	County-level
	2000-2019

Demographic groups: 
	18+ (all, black, and white)

*/
***
*state 
***
preserve

keep if inrange(year, 2000, 2019)

gen pop_1899_all=population if inrange(age, 18, 99)
gen pop_1899_black=population if inrange(age, 18, 99) & race==2
gen pop_1899_white=population if inrange(age, 18, 99) & race==1

gcollapse (sum) pop_*, by(stfips year)
ren stfips fips 
keep if inrange(fips, 1, 56)

*save 
save "$path\source_data\data\seer\cleaned\seer_state-year_2000-2019_cleaned.dta", replace 

restore 


***
*county 
***
keep if inrange(year, 2000, 2019)

gen totalpop=population
gen pop_1899_all=population if inrange(age, 18, 99)
gen pop_1899_black=population if inrange(age, 18, 99) & race==2
gen pop_1899_white=population if inrange(age, 18, 99) & race==1

gcollapse (sum) totalpop pop_*, by(stfips countyfips year)
ren (stfips countyfips) (fips county)
keep if inrange(fips, 1, 56)

gen popshare_1899_all=(pop_1899_all/totalpop)
gen popshare_1899_black=(pop_1899_black/totalpop)
gen popshare_1899_white=(pop_1899_white/totalpop)

*save 
save "$path\source_data\data\seer\cleaned\seer_county-year_2000-2019_cleaned.dta", replace 



clear 


