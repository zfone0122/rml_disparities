**********************************************************
*name: Appendix Table 9.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Robustness of Arrest Findings to Spillovers 
*             from Border State RMLs
**********************************************************
clear 
****************
**# Border state coding
****************
*****
*State-to-state borders
*****
/*

Downloaded from: https://www.nber.org/research/data/county-adjacency

**FROM CENSUS (which these data are derived):
	https://www.census.gov/programs-surveys/geography/technical-documentation/records-layout/county-adjacency-record-layout.html
	
"Notes

In some instances the boundary between two counties may fall within a body of water, 
so it seems as if the two counties do not physically touch. These counties are included 
on the list as neighbors.

Every county has itself listed as a neighboring county."

*/
use "$path\data\ucr\data\policy\county_adjacency2010.dta", clear

ren (fipscounty fipsneighbor) (countyfips countyfips_neighbor)

destring countyfips countyfips_neighbor, replace

*state fips code for each county 
gen fips=floor(countyfips/1000)
gen fips_neighbor=floor(countyfips_neighbor/1000)

*county lies along border of other state 
gen border=fips!=fips_neighbor

**removing "water" borders
drop if fips==26 & fips_neighbor==55 & !inlist(countyfips, 26053, 26071, 26043, 26109) & border==1  //MI counties that "share" a border with WI, but aren't on the UP. MI countyfips map: https://www.cccarto.com/fipscodes/michigan/files/michigan-fips-code-map.gif
drop if fips==55 & fips_neighbor==26 & !inlist(countyfips_neighbor, 26053, 26071, 26043, 26109) & border==1  //WI counties that "share" a border with MI, but they aren't shared with UP counties. MI countyfips map: https://www.cccarto.com/fipscodes/michigan/files/michigan-fips-code-map.gif
drop if countyfips==26083 & fips_neighbor==27 & border==1 //UP "water border" with MN. There is no bridge. MN countyfips map: https://www.cccarto.com/fipscodes/minnesota/files/minnesota-fips-code-map.gif
drop if countyfips==26021 & fips_neighbor==17 & border==1  //MI county that "shares" a border with IL. IL county map: https://www.cccarto.com/fipscodes/illinois/files/illinois-fips-code-map.gif
drop if inlist(countyfips, 17031, 17097) & fips_neighbor==26 & border==1  //IL counties that "share" a border with MI.
drop if inlist(countyfips, 27075, 27031) & inlist(fips_neighbor, 26, 55) & border==1  //MN counties that "share" a border with WI and MI. WI countyfips map: https://www.cccarto.com/fipscodes/wisconsin/files/wisconsin-fips-code-map.gif
drop if inlist(countyfips, 55007, 55003) & inlist(fips_neighbor, 26, 27) & border==1  //WI counties that "share" a border with MN and MI.
drop if countyfips==55029 & fips_neighbor==26 & border==1  //WI county that "shares" a border with MI
drop if inlist(countyfips, 26159, 26005, 26131) & inlist(fips_neighbor, 27, 17) & border==1  //MI counties that "share" a border with MN and IL.
drop if countyfips==18127 & inlist(fips_neighbor, 17, 26) & border==1  //IN county that "shares" a border with IL and MI. IN county map: https://www.cccarto.com/fipscodes/indiana/files/indiana-fips-code-map-.gif
drop if inlist(countyfips, 36005, 36059, 36103, 36081, 36047) & inlist(fips_neighbor, 34, 9, 44) & border==1  //NY counties that "share" a border with NJ, CT, and RI. NY county map: https://www.cccarto.com/fipscodes/newyork/files/new-york-fips-code-map.gif
drop if fips==34 & fips_neighbor==36 & !inlist(countyfips_neighbor, 36085, 36061, 36087, 36071) & border==1  //NJ counties that "share" a border with NY that aren't Richmond county, NY county, Rockland county, or Orange county
drop if countyfips==34025 & fips_neighbor==36 & border==1  //NJ county that "shares" a bordery with NY. NJ county map: https://www.cccarto.com/fipscodes/newjersey/files/new-jersey-fips-code-map.gif
drop if inlist(countyfips, 34011, 34009) & fips_neighbor==10 & border==1 //NJ counties that "share" a border with DE
drop if inlist(countyfips, 10001, 10005) & fips_neighbor==34 & border==1 //DE counties that "share" a border with NJ. DE county map: https://www.cccarto.com/fipscodes/delaware/files/delaware-fips-code-map.gif
drop if inlist(countyfips, 9007, 9009) & fips_neighbor==36 & border==1 //CT counties that "share" a border with NY. CT county map: https://www.cccarto.com/fipscodes/connecticut/files/connecticut-fips-code-map-.gif
drop if fips==44 & fips_neighbor==36 & border==1  //RI counties that "share" border with NY. RI county map: https://www.cccarto.com/fipscodes/rhodeisland/files/rhode-island-fips-code-map.gif
drop if countyfips==22087 & fips_neighbor==28 & border==1  //LA county that "shares" a border with MS. LA county map: https://www.cccarto.com/fipscodes/louisiana/files/louisiana-fips-code-map-.gif
drop if fips==24 & inlist(countyfips_neighbor, 51133, 51193) & border==1  //MD counties that "share" a border with VA. MD county map: https://www.cccarto.com/fipscodes/virginia/files/virginia-fips-code-map.gif
drop if inlist(countyfips, 51133, 51193) & fips_neighbor & border==1  //VA counties that "share" a border with MD. VA county map: https://www.cccarto.com/fipscodes/virginia/files/virginia-fips-code-map.gif

