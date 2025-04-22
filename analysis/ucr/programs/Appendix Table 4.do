**********************************************************
*name: Appendix Table 4.do
*author: Zach Fone (U.S. Air Force Academy)
*description: CS Estimates of Effect of RML Adoption on Black/White 
*             Marijuana Arrests, Non-Marijuana Drug Arrests and Part I Arrests 
**********************************************************
clear 

cd "$path\analysis\ucr\CS output\"

**import csv estimates, save as dta
foreach i in total_cannabis total_nonmj total_property total_violent {

import delimited using "rate_`i'_1899 static_black_ny.csv", clear 
drop v1
gen race="black"

tempfile black 
save `black'

sleep 250

import delimited using "rate_`i'_1899 static_white_ny.csv", clear 
drop v1
gen race="white"

append using `black'

keep type estimate stderror controlgroup outcome race estmethod pval race 
gen covariates="YES"

save "`i'_static_ny.dta", replace
sleep 250

}

use "total_cannabis_static_ny.dta", clear 
foreach i in total_nonmj total_property total_violent {
	append using "`i'_static_ny.dta"
}
save "cs_static_X.dta", replace 
export delimited using "$path\analysis\ucr\tables\Appendix Table 4.csv", replace 



clear 


