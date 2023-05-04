**********************************************************
*name: UCR data for RML project.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Cleaning UCR data to be used in the RML 
*             project
**********************************************************
clear all

/* Data downloaded from: 
	https://www.openicpsr.org/openicpsr/project/102263/version/V14/view?path=/openicpsr/102263/fcr:versions/V14/ucr_arrests_yearly_data_1974_2020_dta.zip&type=file

File Citation: 

Kaplan, Jacob. Jacob Kaplan’s Concatenated Files: Uniform Crime Reporting (UCR) Program Data: Arrests by Age, Sex, and Race, 1974-2020: ucr_arrests_yearly_data_1974_2020_dta.zip. Ann Arbor, MI: Inter-university Consortium for Political and Social Research [distributor], 2021-09-27. https://doi.org/10.3886/E102263V14-107920
To view the citation for the overall project, see http://doi.org/10.3886/E102263V14.

*/   

/* Data to gather

Panel:
	State-level 
	2000-2019

Arrest categories:
	Drug (total, sale, possession)
	Marijuana (total, sale, posession)
	Cocaine/Heroin/Crack/Other Opioids (total, sale, posession)
	"Truly addicting synthetic narcotics" (total, sale, posession)
	"Other dangerous non-narcotic drugs" (total, sale, posession)
	Property (total, larceny, burglary, MVT, arson) 
	Violent (total, murder, assault, rape, robbery)
	Vandalism
	Liquor law 
	Drunkenness 
	Disorderly Conduct

Demographic groups: 
	18+ white and black

*/

*******
**#Data cleaning 
*******
use "$path\source_data\data\ucr\raw\ucr_arrests_yearly_all_crimes_race_sex_1974_2020.dta", clear

keep if inrange(year, 2000, 2019)

**create arrest variables 
foreach i in agg_assault murder rape robbery arson burglary mtr_veh_theft theft liquor drunkenness dui vandalism disorder_cond total_drug poss_drug_total sale_drug_total sale_cannabis poss_cannabis sale_heroin_coke poss_heroin_coke sale_synth_narc poss_synth_narc sale_other_drug poss_other_drug {
	
	gen `i'_1899_all=`i'_tot_adult 
	gen `i'_1899_black=`i'_adult_black	
	gen `i'_1899_white=`i'_adult_white
	
}
foreach i in cannabis heroin_coke synth_narc other_drug {
	gen total_`i'_1899_all=sale_`i'_1899_all+poss_`i'_1899_all
	gen total_`i'_1899_black=sale_`i'_1899_black+poss_`i'_1899_black
	gen total_`i'_1899_white=sale_`i'_1899_white+poss_`i'_1899_white

}
foreach i in 1899_all 1899_black 1899_white {
	gen property_`i'=theft_`i'+burglary_`i'+mtr_veh_theft_`i'+arson_`i'
	gen violent_`i'=agg_assault_`i'+murder_`i'+rape_`i'+robbery_`i'
}

*total arrests for 18-99 YOs
gen total_1899_all=agg_assault_tot_adult+all_other_tot_adult+arson_tot_adult+burglary_tot_adult+curfew_loiter_tot_adult+disorder_cond_tot_adult+drunkenness_tot_adult+dui_tot_adult+embezzlement_tot_adult+family_off_tot_adult+forgery_tot_adult+fraud_tot_adult+gamble_total_tot_adult+liquor_tot_adult+manslaught_neg_tot_adult+mtr_veh_theft_tot_adult+murder_tot_adult+oth_assault_tot_adult+oth_sex_off_tot_adult+prostitution_tot_adult+rape_tot_adult+robbery_tot_adult+runaways_tot_adult+total_drug_tot_adult+stolen_prop_tot_adult+suspicion_tot_adult+theft_tot_adult+vagrancy_tot_adult+vandalism_tot_adult+weapons_tot_adult
gen total_1899_black=agg_assault_adult_black+all_other_adult_black+arson_adult_black+burglary_adult_black+curfew_loiter_adult_black+disorder_cond_adult_black+drunkenness_adult_black+dui_adult_black+embezzlement_adult_black+family_off_adult_black+forgery_adult_black+fraud_adult_black+gamble_total_adult_black+liquor_adult_black+manslaught_neg_adult_black+mtr_veh_theft_adult_black+murder_adult_black+oth_assault_adult_black+oth_sex_off_adult_black+prostitution_adult_black+rape_adult_black+robbery_adult_black+runaways_adult_black+total_drug_adult_black+stolen_prop_adult_black+suspicion_adult_black+theft_adult_black+vagrancy_adult_black+vandalism_adult_black+weapons_adult_black
gen total_1899_white=agg_assault_adult_white+all_other_adult_white+arson_adult_white+burglary_adult_white+curfew_loiter_adult_white+disorder_cond_adult_white+drunkenness_adult_white+dui_adult_white+embezzlement_adult_white+family_off_adult_white+forgery_adult_white+fraud_adult_white+gamble_total_adult_white+liquor_adult_white+manslaught_neg_adult_white+mtr_veh_theft_adult_white+murder_adult_white+oth_assault_adult_white+oth_sex_off_adult_white+prostitution_adult_white+rape_adult_white+robbery_adult_white+runaways_adult_white+total_drug_adult_white+stolen_prop_adult_white+suspicion_adult_white+theft_adult_white+vagrancy_adult_white+vandalism_adult_white+weapons_adult_white

drop agg_assault_adult_amer_ind-sale_drug_total_tot_white

**collapse to state-year 
ren population agency_pop
gen num_agencies=1
gen num_agencies_report=number_of_months_reported>0
collapse (sum) agg_assault_1899_all-total_1899_white num_agencies num_agencies_report (mean) number_of_months_reported-num_months_arson num_months_liquor num_months_drunkenness num_months_total_drug-num_months_disorder_cond, by(year state state_abb fips_state_code)
ren fips_state_code fips 
destring fips, replace 
keep if inrange(fips, 1, 56)
sort fips year

**save 
save "$path\source_data\data\ucr\cleaned\ucr_state-year_2000-2019_cleaned.dta", replace 



clear 


