* ==========================================================
* CLEAN NVSS MORTALITY DATA FOR ALL OUTCOMES BY AGE GROUP
* Authors: Fone & Kumpas & Sabia
* ==========================================================
clear
set more off

* ----------------------------
* GLOBAL PATHS AND PARAMETERS
* ----------------------------
global root "$path\data\nvss"
global savepath "$root\final"
global outcomes "suicide drug_suicide overdose"
global age_groups "All 18-20 21plus"

* ========================================================
* LOOP THROUGH OUTCOMES AND AGE GROUPS
* ========================================================
foreach outcome in $outcomes {
    foreach age in $age_groups {
 
        di "Processing `outcome' - `age'..."
 
        * STEP 1: IMPORT ALL DEATHS
        import delimited "$root\All Deaths `age'.txt", clear
        drop notes  
        drop if missing(year)
 
        gen hispanic = .
        replace hispanic = 1 if hispanicorigin == "Hispanic or Latino"
        replace hispanic = 0 if hispanicorigin == "Not Hispanic or Latino"
        drop if missing(hispanic)
        drop hispanicorigin hispanicorigincode
 
        gen raceint = .
        replace raceint = 1 if racecode == "2106-3"     // White
        replace raceint = 2 if racecode == "2054-5"     // Black
        replace raceint = 3 if racecode == "1002-5"     // AI/AN
        replace raceint = 4 if racecode == "A-PI"       // Asian/PI
 
        replace deaths = "0" if deaths == "Suppressed"
        destring deaths, replace force
        save "$root\tmp\AllDeaths_`outcome'_`age'.dta", replace
        clear
 
        * STEP 2: IMPORT NON-`outcome' DEATHS
        import delimited "$root\Except `outcome' `age'.txt", clear
        drop notes  
        drop if missing(year)
 
        gen hispanic = .
        replace hispanic = 1 if hispanicorigin == "Hispanic or Latino"
        replace hispanic = 0 if hispanicorigin == "Not Hispanic or Latino"
        drop if missing(hispanic)
        drop hispanicorigin hispanicorigincode
 
        gen raceint = .
        replace raceint = 1 if racecode == "2106-3"
        replace raceint = 2 if racecode == "2054-5"
        replace raceint = 3 if racecode == "1002-5"
        replace raceint = 4 if racecode == "A-PI"
 
        replace deaths = "0" if deaths == "Suppressed"
        destring deaths, replace force
        save "$root\tmp\Except_`outcome'_`age'.dta", replace
        clear
 
        * STEP 3: MERGE AND CREATE OUTCOME-SPECIFIC DEATHS
        use "$root\tmp\AllDeaths_`outcome'_`age'.dta", clear
        rename deaths deaths_all
        merge 1:1 state year raceint hispanic using "$root\tmp\Except_`outcome'_`age'.dta", nogen
        rename deaths deaths_except
        gen deaths_`outcome' = deaths_all - deaths_except
 
        * STEP 4: RECODE RACEETH
        gen raceeth = .
        replace raceeth = 1 if raceint == 1 & hispanic == 0     // NH White
        replace raceeth = 2 if raceint == 2 & hispanic == 0     // NH Black
        replace raceeth = 3 if hispanic == 1                    // Hispanic
        replace raceeth = 4 if inlist(raceint, 3, 4) & hispanic == 0  // NH Other
 
        * STEP 5: COLLAPSE DEATHS
		statastates, name(state)
        keep state state_fips year raceeth population deaths_`outcome'
              destring population, replace 
        collapse (sum) population deaths_`outcome', by(state state_fips year raceeth)
       
       * STEP 6: RECODE RACEGROUP
        gen racegroup = 1 if raceeth == 1                      // White
		replace racegroup = 2 if inlist(raceeth, 2, 3)         // Black + Hispanic
		replace racegroup = 3 if raceeth == 4                  // Asian/Other
		collapse (sum) population deaths_`outcome', by(state state_fips year racegroup)
		ren racegroup raceeth 
 
        * STEP 7: GENERATE RATE PER 100,000
        gen rate_`outcome' = (deaths_`outcome'/population)*100000
 
        * STEP 8: SAVE FINAL CLEANED FILE
        save "$root\clean\\`outcome'_Cleaned_`age'.dta", replace
        clear
    }
}

