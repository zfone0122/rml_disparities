**********************************************************
*name: prepping data for CS in R.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Data to load into R for CS analysis
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear 

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

gen temp=year if rml>0 & rml!=.
egen g_rml=min(temp), by(fips)
replace g_rml=0 if g_rml==.
drop temp 

ren (rate_property_1899 rate_violent_1899) (rate_total_property_1899 rate_total_violent_1899)

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

preserve 
keep if race==2
tempfile black
save `black'
saveold "$path\data\ucr\data\analysis_files\rml_black.dta", replace
restore
keep if race==3
tempfile white
save `white'
saveold "$path\data\ucr\data\analysis_files\rml_white.dta", replace


**********
*Sales/No Sales
**********
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear 

**merge in rml-sales 
merge m:1 fips year using "$path\data\ucr\data\policy\rml-sales_year_2000-2019", keepusing(rml_sales rml_no_sales)
drop if _merge==2
drop _merge 

gen temp=year if rml_no_sales>0 & rml!=.
egen g_rml_no_sales=min(temp), by(fips)
replace g_rml_no_sales=0 if g_rml_no_sales==.
drop temp 

gen temp=year if rml_sales>0 & rml!=.
egen g_rml_sales=min(temp), by(fips)
replace g_rml_sales=0 if g_rml_sales==.
drop temp 

gen same=g_rml_sales==g_rml_no_sales & g_rml_no_sales!=0

gen sales_samp=1
replace sales_samp=0 if inrange(year, g_rml_no_sales, g_rml_sales-1) & g_rml_sales!=0

gen nosales_samp=1 
replace nosales_samp=0 if year>=g_rml_sales & g_rml_no_sales!=0

ren (rate_property_1899 rate_violent_1899) (rate_total_property_1899 rate_total_violent_1899)

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

**no sales data 
preserve 
keep if race==2
drop if g_rml_sales!=0
tempfile black
save `black'
saveold "$path\data\ucr\data\analysis_files\rml_black_nosales.dta", replace
restore
preserve
keep if race==3
drop if g_rml_sales!=0
tempfile white
save `white'
saveold "$path\data\ucr\data\analysis_files\rml_white_nosales.dta", replace
restore
**with sales data
preserve 
keep if race==2
drop if g_rml_no_sales!=0 & g_rml_sales==0
tempfile black
save `black'
saveold "$path\data\ucr\data\analysis_files\rml_black_sales.dta", replace
restore
keep if race==3
drop if g_rml_no_sales!=0 & g_rml_sales==0
tempfile white
save `white'
saveold "$path\data\ucr\data\analysis_files\rml_white_sales.dta", replace