*reshape to have a variable for each border fips 
keep if border==1

gen num_border_counties=1
collapse (sum) num_border_counties, by(fips fips_neighbor border)

ren fips_neighbor border_fips
bysort fips: gen n=_n

reshape wide border_fips num_border_counties, i(fips) j(n)

*create obs for HI and AK
set obs 51

replace fips=2 in 50 
replace fips=15 in 51 
replace border=0 if border==.

sort fips

*****
*Merge in RML data 
*****
*create panel 
gen year=2000
expand 2 

bysort fips: gen n=_n
replace year=2019 if n==2 
drop n 

tsset fips year 
tsfill, full

drop num_border*

foreach i in fips border_fips1 border_fips2 border_fips3 border_fips4 border_fips5 border_fips6 border_fips7 border_fips8  border { //replace missing values 

	egen temp=min(`i'), by(fips)
	replace `i'=temp if `i'==. 
	drop temp
}	

**one by one, merge in policy vars for each "border_fips"
ren fips fips_home

preserve 
use "$path\data\ucr\data\policy\rml-mml_2000-2019.dta", clear 
ren state_fips fips 
tempfile rml 
save `rml'
restore

forval i=1/8 {
	
ren border_fips`i' fips 

merge m:1 fips year using `rml', keepusing(rml)
drop if _merge==2 //AK and HI
drop _merge 

ren (fips rml) (border_fips`i' rml_`i')
}

ren fips_home fips 
sort fips year

*max border rml
egen rml_max=rowmax(rml_1 rml_2 rml_3 rml_4 rml_5 rml_6 rml_7 rml_8)

*RML border var (turns on when first border state adopts RML) 
gen rml_state_border=rml_max 

keep fips year border rml_state_border

ren border state_border
order year, after(fips)

sort fips year

replace rml_state_border=0 if rml_state_border==. // for AK and HI 

*save
tempfile border_rml 
save `border_rml'


****************
**# Analysis Data
****************
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

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

**merge in border state info
merge m:1 fips year using `border_rml'
drop if _merge==2
drop _merge 

gen rml_no_border=rml
replace rml_no_border=1-rml_state_border if (rml_state_border!=0 & rml_state_border!=. & rml!=0 & rml!=.)
gen rml_with_border=rml*rml_state_border
gen no_rml_with_border=rml_state_border
replace no_rml_with_border=1-rml if (rml_state_border!=0 & rml_state_border!=. & rml!=0 & rml!=.)
egen ever_no_rml_with_border=max(no_rml_with_border), by(fips)
replace ever_no_rml_with_border=1 if ever_no_rml_with_border>0 & ever_no_rml_with_border!=.
replace ever_no_rml_with_border=0 if ever_rml==1

label var rml_state_border "Border State RML"


****************
**# Appendix Table 9 
****************
cd "$path\analysis\ucr\tables"

**Panel I: RML 
*c1 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c1 
	
*c2 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c2 	
	
*c3 
reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c3 
	
*c4 
reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c4 	

*c5 
reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c5 
	
*c6 
reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c6	
	
*c7 
reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c7 
	
*c8 
reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c8
	
esttab c1 c2 c3 c4 c5 c6 c7 c8 using "Appendix Table 9.csv", label ///
		title("Appendix Table 9 - Panel 1 ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(2) sefmt(2) sfmt(2 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "" "Non-Marijuana" "" "Property" "" "Violent" "") nogaps se nonotes ///
		page replace  
		est clear 	
	
**Panel II: RML + Border State RML 
*c1 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c1 
	
*c2 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c2 	
	
*c3 
reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c3 
	
*c4 
reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c4 	

*c5 
reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c5 
	
*c6 
reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c6	
	
*c7 
reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="white", a(fips year) vce(cl fips)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c7 
	
*c8 
reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml rml_state_border [pw=pop_1899] if race2=="black", a(fips year) vce(cl fips)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c8
	
esttab c1 c2 c3 c4 c5 c6 c7 c8 using "Appendix Table 9.csv", label ///
		title("Appendix Table 9 - Panel 2 ")  ///
		keep(rml rml_state_border) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(2) sefmt(2) sfmt(2 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "" "Non-Marijuana" "" "Property" "" "Violent" "") nogaps se nonotes ///
		page append 
		est clear

**Panel III: RML + drop states that border an RML but don't have an RML 
*c1 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c1 
	
*c2 
reghdfe rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_total_cannabis_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c2 	
	
*c3 
reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c3 
	
*c4 
reghdfe rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_total_nonmj_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c4 	

*c5 
reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c5 
	
*c6 
reghdfe rate_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_property_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c6	
	
*c7 
reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="white" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="white"
	estadd scalar pdvm = r(mean)
	est store c7 
	
*c8 
reghdfe rate_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol rml [pw=pop_1899] if race2=="black" & ever_no_rml_with_border==0, a(fips year) vce(cl fips)
	sum rate_violent_1899 [aw=pop_1899] if rml==0 & ever_rml==1 & race2=="black"
	estadd scalar pdvm = r(mean)
	est store c8
	
esttab c1 c2 c3 c4 c5 c6 c7 c8 using "Appendix Table 9.csv", label ///
		title("Appendix Table 9 - Panel 3 ")  ///
		keep(rml) ///
		noobs scalars("pdvm Pre-treat DV mean" "N N") bfmt(2) sefmt(2) sfmt(2 0) star(* 0.10 ** 0.05 *** 0.01) ///
		mtitles("Marijuana" "" "Non-Marijuana" "" "Property" "" "Violent" "") nogaps se nonotes ///
		page append 
		est clear 	
	