****************opioid overdose deaths 
foreach age in $age_groups {
        *IMPORT 
        import delimited "$root\opioid_overdose `age'.txt", clear
        drop notes  
        drop if missing(year)
        replace deaths = "0" if deaths == "Suppressed"
        destring deaths, replace force
 
        gen hispanic = .
        replace hispanic = 1 if hispanicorigin == "Hispanic or Latino"
        replace hispanic = 0 if hispanicorigin == "Not Hispanic or Latino"
        drop if missing(hispanic)
        drop hispanicorigin hispanicorigincode
 
        gen raceint = .
        replace raceint = 1 if racecode == "2106-3"
        replace raceint = 2 if racecode == "2054-5"
        replace raceint = 3 if racecode == "1002-5"
        replace raceint = 4 if racecode == "A-PI"

        *RECODE RACEETH
        gen raceeth = .
        replace raceeth = 1 if raceint == 1 & hispanic == 0     // NH White
        replace raceeth = 2 if raceint == 2 & hispanic == 0     // NH Black
        replace raceeth = 3 if hispanic == 1                    // Hispanic
        replace raceeth = 4 if inlist(raceint, 3, 4) & hispanic == 0  // NH Other
 
        *COLLAPSE DEATHS
		statastates, name(state)
        keep state state_fips year raceeth population deaths
        destring population, replace 
        collapse (sum) population deaths, by(state state_fips year raceeth)
       
       *RECODE RACEGROUP
        gen racegroup = 1 if raceeth == 1                      // White
		replace racegroup = 2 if inlist(raceeth, 2, 3)         // Black + Hispanic
		replace racegroup = 3 if raceeth == 4                  // Asian/Other
		collapse (sum) population deaths, by(state state_fips year racegroup)
		ren racegroup raceeth 
 
        *GENERATE RATE PER 100,000
        gen rate_opioid_overdose = (deaths/population)*100000
		ren deaths deaths_opioid_overdose
		
		*SAVE CLEANED FILE
        save "$root\clean\opioid_overdose_Cleaned_`age'.dta", replace
        clear
}

****************four race/ethn groups
foreach outcome in $outcomes {
 
        * MERGE AND CREATE OUTCOME-SPECIFIC DEATHS
        use "$root\tmp\AllDeaths_`outcome'_All.dta", clear
        rename deaths deaths_all
        merge 1:1 state year raceint hispanic using "$root\tmp\Except_`outcome'_All.dta", nogen
        rename deaths deaths_except
        gen deaths_`outcome' = deaths_all - deaths_except
 
        * RECODE RACEETH
        gen raceeth = .
        replace raceeth = 1 if raceint == 1 & hispanic == 0     // NH White
        replace raceeth = 2 if raceint == 2 & hispanic == 0     // NH Black
        replace raceeth = 3 if hispanic == 1                    // Hispanic
        replace raceeth = 4 if inlist(raceint, 3, 4) & hispanic == 0  // NH Other
		
        * COLLAPSE DEATHS
		statastates, name(state)
        keep state state_fips year raceeth population deaths_`outcome'
              destring population, replace 
        collapse (sum) population deaths_`outcome', by(state state_fips year raceeth)
       
 
        * GENERATE RATE PER 100,000
        gen rate_`outcome' = (deaths_`outcome'/population)*100000
 
        * SAVE FINAL CLEANED FILE
        save "$root\clean\\`outcome'_Cleaned_all_4.dta", replace
        clear
}
*IMPORT 
import delimited "$root\opioid_overdose All.txt", clear
drop notes  
drop if missing(year)
replace deaths = "0" if deaths == "Suppressed"
destring deaths, replace force
 
gen hispanic = .
replace hispanic = 1 if hispanicorigin == "Hispanic or Latino"
replace hispanic = 0 if hispanicorigin == "Not Hispanic or Latino"
drop if missing(hispanic)
drop hispanicorigin hispanicorigincode
 
gen raceint = .
replace raceint = 1 if racecode == "2106-3"
replace raceint = 2 if racecode == "2054-5"
replace raceint = 3 if racecode == "1002-5"
replace raceint = 4 if racecode == "A-PI"

*RECODE RACEETH
gen raceeth = .
replace raceeth = 1 if raceint == 1 & hispanic == 0     // NH White
replace raceeth = 2 if raceint == 2 & hispanic == 0     // NH Black
replace raceeth = 3 if hispanic == 1                    // Hispanic
replace raceeth = 4 if inlist(raceint, 3, 4) & hispanic == 0  // NH Other

*COLLAPSE DEATHS
statastates, name(state)
keep state state_fips year raceeth population deaths
destring population, replace 
collapse (sum) population deaths, by(state state_fips year raceeth)
       
*GENERATE RATE PER 100,000
gen rate_opioid_overdose = (deaths/population)*100000
ren deaths deaths_opioid_overdose
		
*SAVE CLEANED FILE
save "$root\clean\opioid_overdose_Cleaned_All_4.dta", replace
clear


