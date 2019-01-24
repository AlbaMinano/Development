//Development HW1
/**
Created by: Alba Miñano Mañero
Date: January 2019
Purpose:Compute wealth for Uganda
*/


clear all
set type double
set more off
	

	global mpath "/Users/albaminano/Dropbox/Development/HW1"
	global path "$mpath"
	gl temp "$path/temp"
	gl data "$path/data"
	gl do "$path/do_files"

	
/******************* Household assets *********/

use "$data/GSEC14A.dta", clear

gen  a = . 
replace a = h14q5 if  h14q3 ==1 // only for those who answer yes
replace a= 0 if h14q3==2

bysort HHID: egen assets = sum(a)

collapse ( mean) assets, by (HHID)

rename HHID hh
save "$temp/wealth_temp.dta", replace 

 /******************* Agricultural equipment and HH assets *****/ 
 use "$data/AGSEC10.dta", clear

gen  ag_eq_t = . 
replace ag_eq_t = a10q2 if  a10q1 >0 // only for those who have some item 
replace ag_eq_t= 0 if ag_eq_t == . 

bysort HHID: egen ag_eq = sum(ag_eq_t)

collapse ( mean) ag_eq, by (hh)

merge 1:1 hh using "$temp/wealth_temp.dta"
drop _merge
replace ag_eq = 0 if ag_eq==.
save "$temp/wealth_temp.dta", replace 


/*********** Livestock capital **********/

// Cattle
 use "$data/AGSEC6A.dta", clear

gen  cattle_k_t = . 

// We get the mean selling price 
bysort LiveStockID: egen p = mean(a6aq13b)

replace cattle_k_t = a6aq3a*p if  a6aq3a>0 // only for those who currently own it
replace cattle_k_t= 0 if cattle_k_t== . // Missing values do not have nor own

bysort HHID: egen cattle_k = sum(cattle_k_t)

collapse ( mean) cattle_k, by (hh)

merge 1:1 hh using "$temp/wealth_temp.dta"
drop _merge
replace cattle_k= 0 if cattle_k==.

save "$temp/wealth_temp.dta", replace 


// Small animals 
 use "$data/AGSEC6B.dta", clear

gen  small_k_t = . 

// We get the mean selling price 
bysort ALiveStock_Small_ID: egen p = mean(a6bq14b)

replace small_k_t = a6bq3a*p if  a6bq3a>0 // only for those who currently own it
replace small_k_t= 0 if small_k_t== . // Missing values do not have nor own

bysort HHID: egen  small_k = sum(small_k_t)

collapse ( mean) small_k, by (hh)

merge 1:1 hh using "$temp/wealth_temp.dta"
drop _merge
replace small_k= 0 if small_k==.

save "$temp/wealth_temp.dta", replace 

//  Poultry 
 use "$data/AGSEC6C.dta", clear

gen  poultry_k_t = . 

// We get the mean selling price 
bysort APCode: egen p = mean(a6cq14b)

replace poultry_k_t = a6cq3a*p if  a6cq3a>0 // only for those who currently own it
replace poultry_k_t= 0 if poultry_k_t== . // Missing values do not have nor own

bysort HHID: egen  poultry_k = sum(poultry_k_t)

collapse ( mean) poultry_k, by (hh)

merge 1:1 hh using "$temp/wealth_temp.dta"
drop _merge
replace poultry_k= 0 if poultry_k==.

save "$temp/wealth_temp.dta", replace 

/******************* Agricultural Land value ******************/

 use "$data/AGSEC2B.dta", clear

keep if a2bq9 != . // We don 't want missing prices 

gen size = a2bq4
replace size = a2bq5 if a2bq4 ==.
gen rental_price = a2bq9/size // Rental prices/ acres farmer estimation

rename a2bq14 a2aq16
rename a2bq15 a2aq17
rename a2bq16 a2aq18
rename a2bq17 a2aq19

reg rental_price i.a2aq16 i.a2aq17 i.a2aq18 i. a2aq19  


use "$data/AGSEC2a.dta", clear
predict rental

generate size = a2aq4
replace size = a2aq5 if a2aq4 ==. 
generate ag_land = rental* size 

collapse (sum)  ag_land, by(hh)


merge 1:1 hh using "$temp/wealth_temp.dta"
drop _merge
replace ag_land = 0 if ag_land ==. 

gen wealth = ag_land + small_k + ag_eq + assets
keep hh wealth
save "$temp/wealth.dta", replace 
