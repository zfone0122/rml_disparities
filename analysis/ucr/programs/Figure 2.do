**********************************************************
*name: Figure 2.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Trends in Black and White Marijuana Arrests 
*             in Event time around Adoption Year
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.

keep if ever_rml==1

drop if race==1

keep state fips year race rate_total_cannabis_1899 pop_1899 L0_rml
gen temp=year if L0_rml!=0
egen rml_year=min(temp), by(fips)
gen event_time=year-rml_year

collapse (mean) rate_total_cannabis_1899 [pw=pop_1899], by(race event_time)

*-5 to 3
twoway (line rate_total_cannabis_1899 event_time if race==3 & inrange(event_time, -5, 3), lpattern(dash)) (line rate_total_cannabis_1899 event_time if race==2 & inrange(event_time, -5, 3), ytitle("Marijuana arrest rate per 100,000") xtitle("Years Relative to RML Enactment") xlabel(-5(1)3) xline(-0.5) legend(pos(6) col(2) label(1 "White") label(2 "Black")))
graph export "$path\analysis\ucr\figures\Figure 2.png", replace


