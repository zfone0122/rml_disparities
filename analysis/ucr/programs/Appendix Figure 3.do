**********************************************************
*name: Appendix Figure 3.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Event-Study Analyses of RMLs and Non-Marijuana Drug Arrests, 
*             Using Callaway and Sant'Anna Estimates
**********************************************************
clear 

****************
**# Appendix Figure 3
****************
cd "$path\analysis\ucr\CS output\"

	*Panel A: 
	use "total_heroin_coke_noX.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(stblue) lwidth(thin)) (scatter estimate eventtime if race=="white", lcolor(stblue) mcolor(stblue) msymbol(X) msize(medium))  || (rcap conflow confhigh eventtime if race=="black", lcolor(stred) lwidth(thin)) (scatter estimate eventtime if race=="black", lcolor(stred) mcolor(stred) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-450(150)450) legend(pos(6) col(2))
	graph export "$path\analysis\ucr\figures\Appendix Figure 3_coke.png", replace
	
	*Panel B: 
	use "total_synth_narc_noX.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(stblue) lwidth(thin)) (scatter estimate eventtime if race=="white", lcolor(stblue) mcolor(stblue) msymbol(X) msize(medium))  || (rcap conflow confhigh eventtime if race=="black", lcolor(stred) lwidth(thin)) (scatter estimate eventtime if race=="black", lcolor(stred) mcolor(stred) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-60(20)60) legend(pos(6) col(2))
	graph export "$path\analysis\ucr\figures\Appendix Figure 3_snarc.png", replace

	*Panel C:
	use "total_other_drug_noX.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(stblue) lwidth(thin)) (scatter estimate eventtime if race=="white", lcolor(stblue) mcolor(stblue) msymbol(X) msize(medium))  || (rcap conflow confhigh eventtime if race=="black", lcolor(stred) lwidth(thin)) (scatter estimate eventtime if race=="black", lcolor(stred) mcolor(stred) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-225(75)225) legend(pos(6) col(2))
	graph export "$path\analysis\ucr\figures\Appendix Figure 3_odrug.png", replace
	