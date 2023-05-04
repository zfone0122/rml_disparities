**********************************************************
*name: Table 8.do
*author: Zach Fone (U.S. Air Force Academy)
*description: RML estimates by whether sales are operational
**********************************************************
clear all 

use "$path\source_data\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta" 

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

**merge in rml-sales 
merge m:1 fips year using "$path\source_data\data\policy\rml-sales_year_2000-2019", keepusing(rml_sales rml_no_sales)
drop if _merge==2
drop _merge 

**interactions with black 
gen black=race==2
foreach i in num_agencies_report unemployment pc_income prop_black prop_hisp democrat mml decrim beer_tax samaritan_alc samaritan_drug naloxone pdmp cig_tax ecigtax lnpolice_percapita eitc snap4 minimum_wage acaexp shall_law stand_ground lnmw lnbeer lnpci rml rml_sales rml_no_sales {
	gen `i'_black=`i'*black 
}
label var rml_black "RML*Black"
label var rml_sales_black "RML-Sales*Black"
label var rml_no_sales_black "RML-No Sales*Black"
label var rml_sales "RML-Sales"
label var rml_no_sales "RML-No Sales"

**globals 
global lea "num_agencies_report"
global mml_mdl "mml decrim"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global sw_pol "lnmw acaexp democrat eitc"
global pars_interx "num_agencies_report num_agencies_report_black mml mml_black decrim decrim_black"
global sat_interx "num_agencies_report num_agencies_report_black mml mml_black lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black democrat democrat_black decrim decrim_black samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnmw lnmw_black acaexp acaexp_black lnbeer lnbeer_black eitc eitc_black"

drop if race==1

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

****************
**# Table 8
****************
cd "$path\analysis\tables"

*c1
reghdfe rate_total_cannabis_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	est store c1 
		
*c2
reghdfe rate_total_nonmj_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	est store c2	
		
*c3
reghdfe rate_property_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	est store c3
	
*c4
reghdfe rate_violent_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==2
	estadd scalar pdvm_b = r(mean)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race==3
	estadd scalar pdvm_w = r(mean)	
	est store c4
	
esttab c1 c2 c3 c4 using "Table 8.csv", label ///
	title("Table 8")  ///
	keep(rml_no_sales rml_no_sales_black rml_sales rml_sales_black) ///
	noobs scalars("pdvm_w Pre-treat DV mean (White)" "pdvm_b Pre-treat DV mean (Black)" "N N") bfmt(2) sefmt(2) sfmt(2 2 0) star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") nogaps se nonotes ///
	page replace 
	est clear 		



clear 


