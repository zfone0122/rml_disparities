**********************************************************
*name: BOE CALC.do
*author: Zach Fone (U.S. Air Force Academy)
*description: BOE calculation for conclusion paragraph
**********************************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear 

drop if race==1

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.
keep if rml==0 & ever_rml==1

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

keep state state_abb fips year race total_cannabis_1899 total_synth_narc_1899 pop_1899

**weighted average arrests in a pre-treatment RML state-year
sum total_cannabis_1899 if race==2 [aw=pop_1899]
gen cannabis_mean=r(mean)
sum total_cannabis_1899 if race==3 [aw=pop_1899]
replace cannabis_mean=r(mean) if race==3

sum total_synth_narc_1899 if race==2 [aw=pop_1899]
gen synth_narc_mean=r(mean)
sum total_synth_narc_1899 if race==3 [aw=pop_1899]
replace synth_narc_mean=r(mean) if race==3

keep cannabis_mean synth_narc_mean race
keep in 1/2

**treatment effect (in percentage terms)
gen cannabis_te=(-325.15/492.25) if race==2
replace cannabis_te=(-115.23/158.32) if race==3
gen synth_narc_te=(-20.11/19.99) if race==2
replace synth_narc_te=(-24.29/18.07) if race==3

**arrest reduction
gen cannabis_reduction=cannabis_te*cannabis_mean
gen synth_narc_reduction=synth_narc_te*synth_narc_mean