*************merge outcomes together (separate datasets by age)
foreach age in $age_groups {
	use "$root\clean\suicide_Cleaned_`age'.dta", clear 
	merge 1:1 state_fips year raceeth using "$root\clean\drug_suicide_Cleaned_`age'.dta", keepusing(deaths* rate*) nogen
	merge 1:1 state_fips year raceeth using "$root\clean\overdose_Cleaned_`age'.dta", keepusing(deaths* rate*) nogen
	merge 1:1 state_fips year raceeth using "$root\clean\opioid_overdose_Cleaned_`age'.dta", keepusing(deaths* rate*) nogen
	save "$root\clean\deaths_Cleaned_`age'.dta", replace 
}
use "$root\clean\suicide_Cleaned_All_4.dta", clear 
merge 1:1 state_fips year raceeth using "$root\clean\drug_suicide_Cleaned_All_4.dta", keepusing(deaths* rate*) nogen
merge 1:1 state_fips year raceeth using "$root\clean\overdose_Cleaned_All_4.dta", keepusing(deaths* rate*) nogen
merge 1:1 state_fips year raceeth using "$root\clean\opioid_overdose_Cleaned_All_4.dta", keepusing(deaths* rate*) nogen
save "$root\clean\deaths_Cleaned_All_4.dta", replace 
 
* ========================================================
* Merge Cleaned Mortality Data with Controls
* ========================================================
foreach age in $age_groups {
 
        * Load cleaned dataset
        use "$root\clean\deaths_Cleaned_`age'.dta", clear
 
        * Merge with Controls
        merge m:1 state_fips year using "$root\Controls.dta", keep(match) nogen
 
        * --- Generate race dummies ---
        gen white     = raceeth == 1
        gen blackhisp = raceeth == 2
        gen asian     = raceeth == 3
              
		* --- Step 3: Merge Dispensary data (e.g., dummy = 1 if dispensary present)
        merge m:1 state_fips year using "$root\dispensary data.dta", nogen keep(match)
		
		* Create rml_without_dispensary for RML with no dispensary
		gen rml_without_dispensary = rml if dispensary == 0
		replace rml_without_dispensary = 0 if rml_without_dispensary == .

		* Create rmldispensary1 for RML with dispensary
		gen rml_with_dispensary = rml if dispensary == 1
		replace rml_with_dispensary = 0 if rml_with_dispensary == .
 
        * --- Step 4: Merge RML Event Time Indicators (leads\lags)
        merge m:1 state_fips year using "$root\Leads and Lags NVSS.dta", nogen keep(match)
 
        * --- Log transformation of base variables ---
        gen lnpc_income = ln(pc_income)
        gen lnminimum_wage = ln(minimum_wage)
 
        * --- Save final regression-ready dataset ---
        save "$root\final\deaths_Final_`age'.dta", replace
        clear
}
use "$root\clean\deaths_Cleaned_All_4.dta", clear
 
* Merge with Controls
merge m:1 state_fips year using "$root\Controls.dta", keep(match) nogen
gen lnpc_income = ln(pc_income)
gen lnminimum_wage = ln(minimum_wage)
 
* --- Generate race dummies ---
gen white = raceeth == 1
gen black = raceeth == 2
gen hisp  = raceeth == 3
gen oth   = raceeth == 4
              
* --- Save final regression-ready dataset ---
save "$root\final\deaths_Final_All_4.dta", replace
clear

************erase intermediate files
shell del /Q "$root\tmp\*"
shell del /Q "$root\clean\*"


* ==========================================================
* Master Regression File for NVSS Mortality Analysis
* Outcomes: Suicide, DrugSuicide, Overdose, Opioid
* Group: White vs. Black & Hispanic
* ==========================================================
use "$savepath\deaths_Final_All.dta", clear
 
* --- Global Paths and Setup --- *
global controls "mml decrim lnpolice_percapita unemployment lnpc_income prop_black prop_hisp samaritan_alc samaritan_drug naloxone pdmp beer_tax lnminimum_wage acaexp democrat eitc"
foreach var in $controls {
	gen `var'_bh=`var'*blackhisp
}
foreach i in rml rml_with_dispensary rml_without_dispensary {
	gen `i'_bh=`i'*blackhisp
}
global controls_X "mml decrim lnpolice_percapita unemployment lnpc_income prop_black prop_hisp samaritan_alc samaritan_drug naloxone pdmp beer_tax lnminimum_wage acaexp democrat eitc mml_bh decrim_bh lnpolice_percapita_bh unemployment_bh lnpc_income_bh prop_black_bh prop_hisp_bh samaritan_alc_bh samaritan_drug_bh naloxone_bh pdmp_bh beer_tax_bh lnminimum_wage_bh acaexp_bh democrat_bh eitc_bh"
*global outcomes "suicide drug_suicide overdose opioid_overdose"

