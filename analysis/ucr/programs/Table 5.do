**********************************************************
*name: Table 5.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Exploration of Heterogeneity in the Effects of RMLs on Arrests
*             by Whether a Recreational Dispensary is Allowed
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear

egen ever_rml=max(rml), by(fips)
replace ever_rml=1 if ever_rml>0 & ever_rml!=.

label var rml "RML"

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

**interactions with black 
gen black=race==2
foreach i in number_of_months_reported report_share_seer unemployment pc_income prop_black prop_hisp democrat mml decrim beer_tax samaritan_alc samaritan_drug naloxone pdmp cig_tax ecigtax lnpolice_percapita eitc snap4 minimum_wage acaexp shall_law stand_ground lnmw lnbeer lnpci rml {
	gen `i'_black=`i'*black 
}
label var rml_black "Diff. in Coeff. (Black-White)"

**globals 
global lea "number_of_months_reported report_share_seer"
global lea_interx "number_of_months_reported report_share_seer number_of_months_reported_black report_share_seer_black"
global mml_mdl "mml decrim"
global mml_mdl_interx "mml mml_black decrim decrim_black"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global police_econ_interx "lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global drug_pol_interx "samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnbeer lnbeer_black"
global sw_pol "lnmw acaexp democrat eitc"
global sw_pol_interx "lnmw lnmw_black acaexp acaexp_black democrat democrat_black eitc eitc_black"
global sat_interx "number_of_months_reported report_share_seer number_of_months_reported_black report_share_seer_black mml mml_black lnpolice_percapita lnpolice_percapita_black unemployment unemployment_black lnpci lnpci_black prop_black prop_black_black prop_hisp prop_hisp_black democrat democrat_black decrim decrim_black samaritan_alc samaritan_alc_black samaritan_drug samaritan_drug_black naloxone naloxone_black pdmp pdmp_black lnmw lnmw_black acaexp acaexp_black lnbeer lnbeer_black eitc eitc_black"

gen race2="all"
replace race2="black" if race==2 
replace race2="white" if race==3
drop if race==1

**merge in rml-sales 
merge m:1 fips year using "$path\data\ucr\data\policy\rml-sales_year_2000-2019", keepusing(rml_sales rml_no_sales)
drop if _merge==2
drop _merge 
gen rml_sales_black=rml_sales*black 
gen rml_no_sales_black=rml_no_sales*black
label var rml_no_sales "RML-No Sales"
label var rml_sales "RML-Sales"
label var rml_sales_black "RML-Sales Diff (Black-White)"
label var rml_no_sales_black "RML-No Sales Diff (Black-White)"

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000


****************
**# Table 5
****************
cd "$path\analysis\ucr\tables"

foreach i in black white {
	
	*c1
	reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml_no_sales rml_sales [pw=pop_1899] if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c1
		
	*c2
	reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml_no_sales rml_sales [pw=pop_1899] if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c2	
		
	*c3
	reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml_no_sales rml_sales [pw=pop_1899] if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c3	
		
	*c4
	reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml_no_sales rml_sales [pw=pop_1899] if race2=="`i'", a(fips year) vce(cl fips)
		sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="`i'"
		estadd scalar pdvm = r(mean)
		est store c4

esttab c1 c2 c3 c4 using "Table 5.csv", label ///
		title("Table 5 - `i' ")  ///
		keep(rml_no_sales rml_sales) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(2) sefmt(2) sfmt(2 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") nogaps se nonotes ///
		page append 
		est clear 	

}

**difference in coefficients
	*c1
	reghdfe rate_total_cannabis_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black if race!=1 [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c1 
			
	*c2
	reghdfe rate_total_nonmj_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black if race!=1 [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c2	
			
	*c3
	reghdfe rate_property_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black if race!=1 [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c3
		
	*c4
	reghdfe rate_violent_1899 $sat_interx rml_no_sales rml_no_sales_black rml_sales rml_sales_black if race!=1 [pw=pop_1899], a(i.fips#i.black i.year#i.black) vce(cl fips)
		est store c4
		
	esttab c1 c2 c3 c4 using "Table 5.csv", label ///
		title("Table 5 - diff in RML coeff. ")  ///
		keep(rml_no_sales_black rml_sales_black) ///
		noobs bfmt(2) sefmt(2) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "Non-Marijuana" "Property" "Violent") nogaps se nonotes ///
		page append 
		est clear 	
		


clear 


