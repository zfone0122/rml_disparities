**********************************************************
*name: boe calc.do
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

gen race2="all"
replace race2="black" if race==2 
replace race2="white" if race==3


egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.

label var rml "RML"

sum total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
gen mean_black=r(mean)
gen treat_effect_black=-561.23/538.74
sum total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
gen mean_white=r(mean)
gen treat_effect_white=-144.68/164.45

keep in 1
keep mean_* treat_effect_*
gen n=1
reshape long treat_effect_ mean_, i(n) j(race) string

gen arrest_reduction=treat_effect_*mean_ 
list