* ==========================================================
*Table 6: TWFE Regressions by Race Group 
* ==========================================================
***White - RML
*suicide 
reghdfe rate_suicide $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c1 

*drug_suicide
reghdfe rate_drug_suicide $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c2 

*overdose
reghdfe rate_overdose $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c3 

*opioid overdose 
reghdfe rate_opioid_overdose $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Table 6.csv", label ///
	title("Table 6 - White ")  ///
	keep(rml) ///
	noobs scalars("N N") bfmt(3) sefmt(3) sfmt(0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page replace 
	est clear 	

***White - RML Sales
*suicide 
reghdfe rate_suicide $controls rml_with_dispensary rml_without_dispensary if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_suicide if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c1 

*drug_suicide
reghdfe rate_drug_suicide $controls rml_with_dispensary rml_without_dispensary if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_drug_suicide if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c2 

*overdose
reghdfe rate_overdose $controls rml_with_dispensary rml_without_dispensary if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_overdose if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c3 

*opioid overdose 
reghdfe rate_opioid_overdose $controls rml_with_dispensary rml_without_dispensary if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_opioid_overdose if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Table 6.csv", label ///
	title("Table 6 - White ")  ///
	keep(rml_with_dispensary rml_without_dispensary) ///
	noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(3) sefmt(3) sfmt(3 0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page append 
	est clear 	

***Black-Hispanic - RML
*suicide 
reghdfe rate_suicide $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c1 

*drug_suicide
reghdfe rate_drug_suicide $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c2 

*overdose
reghdfe rate_overdose $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c3 

*opioid overdose 
reghdfe rate_opioid_overdose $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Table 6.csv", label ///
	title("Table 6 - Black-Hispanic ")  ///
	keep(rml) ///
	noobs scalars("N N") bfmt(3) sefmt(3) sfmt(0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page append 
	est clear 	

***Black-Hispanic - RML Sales
*suicide 
reghdfe rate_suicide $controls rml_with_dispensary rml_without_dispensary if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_suicide if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c1 

*drug_suicide
reghdfe rate_drug_suicide $controls rml_with_dispensary rml_without_dispensary if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_drug_suicide if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c2 

*overdose
reghdfe rate_overdose $controls rml_with_dispensary rml_without_dispensary if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_overdose if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c3 

*opioid overdose 
reghdfe rate_opioid_overdose $controls rml_with_dispensary rml_without_dispensary if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
sum rate_opioid_overdose if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Table 6.csv", label ///
	title("Table 6 - Black-Hispanic ")  ///
	keep(rml_with_dispensary rml_without_dispensary) ///
	noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(3) sefmt(3) sfmt(3 0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page append 
	est clear 	
	
***Difference - RML
*suicide 
reghdfe rate_suicide $controls_X rml rml_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c1 

*drug_suicide 
reghdfe rate_drug_suicide $controls_X rml rml_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c2 

*overdose 
reghdfe rate_overdose $controls_X rml rml_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c3 

*opioid_overdose 
reghdfe rate_opioid_overdose $controls_X rml rml_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Table 6.csv", label ///
	title("Table 6 - Difference ")  ///
	keep(rml_bh) ///
	noobs scalars("N N") bfmt(3) sefmt(3) sfmt(0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page append 
	est clear 	
	
***Difference - RML Sales
*suicide 
reghdfe rate_suicide $controls_X rml_with_dispensary rml_without_dispensary rml_with_dispensary_bh rml_without_dispensary_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c1 

*drug_suicide 
reghdfe rate_drug_suicide $controls_X rml_with_dispensary rml_without_dispensary rml_with_dispensary_bh rml_without_dispensary_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c2 

*overdose 
reghdfe rate_overdose $controls_X rml_with_dispensary rml_without_dispensary rml_with_dispensary_bh rml_without_dispensary_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c3 

*opioid_overdose 
reghdfe rate_opioid_overdose $controls_X rml_with_dispensary rml_without_dispensary rml_with_dispensary_bh rml_without_dispensary_bh if (white == 1 | blackhisp==1) [aw=population], a(i.state_fips#i.blackhisp i.year#i.blackhisp) cluster(state_fips)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Table 6.csv", label ///
	title("Table 6 - Difference ")  ///
	keep(rml_with_dispensary_bh rml_without_dispensary_bh) ///
	noobs scalars("N N") bfmt(3) sefmt(3) sfmt(0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page append 
	est clear 	


* ==========================================================
* Appendix Table 11: RML Interacted with Race Dummies
* ==========================================================
use "$root\final\deaths_Final_All_4.dta", clear
drop if raceeth==4

foreach var in $controls {
	gen `var'_b=`var'*black
	gen `var'_h=`var'*hisp
}
foreach i in rml {
	gen `i'_black=`i'*black
	gen `i'_hisp=`i'*hisp
}
global controls_b "mml_b decrim_b lnpolice_percapita_b unemployment_b lnpc_income_b prop_black_b prop_hisp_b samaritan_alc_b samaritan_drug_b naloxone_b pdmp_b beer_tax_b lnminimum_wage_b acaexp_b democrat_b eitc_b"
global controls_h "mml_h decrim_h lnpolice_percapita_h unemployment_h lnpc_income_h prop_black_h prop_hisp_h samaritan_alc_h samaritan_drug_h naloxone_h pdmp_h beer_tax_h lnminimum_wage_h acaexp_h democrat_h eitc_h"

*suicide 
reghdfe rate_suicide $controls $controls_b $controls_h rml rml_black rml_hisp [aw=population], a(state_fips year i.state_fips#i.black i.year#i.black i.state_fips#i.hisp i.year#i.hisp) cluster(state_fips)
sum rate_suicide if white == 1 & rml==0 
estadd scalar ptw = r(mean)
sum rate_suicide if black == 1 & rml==0 
estadd scalar ptb = r(mean)
sum rate_suicide if hisp == 1 & rml==0 
estadd scalar pth = r(mean)
est store c1 

*drug_suicide
reghdfe rate_drug_suicide $controls $controls_b $controls_h rml rml_black rml_hisp [aw=population], a(state_fips year i.state_fips#i.black i.year#i.black i.state_fips#i.hisp i.year#i.hisp) cluster(state_fips)
sum rate_drug_suicide if white == 1 & rml==0 
estadd scalar ptw = r(mean)
sum rate_drug_suicide if black == 1 & rml==0 
estadd scalar ptb = r(mean)
sum rate_drug_suicide if hisp == 1 & rml==0 
estadd scalar pth = r(mean)
est store c2 

*overdose
reghdfe rate_overdose $controls $controls_b $controls_h rml rml_black rml_hisp [aw=population], a(state_fips year i.state_fips#i.black i.year#i.black i.state_fips#i.hisp i.year#i.hisp) cluster(state_fips)
sum rate_overdose if white == 1 & rml==0 
estadd scalar ptw = r(mean)
sum rate_overdose if black == 1 & rml==0 
estadd scalar ptb = r(mean)
sum rate_overdose if hisp == 1 & rml==0 
estadd scalar pth = r(mean)
est store c3 

*opioid overdose 
reghdfe rate_opioid_overdose $controls $controls_b $controls_h rml rml_black rml_hisp [aw=population], a(state_fips year i.state_fips#i.black i.year#i.black i.state_fips#i.hisp i.year#i.hisp) cluster(state_fips)
sum rate_opioid_overdose if white == 1 & rml==0 
estadd scalar ptw = r(mean)
sum rate_opioid_overdose if black == 1 & rml==0 
estadd scalar ptb = r(mean)
sum rate_opioid_overdose if hisp == 1 & rml==0 
estadd scalar pth = r(mean)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Appendix Table 11.csv", label ///
	title("Appendix Table 11")  ///
	keep(rml rml_black rml_hisp) ///
	noobs scalars("ptw Pre-treat Mean (White)" "ptb Pre-treat Mean (Black)" "pth Pre-treat Mean (Hispanic)" "N N") bfmt(3) sefmt(3) sfmt(3 3 3 0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page replace 
	est clear 	


* ==========================================================
* Appendix Table 12: Age × Race Stratified Regressions
* ==========================================================
clear
global age_groups "18-20 21plus"
cap erase "$path\analysis\nvss\tables\Appendix Table 12.csv"

foreach i in $age_groups {

	use "$savepath\deaths_Final_`i'.dta", clear

	***White - RML
	*suicide 
	reghdfe rate_suicide $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_suicide if white == 1 & rml==0 
	estadd scalar pdvm = r(mean)
	est store c1 

	*drug_suicide
	reghdfe rate_drug_suicide $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_drug_suicide if white == 1 & rml==0 
	estadd scalar pdvm = r(mean)
	est store c2 

	*overdose
	reghdfe rate_overdose $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_overdose if white == 1 & rml==0 
	estadd scalar pdvm = r(mean)
	est store c3 

	*opioid overdose 
	reghdfe rate_opioid_overdose $controls rml if white == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_opioid_overdose if white == 1 & rml==0 
	estadd scalar pdvm = r(mean)
	est store c4 

	esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Appendix Table 12.csv", label ///
		title("Appendix Table 12 - White - `i' ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(3) sefmt(3) sfmt(3 0) star(* 0.10 ** 0.05 *** 0.01) ///
		nogaps se nonotes ///
		page append 
		est clear 	
		

	***Black-Hispanic
	*suicide 
	reghdfe rate_suicide $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_suicide if blackhisp == 1 & rml==0 
	estadd scalar pdvm = r(mean)
	est store c1 

	*drug_suicide
	reghdfe rate_drug_suicide $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_drug_suicide if blackhisp == 1 & rml==0 
	estadd scalar pdvm = r(mean)
	est store c2 

	*overdose
	reghdfe rate_overdose $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_overdose if blackhisp == 1 & rml==0 
	estadd scalar pdvm = r(mean)	
	est store c3 

	*opioid overdose 
	reghdfe rate_opioid_overdose $controls rml if blackhisp == 1 [aw=population], a(state_fips year) cluster(state_fips)
	sum rate_opioid_overdose if blackhisp == 1 & rml==0 
	estadd scalar pdvm = r(mean)	
	est store c4 

	esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Appendix Table 12.csv", label ///
		title("Appendix Table 12 - Black-Hispanic - `i' ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(3) sefmt(3) sfmt(3 0) star(* 0.10 ** 0.05 *** 0.01) ///
		nogaps se nonotes ///
		page append 
		est clear 	
}




* ==========================================================
* Appendix Table 13: Robustness with Region-Year FE or State Trends 
* ==========================================================
use "$savepath\deaths_Final_All.dta", clear

*Census Divisions: see -  https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf
gen division=1 if inlist(state_fips,9,23,25,33,44,50) // CT, ME, MA, RI, VT
replace division=2 if inlist(state_fips,34,36,42) // NJ, NY, PA
replace division=3 if inlist(state_fips,18,17,26,39,55) // IN, IL, MI, OH, WI
replace division=4 if inlist(state_fips,19,20,27,29,31,38,46) // IA, KS, MN, ND, SD
replace division=5 if inlist(state_fips,10,11,12,13,24,37,45,51,54) // DE, DC, FL, GA, MD, NC, SC, VA, WV
replace division=6 if inlist(state_fips,1,21,28,47) // AL, KY, MS, TN
replace division=7 if inlist(state_fips,5,22,40,48) // AR, LA, OK, TX
replace division=8 if inlist(state_fips,4,8,16,35,30,49,32,56) // AZ, CO, ID, NM, MT, NV, UT, WY
replace division=9 if inlist(state_fips,2,6,15,41,53) // AK, CA, HI, OR, WA
label var division "Census division"

*Census Regions: see - https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf
gen region=1 if inlist(division,1,2)
replace region=2 if inlist(division,3,4)
replace region=3 if inlist(division,5,6,7)
replace region=4 if inlist(division,8,9)
label var region "Census region"

gen trend=year-1999

**White
*suicide 
reghdfe rate_suicide $controls i.state_fips#c.trend rml if white == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_suicide if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c1 

*drug_suicide
reghdfe rate_drug_suicide $controls i.state_fips#c.trend rml if white == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_drug_suicide if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c2 

*overdose
reghdfe rate_overdose $controls i.state_fips#c.trend rml if white == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_overdose if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c3 

*opioid overdose 
reghdfe rate_opioid_overdose $controls i.state_fips#c.trend rml if white == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_opioid_overdose if white == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Appendix Table 13.csv", label ///
	title("Appendix Table 13 - White ")  ///
	keep(rml) ///
	noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(3) sefmt(3) sfmt(3 0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page replace

**Black
*suicide 
reghdfe rate_suicide $controls i.state_fips#c.trend rml if blackhisp == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_suicide if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c1 

*drug_suicide
reghdfe rate_drug_suicide $controls i.state_fips#c.trend rml if blackhisp == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_drug_suicide if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c2 

*overdose
reghdfe rate_overdose $controls i.state_fips#c.trend rml if blackhisp == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_overdose if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c3 

*opioid overdose 
reghdfe rate_opioid_overdose $controls i.state_fips#c.trend rml if blackhisp == 1 [aw=population], a(state_fips year i.year#i.region) cluster(state_fips)
sum rate_opioid_overdose if blackhisp == 1 & rml==0 
estadd scalar pdvm = r(mean)
est store c4 

esttab c1 c2 c3 c4 using "$path\analysis\nvss\tables\Appendix Table 13.csv", label ///
	title("Appendix Table 13 - Black-Hispanic ")  ///
	keep(rml) ///
	noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(3) sefmt(3) sfmt(3 0) star(* 0.10 ** 0.05 *** 0.01) ///
	nogaps se nonotes ///
	page append
	

* ========================================================
* EVENT STUDY ANALYSIS - TWFE & CS
* Outcomes: Suicide, Opioid Overdose
* Groups: White vs. Black/Hispanic
* ========================================================
* ========================================================
* Figure 5
* ========================================================
use "$savepath\deaths_Final_All.dta", clear

gen omit=0

label var lead5plus "-5+"
label var lead4 "-4" 
label var lead3 "-3"
label var lead2 "-2"
label var omit "-1"
label var rmlyear "0" 
label var lag1 "1" 
label var lag2 "2"
label var lag3plus "3+"

**Suicide 
*white 
reghdfe rate_suicide $controls lead5plus lead4 lead3 lead2 omit rmlyear lag1 lag2 lag3plus if white == 1 [aw=pop_state], a(state_fips year) cluster(state_fips)
est store c1w
*black 
reghdfe rate_suicide $controls lead5plus lead4 lead3 lead2 omit rmlyear lag1 lag2 lag3plus if blackhisp == 1 [aw=pop_state], a(state_fips year) cluster(state_fips)
est store c1b

coefplot (c1w, offset(-0.15) msymbol(X) msize(medium)) (c1b, offset(0.15) msymbol(O)),  ///
vertical keep(lead5plus lead4 lead3 lead2 omit rmlyear lag1 lag2 lag3plus) plotlabels("White" "Black & Hisp.") ///
omitted ciopts(recast(rcap) lwidth(thin)) ///
graphregion(color(white)) ///
xline(5.5, lcolor(gs8)) ///
xtitle(Years Relative to RML Enactment, size(small)) ///
ytitle(Coefficient Estimate, size(small)) ///
yline(0, lcolor(gs8)) ylabel(-4(2)4,labsize(small)) legend(pos(6) col(2))
graph export "$path\analysis\nvss\figures\Figure 5_suicide.png", replace     
est clear 

**Opioid Overdose 
*white 
reghdfe rate_opioid_overdose $controls lead5plus lead4 lead3 lead2 omit rmlyear lag1 lag2 lag3plus if white == 1 [aw=pop_state], a(state_fips year) cluster(state_fips)
est store c1w
*black 
reghdfe rate_opioid_overdose $controls lead5plus lead4 lead3 lead2 omit rmlyear lag1 lag2 lag3plus if blackhisp == 1 [aw=pop_state], a(state_fips year) cluster(state_fips)
est store c1b

coefplot (c1w, offset(-0.15) msymbol(X) msize(medium)) (c1b, offset(0.15) msymbol(O)),  ///
vertical keep(lead5plus lead4 lead3 lead2 omit rmlyear lag1 lag2 lag3plus) plotlabels("White" "Black & Hisp.") ///
omitted ciopts(recast(rcap) lwidth(thin)) ///
graphregion(color(white)) ///
xline(5.5, lcolor(gs8)) ///
xtitle(Years Relative to RML Enactment, size(small)) ///
ytitle(Coefficient Estimate, size(small)) ///
yline(0, lcolor(gs8)) ylabel(-10(5)10,labsize(small)) legend(pos(6) col(2))
graph export "$path\analysis\nvss\figures\Figure 5_opioid_overdose.png", replace     
est clear 


* ========================================================
* Appendix Figure 6 
* ========================================================
****Suicide
use "$savepath\deaths_Final_All.dta", clear

gen rml1 = 1 if rml > 0
replace rml1 = 0 if rml1 == .
egen gvar = csgvar(rml1), tvar(year) ivar(state_fips)

**white
csdid rate_suicide mml decrim unemployment lnpc_income if white==1 [iw=population], ///
    cluster(state_fips) time(year) gvar(gvar) method(dripw) wboot rseed(1) agg(event) never long2
estat event
preserve
matrix attmat = r(table)
matrix attmat = attmat'
svmat attmat, names(col)
keep b se z ll ul
drop in 1/2
gen time=_n-19
replace time=time+1 if time>=-1
keep if inrange(time, -5, 3)
set obs 9
replace time=-1 in 9 
foreach i in b se z ll ul {
	replace `i'=0 if time==-1
}
sort time 
gen race="white"
gen outcome="suicide"
save "$path\analysis\nvss\figures\sui_white.dta", replace
restore 
**black 
csdid rate_suicide mml decrim unemployment lnpc_income if blackhisp==1 [iw=population], ///
    cluster(state_fips) time(year) gvar(gvar) method(dripw) wboot rseed(1) agg(event) never long2
estat event
preserve
matrix attmat = r(table)
matrix attmat = attmat'
svmat attmat, names(col)
keep b se z ll ul
drop in 1/2
gen time=_n-19
replace time=time+1 if time>=-1
keep if inrange(time, -5, 3)
set obs 9
replace time=-1 in 9 
foreach i in b se z ll ul {
	replace `i'=0 if time==-1
}
sort time 
gen race="black"
gen outcome="suicide"
save "$path\analysis\nvss\figures\sui_black.dta", replace
restore
**combined 
use "$path\analysis\nvss\figures\sui_white.dta", clear 
append using "$path\analysis\nvss\figures\sui_black.dta"

replace time=time-0.15 if race=="white"
replace time=time+0.15 if race=="black"

twoway (rcap ll ul time if race=="white", lcolor(blue)) ///
       (scatter b time if race=="white", mcolor(blue) msymbol(X) msize(medium)) ///
       (rcap ll ul time if race=="black", lcolor(red)) ///
       (scatter b time if race=="black", mcolor(red) msymbol(O) msize(medium)), ///
       xtitle("Years Relative to RML Enactment") ///
	   xline(-0.5, lcolor(gs8)) ///
	   yline(0, lcolor(gs8)) ///
	   xlabel(-5(1)3) ///
       ytitle("Coefficient Estimate") ///
	   yline(0, lcolor(gs8)) ///
       legend(order(2 "White" 4 "Black & Hisp.") pos(6) col(2)) ///
       graphregion(color(white))
graph export "$path\analysis\nvss\figures\Appendix Figure 6_suicide.png", replace  

erase "$path\analysis\nvss\figures\sui_white.dta"
erase "$path\analysis\nvss\figures\sui_black.dta"


****Opioid Overdose
use "$savepath\deaths_Final_All.dta", clear

gen rml1 = 1 if rml > 0
replace rml1 = 0 if rml1 == .
egen gvar = csgvar(rml1), tvar(year) ivar(state_fips)

**white
csdid rate_opioid_overdose mml decrim unemployment lnpc_income if white==1 [iw=population], ///
    cluster(state_fips) time(year) gvar(gvar) method(dripw) wboot rseed(1) agg(event) never long2
estat event
preserve
matrix attmat = r(table)
matrix attmat = attmat'
svmat attmat, names(col)
keep b se z ll ul
drop in 1/2
gen time=_n-19
replace time=time+1 if time>=-1
keep if inrange(time, -5, 3)
set obs 9
replace time=-1 in 9 
foreach i in b se z ll ul {
	replace `i'=0 if time==-1
}
sort time 
gen race="white"
gen outcome="opioid_overdose"
save "$path\analysis\nvss\figures\opd_white.dta", replace
restore 
**black 
csdid rate_opioid_overdose mml decrim unemployment lnpc_income if blackhisp==1 [iw=population], ///
    cluster(state_fips) time(year) gvar(gvar) method(dripw) wboot rseed(1) agg(event) never long2
estat event
preserve
matrix attmat = r(table)
matrix attmat = attmat'
svmat attmat, names(col)
keep b se z ll ul
drop in 1/2
gen time=_n-19
replace time=time+1 if time>=-1
keep if inrange(time, -5, 3)
set obs 9
replace time=-1 in 9 
foreach i in b se z ll ul {
	replace `i'=0 if time==-1
}
sort time 
gen race="black"
gen outcome="opioid_overdose"
save "$path\analysis\nvss\figures\opd_black.dta", replace
restore
**combined 
use "$path\analysis\nvss\figures\opd_white.dta", clear 
append using "$path\analysis\nvss\figures\opd_black.dta"

replace time=time-0.15 if race=="white"
replace time=time+0.15 if race=="black"

twoway (rcap ll ul time if race=="white", lcolor(blue)) ///
       (scatter b time if race=="white", mcolor(blue) msymbol(X) msize(medium)) ///
       (rcap ll ul time if race=="black", lcolor(red)) ///
       (scatter b time if race=="black", mcolor(red) msymbol(O) msize(medium)), ///
       xtitle("Years Relative to RML Enactment") ///
	   xline(-0.5, lcolor(gs8)) ///
	   yline(0, lcolor(gs8)) ///
	   xlabel(-5(1)3) ///
       ytitle("Coefficient Estimate") ///
	   yline(0, lcolor(gs8)) ///
       legend(order(2 "White" 4 "Black & Hisp.") pos(6) col(2)) ///
       graphregion(color(white))
graph export "$path\analysis\nvss\figures\Appendix Figure 6_opioid_overdose.png", replace  

erase "$path\analysis\nvss\figures\opd_white.dta"
erase "$path\analysis\nvss\figures\opd_black.dta"



clear 


