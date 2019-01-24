//Development HW1
/**
Created by: Alba Miñano Mañero
Date: January 2019
Purpose: HW1 Question 3 
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
	
// Preliminary things 

 use "$temp/labor_supply.dta", clear
 drop _merge
*keep if age> 15 & age < 70

 
merge m:m HHID using "$temp/question1.dta" 
drop if _merge == 2
drop if _merge ==1
drop _merge 


save "$temp/question3.dta", replace
 // Compute levels by zone ( i.e district where HH is interviewed)
 

 
 collapse (mean) ls_total consumption income wealth, by (district_code)
 
 foreach var in consumption income wealth {
 replace `var' = log(`var')
 }
 
 preserve
 scatter ls_total consumption, ///
 , ytitle("Mean weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean consumption)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_4a.png", width(1080) as(png) replace
restore

preserve
drop if district_code =="413" // outlier
 scatter ls_total income, ///
 , ytitle("Mean weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean income)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_4b.png", width(1080) as(png) replace
restore

 scatter ls_total wealth ///
 , ytitle("Mean weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean wealth)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_4c.png", width(1080) as(png) replace

/// Part 2: Inequality in ls and district income

use "$temp/question3.dta", clear
*drop if ls_total>15*7 //possible outliers

foreach var in ls_total{

 gen log_`var'=log(`var')
 gen log_`var'_mean=.
 gen vl_`var'=.
 }

 foreach var in ls_total{
 sum log_`var' [w=wgt_X]
 replace log_`var'_mean = r(mean)
 replace vl_`var'=(log_`var'-log_`var'_mean)^2
 }

 collapse (mean) vl_ls_total income wealth consumption, by(district_code)
 
  foreach var in income wealth consumption {
  replace `var' = log(`var')
  }
 
 scatter vl_ls_total consumption  || lfit vl_ls_total consumption, ///
 , ytitle("Mean var log weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log(Mean consumption)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_5a.png", width(1080) as(png) replace


preserve
drop if district_code =="413"
 scatter vl_ls_total income if income<5000 || lfit vl_ls_total income, ///
 , ytitle("Mean var log weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean income)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_5b.png", width(1080) as(png) replace
restore


 scatter vl_ls_total wealth || lfit vl_ls_total wealth ///
 , ytitle("Mean var log weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean wealth)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_5c.png", width(1080) as(png) replace
	
/// Question 3 : correlations agains mean income 
use "$temp/question3.dta", clear


levelsof district_code, local(district)
bysort district: correlate income ls_total

*ssc install egenmore
egen corr_inc = corr(income ls_total) , by(district)
egen corr_wealth = corr(wealth ls_total) , by(district)
egen corr_cons = corr(consumption ls_total) , by(district)

collapse (mean) corr_inc corr_wealth corr_cons income wealth consumption, by(district_code)

foreach var in consumption income wealth {
 replace `var' = log(`var')
 }
 
 scatter corr_inc income  || lfit corr_inc income ///
 , ytitle("Corr income-weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean income)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_6a.png", width(1080) as(png) replace

	preserve 
	drop if district_code=="413"
 scatter corr_wealth income || lfit corr_wealth income, ///
 , ytitle("Corr wealth-weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean income)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_6b.png", width(1080) as(png) replace
restore

 scatter corr_cons income || lfit corr_inc income ///
 , ytitle("Corr consumption- weekly hours", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log (Mean income)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_6c.png", width(1080) as(png) replace
