**********************************************************
*name: Figures 1-3_CS_clean R output.do
*author: Zach Fone (U.S. Air Force Academy)
*description: clean CS estimates from R
**********************************************************
clear 

cd "$path\analysis\figures\from R\"

**import csv estimates, save as dta
foreach i in total_cannabis poss_cannabis sale_cannabis total_heroin_coke total_synth_narc total_other_drug total_property total_violent {

import delimited using "rate_`i'_1899 _black.csv", clear 
drop v1
gen race="black"

tempfile black 
save `black'

sleep 250

import delimited using "rate_`i'_1899 _white.csv", clear 
drop v1
gen race="white"

append using `black'

foreach j in stderror conflow confhigh pointconflow pointconfhigh point_crit simult_crit { //COMMENT OUT IF NOT USING UNIVERSAL BASE PERIOD
	replace `j'="0" if eventtime==-1
	destring `j', replace
}

save "`i'.dta", replace
erase "rate_`i'_1899 _black.csv"
erase "rate_`i'_1899 _white.csv"
sleep 250

}

****
*Event study figures 
****
***USING SIMULTANEOUS CONFIDENCE BANDS

**Figure 1
	*Panel A: 
	use "total_cannabis.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-750(250)500)
	graph export "$path\analysis\figures\Figure 1_CS_mj_tot.png", replace
		
	*Panel B: 
	use "poss_cannabis.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-750(250)500)
	graph export "$path\analysis\figures\Figure 1_CS_mj_poss.png", replace

	*Panel C:
	use "sale_cannabis.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-150(50)100)
	graph export "$path\analysis\figures\Figure 1_CS_mj_sale.png", replace

**Figure 2
	*Panel A: 
	use "total_heroin_coke.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-450(150)450)
	graph export "$path\analysis\figures\Figure 2_CS_coke_tot.png", replace
	
	*Panel B: 
	use "total_synth_narc.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-60(20)60)
	graph export "$path\analysis\figures\Figure 2_CS_snarc_tot.png", replace

	*Panel C:
	use "total_other_drug.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-225(75)225)
	graph export "$path\analysis\figures\Figure 2_CS_odrug_tot.png", replace
	
**Figure 3
	*Panel A: 
	use "total_property.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-450(150)450)
	graph export "$path\analysis\figures\Figure 3_CS_property.png", replace
	
	*Panel B: 
	use "total_violent.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(navy) lwidth(thin)) (connected estimate eventtime if race=="white", lcolor(navy) mcolor(navy) msize(small))  || (rcap conflow confhigh eventtime if race=="black", lcolor(maroon) lwidth(thin)) (connected estimate eventtime if race=="black", lcolor(maroon) mcolor(maroon) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-300(100)300)
	graph export "$path\analysis\figures\Figure 3_CS_violent.png", replace	
	


clear 


