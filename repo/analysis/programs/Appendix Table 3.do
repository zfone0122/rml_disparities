**********************************************************
*name: Appendix Table 3.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Robustness of main results to state-specific
*             time trends and census region-year FE
**********************************************************
use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

**dropping state-years with no arrest reporting (and FL in 2017-2019)
drop if number_of_months_reported==0
drop if fips==12

gen t1=year-1999

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.

label var rml "RML"

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

**interactions with black 
gen black=race==2
foreach i in num_agencies_report unemployment pc_income prop_black prop_hisp democrat mml decrim beer_tax samaritan_alc samaritan_drug naloxone pdmp cig_tax ecigtax lnpolice_percapita eitc snap4 minimum_wage acaexp shall_law stand_ground lnmw lnbeer lnpci rml {
	gen `i'_black=`i'*black 
}
label var rml_black "RML*Black"

**globals 
global lea "num_agencies_report"
global mml_mdl "mml decrim"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global sw_pol "lnmw acaexp democrat eitc"
global pars_interx "num_agencies_report num_agencies_report_black mml mml_black decrim decrim_black"
global sat_interx "num_agencies_report num_agencies_report_black mml mml_black lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black democrat democrat_black decrim decrim_black samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnmw lnmw_black acaexp acaexp_black lnbeer lnbeer_black eitc eitc_black"

drop if race==1

*Census Divisions: see -  https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf
gen division=1 if inlist(fips,9,23,25,33,44,50) // CT, ME, MA, RI, VT
replace division=2 if inlist(fips,34,36,42) // NJ, NY, PA
replace division=3 if inlist(fips,18,17,26,39,55) // IN, IL, MI, OH, WI
replace division=4 if inlist(fips,19,20,27,29,31,38,46) // IA, KS, MN, ND, SD
replace division=5 if inlist(fips,10,11,12,13,24,37,45,51,54) // DE, DC, FL, GA, MD, NC, SC, VA, WV
replace division=6 if inlist(fips,1,21,28,47) // AL, KY, MS, TN
replace division=7 if inlist(fips,5,22,40,48) // AR, LA, OK, TX
replace division=8 if inlist(fips,4,8,16,35,30,49,32,56) // AZ, CO, ID, NM, MT, NV, UT, WY
replace division=9 if inlist(fips,2,6,15,41,53) // AK, CA, HI, OR, WA
label var division "Census division"

*Census Regions: see - https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf
gen region=1 if inlist(division,1,2)
replace region=2 if inlist(division,3,4)
replace region=3 if inlist(division,5,6,7)
replace region=4 if inlist(division,8,9)
label var region "Census region"

*time trends 
cap drop t1
gen t1=year-1999

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000


****************
**# Appendix Table 3
****************
cd "$path\analysis\tables"

*c1
reghdfe rate_total_cannabis_1899 $sat_interx i.fips#i.black#c.t1 rml rml_black [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	estadd local trends="Yes"
	estadd local reg_year="No"
	est store c1
 
*c2
reghdfe rate_total_cannabis_1899 $sat_interx i.fips#i.black#c.t1 rml rml_black [pw=pop_1899], a(i.fips#i.black i.year#i.black i.year#i.black#i.region) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	estadd local trends="Yes"
	estadd local reg_year="Yes"
	est store c2
	
*c3
reghdfe rate_total_nonmj_1899 $sat_interx i.fips#i.black#c.t1 rml rml_black [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	estadd local trends="Yes"
	estadd local reg_year="No"
	est store c3
		
*c4
reghdfe rate_total_nonmj_1899 $sat_interx i.fips#i.black#c.t1 rml rml_black [pw=pop_1899], a(i.fips#i.black i.year#i.black i.year#i.black#i.region) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	estadd local trends="Yes"
	estadd local reg_year="Yes"	
	est store c4	

esttab c1 c2 c3 c4 using "Appendix Table 3.csv", label ///
	title("Appendix Table 3")  ///
	keep(rml rml_black) ///
	noobs scalars("pdvm_w Pre-treat DV mean (White)" "pdvm_b Pre-treat DV mean (Black)" "N N" "trends State-specific linear time trends" "reg_year Census region-year FE") bfmt(2) sefmt(2) sfmt(2 2 0) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles("Marijuana Arrests" "" "Non-Marijuana Drug Arrests" "") nogaps se nonotes ///
	page replace 
	est clear



clear 


