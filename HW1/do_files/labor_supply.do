//Development HW1
/**
Created by: Alba Miñano Mañero
Date: January 2019
Purpose: Labour supply 
*/


clear all
set type double
set more off
	

	global mpath "/Users/albaminano/Dropbox/Development/HW1"
	global path "$mpath"
	gl temp "$path/temp"
	gl data "$path/data"
	gl do "$path/do_files"
	gl output "$path/output"

	
/************ Agricultural Labour supply **************/
//Preliminary: generate HHID in family roster to do merge

use "$data/GSEC2.dta", clear

 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID
 
  replace PID = subinstr(PID, "P00", "", .)
 replace PID = subinstr(PID, "-", "", .)
 replace PID=subinstr(PID, "P0", "", .)
  replace PID=subinstr(PID, "P", "", .)
 destring PID, gen(pid)
 drop PID
 rename pid PID

 save "$temp/roster_HHID.dta", replace
 
/// 
use "$data/UNPS 2013-14 Consumption Aggregate.dta", clear

 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID
 
 save "$temp/roster_HHID2.dta", replace
// First visit 

use "$data/AGSEC3A.dta", clear

 
keep if a3aq33	>0 & a3aq33 !=. // We keep only who report that some family member worked on the plot


replace a3aq33a_1 = 0 if a3aq33a_1 ==. 
replace a3aq33b_1 = 0 if a3aq33b_1 ==. 
replace a3aq33c_1 = 0 if a3aq33c_1 ==. 
replace a3aq33d_1 = 0 if a3aq33d_1 ==. 
replace a3aq33e_1 = 0 if a3aq33e_1 ==. 

foreach var in a3aq33a_1 a3aq33b_1 a3aq33c_1 a3aq33d_1 a3aq33e_1 {
replace `var' = `var'*8 // Assume each worked 8 hrs  per day
}

keep HHID a3aq33* plotID parcelID
drop a3aq33

rename a3aq33a a1
rename a3aq33b a2
rename a3aq33c a3
rename a3aq33d a4
rename a3aq33e a5

rename a3aq33a_1 b1
rename a3aq33b_1 b2
rename a3aq33c_1 b3
rename a3aq33d_1 b4
rename a3aq33e_1 b5


foreach var of varlist _all {
replace `var' = 0 if `var'==.
}

 egen id =group(HHID parcelID plotID)


reshape long a b, i(id) j(pid)

keep HHID pid a b
 rename a PID
 
collapse (sum) b, by(HHID PID) 
drop if PID==0


merge 1:1 HHID PID using "$temp/roster_HHID.dta"

keep if _merge==3
 keep if h2q4 == 1 
 rename h2q8 age 
 rename h2q3 sex
 
 keep HHID PID age sex b 
 rename b ls_ag1
 

save "$temp/ls_ag.dta", replace 

// Second visit 

use "$data/AGSEC3B.dta", clear


	
keep if a3bq33	>0 & a3bq33 !=. // We keep only who report that some family member worked on the plot

replace a3bq33a_1 = 0 if a3bq33a_1 ==. 
replace a3bq33b_1 = 0 if a3bq33b_1 ==. 
replace a3bq33c_1 = 0 if a3bq33c_1 ==. 
replace a3bq33d_1 = 0 if a3bq33d_1 ==. 
replace a3bq33e_1 = 0 if a3bq33e_1 ==. 
foreach var in a3bq33a_1 a3bq33b_1 a3bq33c_1 a3bq33d_1 a3bq33e_1 {
replace `var' = `var'*8 // Assume each worked 8 hrs  per day
}

keep HHID a3bq33* plotID parcelID
drop a3bq33

rename a3bq33a a1
rename a3bq33b a2
rename a3bq33c a3
rename a3bq33d a4
rename a3bq33e a5
rename a3bq33a_1 b1
rename a3bq33b_1 b2
rename a3bq33c_1 b3
rename a3bq33d_1 b4
rename a3bq33e_1 b5


foreach var of varlist _all {
replace `var' = 0 if `var'==.
}

 egen id =group(HHID parcelID plotID)


reshape long a b, i(id) j(pid)

keep HHID pid a b
 rename a PID
 
collapse (sum) b, by(HHID PID) 
drop if PID==0


merge 1:1 HHID PID using "$temp/roster_HHID.dta"

keep if _merge==3
 keep if h2q4 == 1 
 rename h2q8 age 
 rename h2q3 sex
 
 keep HHID PID age sex b 
 rename b ls_ag2
 
 merge 1:1 HHID PID using "$temp/ls_ag.dta"
 
 foreach var of varlist _all {
 replace `var' = 0 if `var'==.
 }
 drop _merge
 gen ls_ag=(ls_ag1+ls_ag2)/52
 
 
save "$temp/ls_ag.dta", replace 

// Non agricultural labour supply 

use "$data/GSEC8_1.dta", clear

keep HHID PID h8q36* h8q52_2

foreach var  in h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g h8q52_2{
replace `var' = 0 if `var' ==. 
}

gen ls= h8q36a + h8q36b + h8q36c +h8q36d +h8q36f +h8q36g + h8q52_2 // last one is secondary job


merge 1:1 HHID PID using "$data/GSEC2.dta"
keep if _merge==3
 keep if h2q4 == 1 
 rename h2q8 age 
 rename h2q3 sex
 
 keep HHID PID ls age sex h2q4

  replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID
 
  replace PID = subinstr(PID, "P00", "", .)
 replace PID = subinstr(PID, "-", "", .)
 replace PID=subinstr(PID, "P0", "", .)
  replace PID=subinstr(PID, "P", "", .)
 destring PID, gen(pid)
 drop PID
 rename pid PID
 
 merge 1:1 HHID PID using "$temp/ls_ag.dta"
drop _merge
 foreach var of varlist _all {
 replace `var' = 0 if `var'==. 
 }
 
 gen ls_total=ls_ag+ls

 // Merge with consumption to get urban rural
 

  merge m:m HHID using "$temp/roster_HHID2.dta"
  
  save  "$temp/labor_supply.dta", replace
  
  
