**********************************************************
*name: Policy data for RML project.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Cleaning the policy data and covariates to 
*             be used for the RML project
**********************************************************
clear all

******
**# Clean data
******
import delimited using "$path\source_data\data\policy\RML_Control.csv", varnames(1)

***
*RML/MML file 
***
preserve 
keep year state_fips state rml mml mml_tag mml_year
save "$path\source_data\data\policy\rml-mml_2000-2019.dta", replace
restore 

***
*Coviariates file 
***
drop rml mml mml_tag mml_year
save "$path\source_data\data\policy\covariates_2000-2019.dta", replace

***
*Event study coding 
*** 
use "$path\source_data\data\policy\rml-mml_2000-2019.dta", clear 

keep year state_fips state rml 

xtset state_fips year 
bysort state_fips: gen rml_1=d1.rml //first difference of policy variable to create events

foreach v in rml_1 {
forval f = 5(-1)1 { //leads
sort state_fips year
gen F`f'_`v' = F`f'.`v'
gsort state_fips -year
if `f' == 5 bys state_fips: gen sum_F`f'_`v' = sum(F`f'_`v')
}

forval l = 0/3  { //lags
sort state_fips year
qui gen L`l'_`v' = L`l'.`v'
if `l' == 3 bys state_fips: gen sum_L`l'_`v' = sum(L`l'_`v')
}

replace F5_`v' = sum_F5_`v' if F5_`v' != .
replace L3_`v' = sum_L3_`v' if L3_`v' != .

drop sum_*_`v' 
} 
*replace missing values
foreach v in rml_1 {
forval f = 5(-1)1 { //leads
replace F`f'_`v' = 0 if F`f'_`v'==.
} //f

forval l = 0/3  { //lags
replace L`l'_`v' = 0 if L`l'_`v'==.
} //l
}
drop rml_1 
ren (F*_1 L*_1) (F* L*)

*label the event variables for graphing purposes
label var F5_rml "-5+"
label var F4_rml "-4"
label var F3_rml "-3"
label var F2_rml "-2"
label var F1_rml "-1"
label var L0_rml "0"
label var L1_rml "1"
label var L2_rml "2"
label var L3_rml "3+"

*normalize first lead to zero (reference period)
replace F1_rml=0

*save 
save "$path\source_data\data\policy\rml events_2000-2019.dta", replace  


******
**# RML Sales
******
/* Data documentation:

From Table 1 in:
	"Public Health Effects of Marijuana Legalization" - Anderson and Rees (2023)

*/
clear
import excel using "$path\source_data\data\policy\rml_mml_sales.xlsx", firstrow

label var mml_date "MML effective date"
label var rml_date "RML effective date"
label var rml_sales "date when recreational sales began"
ren rml_sales rml_sales_date
label var mml_note "note regarding MML effective date"

replace state_name="District of Columbia" if state_name=="D. C."
statastates, name(state_name)
gen no_mml_rml=_merge==2
drop _merge state_abbrev 
ren state_fips fips 
order fips, after(state_name)

**state-day file (to collapse to state-month and state-year)
gen date=td(01jan1996)
format date %td
expand 2
replace date=td(31dec2020) in 52/102
tsset fips date
tsfill, full

foreach i in state_name mml_note {
	
	egen temp=mode(`i'), by(fips)
	replace `i'=temp if `i'==""
	drop temp 
	
}
foreach i in no_mml_rml mml_date rml_date rml_sales_date {
	
	egen temp=mode(`i'), by(fips)
	replace `i'=temp if `i'==.
	drop temp 
	
}

order date, after(fips)
order mml_note, after(no_mml_rml)

gen mml=date>=mml_date 
order mml, after(mml_date)

gen rml=date>=rml_date 
order rml, after(rml_date)

gen rml_sales=date>=rml_sales_date 
order rml_sales, after(rml_sales_date)

gen rml_no_sales=rml 
replace rml_no_sales=0 if rml_sales==1
order rml_no_sales, before(rml_sales)

**collapse to state-month 
gen year=year(date)
gen month=month(date)
gen ym=mofd(date)
format ym %tm 
order year month ym, after(date)

rename mml_note note
replace note="" if note=="Date on which first medical marijuana dispensary opened."

collapse (mean) rml rml_no_sales rml_sales, by(fips state_name year month ym rml_date rml_sales_date no_mml_rml note)

order rml rml_no_sales rml_sales, after(rml_sales_date)

keep if inrange(year, 2000, 2019)

*save 
save "$path\source_data\data\policy\rml-sales_year-month_2000-2019.dta", replace 

**collapse to state-year 
collapse (mean) rml rml_no_sales rml_sales, by(fips state_name year rml_date rml_sales_date no_mml_rml note)

order rml rml_no_sales rml_sales, after(rml_sales_date)

*save 
save "$path\source_data\data\policy\rml-sales_year_2000-2019.dta", replace 

***
*Event study coding 
*** 
use "$path\source_data\data\policy\rml-sales_year_2000-2019.dta", clear 

keep year fips state rml_sales 

xtset fips year 
bysort fips: gen rml_sales_1=d1.rml_sales //first difference of policy variable to create events

foreach v in rml_sales_1 {
forval f = 5(-1)1 { //leads
sort fips year
gen F`f'_`v' = F`f'.`v'
gsort fips -year
if `f' == 5 bys fips: gen sum_F`f'_`v' = sum(F`f'_`v')
}

forval l = 0/3  { //lags
sort fips year
qui gen L`l'_`v' = L`l'.`v'
if `l' == 3 bys fips: gen sum_L`l'_`v' = sum(L`l'_`v')
}

replace F5_`v' = sum_F5_`v' if F5_`v' != .
replace L3_`v' = sum_L3_`v' if L3_`v' != .

drop sum_*_`v' 
} 
*replace missing values
foreach v in rml_sales_1 {
forval f = 5(-1)1 { //leads
replace F`f'_`v' = 0 if F`f'_`v'==.
} //f

forval l = 0/3  { //lags
replace L`l'_`v' = 0 if L`l'_`v'==.
} //l
}
drop rml_sales_1 
ren (F*_1 L*_1) (F* L*)

*label the event variables for graphing purposes
label var F5_rml_sales "-5+"
label var F4_rml_sales "-4"
label var F3_rml_sales "-3"
label var F2_rml_sales "-2"
label var F1_rml_sales "-1"
label var L0_rml_sales "0"
label var L1_rml_sales "1"
label var L2_rml_sales "2"
label var L3_rml_sales "3+"

*normalize first lead to zero (reference period)
replace F1_rml_sales=0

*save 
save "$path\source_data\data\policy\rml sales events_2000-2019.dta", replace



clear 


