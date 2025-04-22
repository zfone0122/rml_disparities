**********************************************************
*name: Appendix Figure 4.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Event-Study Analyses of RMLs and Part I Arrests, 
*             Using Callaway and Sant'Anna Estimates
**********************************************************
clear 

****************
**# Appendix Figure 4
****************
cd "$path\analysis\ucr\CS output\"

	*Panel A: 
	use "total_property_noX.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(stblue) lwidth(thin)) (scatter estimate eventtime if race=="white", lcolor(stblue) mcolor(stblue) msymbol(X) msize(medium))  || (rcap conflow confhigh eventtime if race=="black", lcolor(stred) lwidth(thin)) (scatter estimate eventtime if race=="black", lcolor(stred) mcolor(stred) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-450(150)450) legend(pos(6) col(2))
	graph export "$path\analysis\ucr\figures\Appendix Figure 4_prop.png", replace
	
	*Panel B: 
	use "total_violent_noX.dta", clear 
	
	keep if inrange(eventtime, -5, 3)

	replace eventtime=eventtime+.15 if race=="black"
	replace eventtime=eventtime-.15 if race=="white"

	twoway (rcap conflow confhigh eventtime if race=="white", lcolor(stblue) lwidth(thin)) (scatter estimate eventtime if race=="white", lcolor(stblue) mcolor(stblue) msymbol(X) msize(medium))  || (rcap conflow confhigh eventtime if race=="black", lcolor(stred) lwidth(thin)) (scatter estimate eventtime if race=="black", lcolor(stred) mcolor(stred) msize(small)), yline(0, lcolor(gs8)) xline(-0.5, lcolor(gs8)) xlabel(-5(1)3) ytitle(Coefficient Estimate, size(small)) xtitle(Years Relative to RML Enactment, size(small)) graphregion(color(white)) legend(order(2 4) label(2 "White") label(4 "Black")) ylabel(-300(100)300) legend(pos(6) col(2))
	graph export "$path\analysis\ucr\figures\Appendix Figure 4_viol.png", replace


