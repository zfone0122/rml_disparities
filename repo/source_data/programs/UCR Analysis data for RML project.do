**********************************************************
*name: UCR Analysis data for RML project.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Creates the data file used for the UCR analysis 
*             of the RML project
**********************************************************
clear all

******
*Combine data (UCR, SEER, Policy variables, Covariates)
******
***
*UCR (for prior coding, see: "path\source_date\programs\UCR data for RML project.do")
***
use "$path\source_data\data\ucr\cleaned\ucr_state-year_2000-2019_cleaned.dta", clear

***
*SEER (for prior coding, see: "path\source_date\programs\SEER data for RML project.do")
*** 
merge 1:1 fips year using "$path\source_data\data\seer\cleaned\seer_state-year_2000-2019_cleaned.dta"
drop _merge // all matched 

**create arrest rates (per 100k state population)
foreach i in total_drug poss_drug_total sale_drug_total poss_cannabis sale_cannabis total_cannabis poss_heroin_coke sale_heroin_coke total_heroin_coke poss_synth_narc sale_synth_narc total_synth_narc poss_other_drug sale_other_drug total_other_drug property theft burglary mtr_veh_theft arson violent agg_assault rape robbery murder liquor drunkenness dui vandalism disorder_cond total {
foreach j in 1899_all 1899_black 1899_white {
	cap gen rate_`i'`j'=(`i'_`j'/pop_`j')*100000
	
}
}

*** 
*Policy variables (for prior coding, see: "path\source_date\programs\Policy data for RML project.do")
***
gen state_fips=fips
merge 1:1 state_fips year using "$path\source_data\data\policy\rml-mml_2000-2019.dta" 
drop _merge 

**RML leads and lags 
merge 1:1 state_fips year using "$path\source_data\data\policy\rml events_2000-2019.dta", keepusing(F* L*)
drop _merge 

*** 
*Covariates (for prior coding, see: "path\source_date\programs\Policy data for RML project.do")
***
merge 1:1 state_fips year using "$path\source_data\data\policy\covariates_2000-2019.dta" 
drop _merge 

**save 
save "$path\source_data\data\analysis_files\ucr_state-year_2000-2019_analysis data.dta", replace


******
*LONG format (separate obs for all/black/white)
******
***
*UCR (for prior coding, see: "path\source_date\programs\UCR data for RML project.do")
***
use "$path\source_data\data\ucr\cleaned\ucr_state-year_2000-2019_cleaned.dta", clear

keep year state state_abb fips *all *black *white num*

*vars to merge back in 
preserve 
keep year state state_abb fips num* 
tempfile vars 
save `vars'
restore

*reshape long
drop num* state* 
reshape long agg_assault_1899 murder_1899 rape_1899 robbery_1899 arson_1899 burglary_1899 mtr_veh_theft_1899 theft_1899 liquor_1899 drunkenness_1899 vandalism_1899 disorder_cond_1899 total_drug_1899 poss_drug_total_1899 sale_drug_total_1899 sale_cannabis_1899 poss_cannabis_1899 sale_heroin_coke_1899 poss_heroin_coke_1899 sale_synth_narc_1899 poss_synth_narc_1899 sale_other_drug_1899 poss_other_drug_1899 total_cannabis_1899 total_heroin_coke_1899 total_synth_narc_1899 total_other_drug_1899 property_1899 violent_1899 dui_1899 total_1899, i(year fips) j(race) string

replace race=subinstr(race, "_", "", .)
encode race, gen(race2)
order race2, after(race)
drop race 
ren race2 race

*merge vars back in 
merge m:1 fips year using `vars'
drop _merge 
order state state_abb fips, before(year)

***
*SEER (for prior coding, see: "path\source_date\programs\SEER data for RML project.do")
*** 
preserve 
use "$path\source_data\data\seer\cleaned\seer_state-year_2000-2019_cleaned.dta", clear 
reshape long pop_1899, i(fips year) j(race) string 
replace race=subinstr(race, "_", "", .)
encode race, gen(race2)
order race2, after(race)
drop race 
ren race2 race
tempfile pop 
save `pop'
restore

merge 1:1 fips year race using `pop'
drop _merge 

**create arrest rates (per 100k state population)
foreach i in agg_assault_1899 murder_1899 rape_1899 robbery_1899 arson_1899 burglary_1899 mtr_veh_theft_1899 theft_1899 liquor_1899 drunkenness_1899 vandalism_1899 disorder_cond_1899 total_drug_1899 poss_drug_total_1899 sale_drug_total_1899 sale_cannabis_1899 poss_cannabis_1899 sale_heroin_coke_1899 poss_heroin_coke_1899 sale_synth_narc_1899 poss_synth_narc_1899 sale_other_drug_1899 poss_other_drug_1899 total_cannabis_1899 total_heroin_coke_1899 total_synth_narc_1899 total_other_drug_1899 property_1899 violent_1899 dui_1899 total_1899 {

	cap gen rate_`i'=(`i'/pop_1899)*100000
	
}

*** 
*Policy variables (for prior coding, see: "path\source_date\programs\Policy data for RML project.do")
***
gen state_fips=fips
merge m:1 state_fips year using "$path\source_data\data\policy\rml-mml_2000-2019.dta" 
drop _merge 

**RML leads and lags 
merge m:1 state_fips year using "$path\source_data\data\policy\rml events_2000-2019.dta", keepusing(F* L*)
drop _merge 

*** 
*Covariates (for prior coding, see: "path\source_date\programs\Policy data for RML project.do")
***
merge m:1 state_fips year using "$path\source_data\data\policy\covariates_2000-2019.dta" 
drop _merge 

**save 
save "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", replace



clear 


