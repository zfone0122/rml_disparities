**********************************************************
*name: Appendix Figure 1.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Event-Study Analyses of RMLs and Marijuana Arrests, 
*             Using Callaway and Sant'Anna Estimates
**********************************************************
clear 

cd "$path\analysis\ucr\CS output\"

**import csv estimates, save as dta
foreach i in total_cannabis total_heroin_coke total_synth_narc total_other_drug total_property total_violent {

import delimited using "rate_`i'_1899 es_black_ny_noX.csv", clear 
drop v1
gen race="black"

tempfile black 
save `black'

sleep 250

import delimited using "rate_`i'_1899 es_white_ny_noX.csv", clear 
drop v1
gen race="white"

append using `black'

foreach j in stderror conflow confhigh pointconflow pointconfhigh point_crit simult_crit { //COMMENT OUT IF NOT USING UNIVERSAL BASE PERIOD
	replace `j'="0" if eventtime==-1
	destring `j', replace
}

save "`i'_noX.dta", replace
sleep 250

}


****************
**# Appendix Figure 1
****************
use "total_cannabis_noX.dta", clear 
	
keep if inrange(eventtime, -5, 3)

replace eventtime=eventtime+.15 if race=="black"
replace eventtime=eventtime-.15 if race=="white"

twoway (rcap conflow confhigh eventtime if race=="white", lcolor(stblue) lwidth(thin)) (scatter estimate eventtime if race=="white", lcolor(stblue) mcolor(stblue) msymbol(X) msize(medium))  || (rcap conflow confhigh eventtime if race=="black", lcolor(stred) lwidth(thin)) (scatter estimate eventtime if race=="black", lcolor(stred) mcolor(stred) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-750(250)500) legend(pos(6) col(2))
graph export "$path\analysis\ucr\figures\Appendix Figure 1.png", replace