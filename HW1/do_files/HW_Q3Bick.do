//Development HW1
/**
Created by: Alba Miñano Mañero
Date: January 2019
Purpose: HW1 Question 3-Bick et al  
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
	
// Data load 	

// We need to get wage per hour
 
 use "$data/GSEC8_1.dta", clear

 // Use question 53 
 
 gen Labor_inc1 = .
 replace h8q31a =  0 if h8q31a ==. 
 replace h8q31b =  0 if h8q31b ==. 
 

gen Lcheck= Labor_inc1
 

 
 foreach var in h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g {
 replace `var' = 0 if `var' == . 
 }
 
 gen totalhours= h8q36a  + h8q36b + h8q36c + h8q36d + h8q36e +h8q36f + h8q36g
 
 rename h8q30a months
 rename h8q30b weeks 
 
 gen hours_hired = months* weeks* totalhours 
 
 gen wage = .
 replace wage = h8q31a + h8q31b if h8q31c == 1
 replace wage = (h8q31a + h8q31b)/ 9 if h8q31c ==2 // they work 9 hours per day
 replace wage = (h8q31a + h8q31b)/ (9*5) if h8q31c== 3 // They work 45 hours per week
 replace wage = (h8q31a + h8q31b)/(4*45) if h8q31c== 4 // Months
 replace wage = 0 if h8q31c == 5
 
 
 replace Labor_inc1 = wage*hours_hired
  replace Labor_inc1 = 0 if Labor_inc1 ==.
 
 // Second ocupation 
 
 gen Labor_inc2 = .
 replace h8q45a =  0 if h8q45a ==. 
 replace h8q45b =  0 if h8q45b ==. 
 
*replace Labor_inc2 = h8q45a + h8q45b // Cash + in kind of main job 
  
 foreach var in h8q43 h8q44 h8q44b {
 replace `var' = 0 if `var' == . 
 }
rename h8q43 totalhours2
 
 rename h8q44 months2
 rename h8q44b weeks2 
 
 gen hours_hired2 = months2* weeks2* totalhours2 
 
 gen wage2 =.
 replace wage2 = h8q45a + h8q45b if h8q45c == 1
 replace wage2 = (h8q45a + h8q45b)/ 9 if h8q45c ==2 // they work 9 hours per day
 replace wage2 = (h8q45a + h8q45b)/ (9*5) if h8q45c== 3 // They work 45 hours per week
 replace wage2 =(h8q45a + h8q45b)/(4*45) if h8q45c== 4 // Months
 replace wage2 = 0 if h8q31c == 5
 
 replace Labor_inc2 = wage2*hours_hired2
 
 replace Labor_inc2 = 0 if Labor_inc2 ==.
 gen Labor_inc = Labor_inc1 + Labor_inc2 //income per year
 
 replace wage = 0 if wage==.
 replace wage2 = 0 if wage2==. 
 
 gen wage_ph= wage + wage2
 
 foreach var  in h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g h8q52_2{
replace `var' = 0 if `var' ==. 
}

 
 gen ls= h8q36a + h8q36b + h8q36c +h8q36d +h8q36f +h8q36g + h8q52_2 // last one is secondary job

 
 keep wage_ph HHID PID Labor_inc ls 
 
 
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
 
 

 
 merge 1:1 HHID PID using "$temp/question3.dta"
 
 

 replace income = income * hsize
 bysort district_code: egen income_d=sum(income)
 
 replace ls = ls*52
 bysort district_code: egen hoursworked=sum(ls)

gen wage_phUSD = wage_ph/3700 // USD
 gen gdp_ph=income_d/hoursworked 
 
 drop if _merge==1
 
 drop _merge
 gen age_sq = age * age
 
 
 bysort district_code: egen pop=sum(wgt_X)
 
 *gen gdp_pc=income/pop
 bysort district_code: egen gdp_pc=mean(income)
 replace gdp_pc = log(gdp_pc)
 
 
 foreach var in ls wage_phUSD income_d gdp_ph{
 generate log_`var' = log(`var')
 }

 label var log_gdp_ph  "($\log$) GDP_{ph}"
 label var log_wage_phUSD "($\log$) W_{ph}"
 
 xi: reg log_ls  log_gdp_ph age age_sq, vce(cluster district_code)
 outreg2 using "$output/Table1a.tex", tex replace ctitle("($\log$)" Hours)/*
*/nocons keep(log_gdp_ph) see label adjr2 addtext (District FE, NO)

 xi: reg log_ls log_wage_phUSD age age_sq, vce(cluster district_code)
  outreg2 using "$output/Table1a.tex", tex append ctitle("($\log$)" Hours)/*
*/nocons keep(log_wage_phUSD) see label adjr2 addtext (District FE, NO)

 
  xi: reg log_ls log_wage_phUSD log_gdp_ph age age_sq, vce(cluster district_code)
  outreg2 using "$output/Table1a.tex", tex append ctitle("($\log$)" Hours)/*
*/nocons keep(log_wage_phUSD log_gdp_ph) see label adjr2 addtext (District FE, NO)


 xi: reg log_ls log_wage_phUSD age age_sq i.district_code, vce(cluster district_code)
   outreg2 using "$output/Table1a.tex", tex append ctitle("($\log$)" Hours)/*
*/nocons keep(log_wage_phUSD log_gdp_ph) see label adjr2 addtext (District FE, YES)

 
 bysort district_code: drop if _N<=28
 generate log_wagetotal = log(Labor_inc/3700)


 
 quietly levelsof district_code, local(district)
  foreach d in `district'{
 xi: reg log_ls  log_wagetotal age age_sq if district=="`d'"
 display "Estimation resuts for the district `d'"

 }
 
 save "$temp/question3bick.dta", replace
 
 
statsby _b, by(district) saving("$temp/mreg_male.dta", replace):  reg log_ls log_wagetotal age age_sq if sex==1
statsby _b, by(district) saving("$temp/mreg_female.dta", replace):  reg log_ls log_wagetotal age age_sq if sex==2

use "$temp/mreg_male.dta", clear


merge 1:m district_code using "$temp/question3bick.dta"

drop _merge

collapse (mean)  _b_log_wagetotal gdp_pc, by(district_code)

 scatter _b_log_wagetotal gdp_pc, yline(0) ///
 , ytitle("beta(w)", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log(Mean income per capita)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_malesLS.png", width(1080) as(png) replace

	
	use "$temp/mreg_female.dta", clear


merge 1:m district_code using "$temp/question3bick.dta"

drop _merge

collapse (mean)  _b_log_wagetotal gdp_pc, by(district_code)

 scatter _b_log_wagetotal gdp_pc, yline(0) ///
 , ytitle("beta(w)", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) ///
	 xtitle("Log(Mean income per capita)", size(medlarge)) ///
	graphregion(color(white))
	graph export "$output/Fig_femalesLS.png", width(1080) as(png) replace


