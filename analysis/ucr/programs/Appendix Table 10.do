**********************************************************
*name: Appendix Table 10.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Exploration of Heterogeneity in the Effects of RMLs on Arrests
*             by Whether a Recreational Dispensary is Allowed, CS
**********************************************************
clear 

cd "$path\analysis\ucr\CS output\"

**import csv estimates, save as dta
foreach i in total_cannabis total_nonmj total_property total_violent {
foreach k in sales nosales {

import delimited using "rate_`i'_1899 static_black_`k'_ny.csv", clear 
drop v1
gen race="black"

tempfile black 
save `black'

sleep 250

import delimited using "rate_`i'_1899 static_white_`k'_ny.csv", clear 
drop v1
gen race="white"

append using `black'
gen rml="`k'"

keep type estimate stderror controlgroup outcome race estmethod pval race rml

save "`i'_static_`k'_ny.dta", replace
sleep 250

}
}
use "total_cannabis_static_sales_ny.dta", clear 
append using "total_cannabis_static_nosales_ny.dta"
foreach i in total_nonmj total_property total_violent {
foreach k in sales nosales {
	append using "`i'_static_`k'_ny.dta"
}
}	
save "cs_disp_static.dta", replace 
export delimited using "$path\analysis\ucr\tables\Appendix Table 10.csv", replace 



clear 


