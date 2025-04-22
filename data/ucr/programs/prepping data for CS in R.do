**********************************************************
*name: prepping data for CS in R.do
*author: Zach Fone (U.S. Air Force Academy)
*description: Data to load into R for CS analysis
**********************************************************
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear 

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

gen temp=year if rml>0 & rml!=.
egen g_rml=min(temp), by(fips)
replace g_rml=0 if g_rml==.
drop temp 

ren (rate_property_1899 rate_violent_1899) (rate_total_property_1899 rate_total_violent_1899)

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

global lea "number_of_months_reported report_share_seer"
global mml_mdl "mml decrim"
global police_econ "lnpolice_percapita unemployment lnpci prop_black prop_hisp"
global drug_pol "samaritan_alc samaritan_drug naloxone pdmp lnbeer"
global sw_pol "lnmw acaexp democrat eitc"

preserve 
keep if race==2
tempfile black
save `black'
saveold "$path\data\ucr\data\analysis_files\rml_black.dta", replace
restore
keep if race==3
tempfile white
save `white'
saveold "$path\data\ucr\data\analysis_files\rml_white.dta", replace

**********
*White 
**********
use `white', clear

reg rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_tot, resid
reg rate_poss_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_poss, resid
reg rate_sale_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_sale, resid
reg rate_total_heroin_coke_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_coc, resid
reg rate_total_synth_narc_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_synth, resid
reg rate_total_other_drug_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_dang, resid
reg rate_total_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_prop, resid
reg rate_total_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_viol, resid
reg rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_nonmj, resid


ren resid_* resid_*_wh
ren pop_1899 popwhite
ren rate_total_*_1899 rate_*_wh
ren (rate_poss_cannabis_1899 rate_sale_cannabis_1899 rate_cannabis_wh) (rate_poss_wh rate_sale_wh rate_tot_wh)
keep fips year resid_* popwhite rate_tot_wh rate_sale_wh rate_poss_wh rate_heroin_coke_wh rate_synth_narc_wh rate_other_drug_wh rate_property_wh rate_violent_wh
tempfile white 
save `white'

**********
*Black/White 
**********
use `black', clear
reg rate_total_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_tot, resid
reg rate_poss_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_poss, resid
reg rate_sale_cannabis_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_sale, resid
reg rate_total_heroin_coke_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_coc, resid
reg rate_total_synth_narc_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_synth, resid
reg rate_total_other_drug_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_dang, resid
reg rate_total_property_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_prop, resid
reg rate_total_violent_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_viol, resid
reg rate_total_nonmj_1899 $lea $mml_mdl $police_econ $drug_pol $sw_pol [pw=pop_1899] 
predict resid_nonmj, resid

ren resid_* resid_*_bl
ren pop_1899 popblack
ren rate_total_*_1899 rate_*_bl
ren (rate_poss_cannabis_1899 rate_sale_cannabis_1899 rate_cannabis_bl) (rate_poss_bl rate_sale_bl rate_tot_bl)
keep fips year g_rml resid_* popblack rate_tot_bl rate_sale_bl rate_poss_bl rate_heroin_coke_bl rate_synth_narc_bl rate_other_drug_bl rate_property_bl rate_violent_bl mml decrim unemployment lnpci report_share_seer
merge 1:1 fips year using `white'
drop _merge

foreach i in resid_tot rate_tot resid_poss rate_poss resid_sale rate_sale resid_coc resid_synth resid_dang resid_prop resid_viol resid_nonmj { 
	gen `i'_bw = `i'_bl - `i'_wh
}
gen popbw=popwhite+popblack



saveold "$path\data\ucr\data\analysis_files\residY.dta", replace


**********
*Sales/No Sales
**********
use "$path\data\ucr\data\analysis_files\ucr_state-year-race_2000-2019_analysis data.dta", clear 

**merge in rml-sales 
merge m:1 fips year using "$path\data\ucr\data\policy\rml-sales_year_2000-2019", keepusing(rml_sales rml_no_sales)
drop if _merge==2
drop _merge 

gen temp=year if rml_no_sales>0 & rml!=.
egen g_rml_no_sales=min(temp), by(fips)
replace g_rml_no_sales=0 if g_rml_no_sales==.
drop temp 

gen temp=year if rml_sales>0 & rml!=.
egen g_rml_sales=min(temp), by(fips)
replace g_rml_sales=0 if g_rml_sales==.
drop temp 

gen same=g_rml_sales==g_rml_no_sales & g_rml_no_sales!=0

gen sales_samp=1
replace sales_samp=0 if inrange(year, g_rml_no_sales, g_rml_sales-1) & g_rml_sales!=0

gen nosales_samp=1 
replace nosales_samp=0 if year>=g_rml_sales & g_rml_no_sales!=0


ren (rate_property_1899 rate_violent_1899) (rate_total_property_1899 rate_total_violent_1899)

*Non-marijuana drug arrest 
gen total_nonmj_1899=total_heroin_coke_1899+total_synth_narc_1899+total_other_drug_1899
gen rate_total_nonmj_1899=(total_nonmj_1899/pop_1899)*100000

gen lnmw=ln(minimum_wage)
gen lnbeer=ln(beer_tax)
gen lnpci=ln(pc_income)

**no sales data 
preserve 
keep if race==2
*drop if same==1 //can't differentiate no sales/sales years
*keep if nosales_samp==1
drop if g_rml_sales!=0
tempfile black
save `black'
saveold "$path\data\ucr\data\analysis_files\rml_black_nosales.dta", replace
restore
preserve
keep if race==3
*drop if same==1 //can't differentiate no sales/sales years
*keep if nosales_samp==1
drop if g_rml_sales!=0
tempfile white
save `white'
saveold "$path\data\ucr\data\analysis_files\rml_white_nosales.dta", replace
restore
**with sales data
preserve 
keep if race==2
*keep if sales_samp==1
drop if g_rml_no_sales!=0 & g_rml_sales==0
tempfile black
save `black'
saveold "$path\data\ucr\data\analysis_files\rml_black_sales.dta", replace
restore
keep if race==3
*keep if sales_samp==1
drop if g_rml_no_sales!=0 & g_rml_sales==0
tempfile white
save `white'
saveold "$path\data\ucr\data\analysis_files\rml_white_sales.dta", replace


