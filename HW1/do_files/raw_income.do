//Development HW1
/**
Created by: Alba Miñano Mañero
Date: January 2019
Purpose:Compute income for Uganda
*/


clear all
set type double
set more off
	

	global mpath "/Users/albaminano/Dropbox/Development/HW1"
	global path "$mpath"
	gl temp "$path/temp"
	gl data "$path/data"
	gl do "$path/do_files"
	
/**************** Agricultural net production *******/

// Crops 
 
 use "$data/AGSEC5A.dta", clear
 drop if cropID==.
 
 keep HHID parcelID plotID cropID a5aq6a a5aq6b a5aq6c a5aq6d a5aq16 a5aq7a a5aq7b a5aq7c a5aq7d a5aq8 a5aq10 a5aq5_2
 drop if a5aq6a==. & a5aq6d==. & a5aq16==. & a5aq7a==. & a5aq7d==. & a5aq8==. & a5aq10==. & a5aq5_2 ==2 // No revenue but crop was mature
 
 // Make sure weights are the same
 replace a5aq7d = a5aq6d if  a5aq6b == a5aq7b & a5aq6c== a5aq7c & a5aq6d != a5aq7d
 
 
 // Harvested crop
 
 gen harvest_t = .
 replace harvest_t = a5aq6a*a5aq6d if a5aq6d!=.
 replace harvest_t  = a5aq6a if a5aq6c==1


 
 // Sales of crops 
 gen sold_harvest_t = .
 replace sold_harvest_t = a5aq7a*a5aq7d if a5aq7d!=.
 replace sold_harvest_t = 0 if a5aq7a==0 
 replace sold_harvest_t = 0 if a5aq7a==. 
 replace sold_harvest_t = a5aq7a if a5aq7c==1
 
 gen net =  harvest_t - sold_harvest_t
 
 replace sold_harvest_t=harvest_t if net<0

 
 bysort HHID cropID: egen sold_harvest = sum(sold_harvest_t) //quantity sold by HH and crop
 bysort HHID cropID: egen harvest = sum(harvest_t) //quantity by HH and crop
 
 
 bysort HHID cropID: egen sold_harvest_tt = sum(a5aq8) //revenue by HH and crop

 gen Price_crop_t = (sold_harvest_tt/sold_harvest)
 bysort cropID: egen Price_crop = mean(Price_crop_t)
 
// value of kept crops 
 gen retained_crop = Price_crop*(harvest - sold_harvest) //46 missings due to P==.
 
  replace retained_crop = 0 if retained_crop== . 
 replace sold_harvest_tt = 0 if sold_harvest_tt == . 


 // Need to subtract Costs
 //Transportation costs
 bysort HHID cropID: gen transport_costs = a5aq10 
 
 replace transport_costs = 0 if transport_costs ==. 
 
 collapse (mean)retained_crop transport_costs sold_harvest_tt, by(HHID cropID) 
 collapse (sum) retained_crop transport_costs sold_harvest_tt, by(HHID) 
 save "$temp/temp.dta", replace
 
 //Land rents
 use "$data/AGSEC2B.dta", clear
 bysort HHID parcelID: gen land_rents = a2bq9
 
 replace land_rents = 0 if land_rents==.
 
 collapse (sum) land_rents, by(HHID)
 merge 1:1 HHID using "$temp/temp.dta"
 drop _merge
 save "$temp/temp.dta", replace

 // Hired labor
 use "$data/AGSEC3A.dta", clear
 bysort HHID parcelID plotID: gen labor = a3aq36
 replace labor = 0 if labor==. 
 
 
 // Pesticides and fertilizers
 bysort HHID parcelID plotID: gen fert1 = a3aq8 

 bysort HHID parcelID plotID: gen fert2 = a3aq18 

 bysort HHID parcelID plotID: gen fert3 = a3aq27 
 
 
 replace fert1 = 0 if fert1 ==. 
 replace fert2 = 0 if fert2==. 
 replace fert3 = 0 if fert3 ==. 
 
 collapse (sum) labor fert*, by(HHID)
 merge 1:1 HHID using "$temp/temp.dta"
 drop _merge
 
  foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 save "$temp/temp.dta", replace
 
 *** Seeds
 use "$data/AGSEC4A.dta", clear
 bysort HHID parcelID plotID cropID: gen seeds = a4aq15 
replace seeds = 0 if seeds ==. 
 collapse (sum) seeds, by(HHID)
 merge 1:1 HHID using "$temp/temp.dta"
 drop _merge
 
  foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 save "$temp/temp.dta", replace

 gen ag_net_prod = retained_crop + sold_harvest_tt - transport_costs - land_rents - labor - fert1 - fert2 - fert3 - seeds
 save "$temp/temp.dta", replace
 

 /********* Livestock ***********/
 
 ** Other costs
 use "$data/AGSEC7.dta", clear
 
 keep if a7aq1 == 1 // we keep only those who hown or raise cattle
 bysort HHID: egen LS_oc7 = sum(a7bq2e) 
 bysort HHID: egen LS_oc8 = sum(a7bq3f) 
 bysort HHID: egen LS_oc9 = sum(a7bq5d) 
 bysort HHID: egen LS_oc10 = sum(a7bq6c) 
 bysort HHID: egen LS_oc11 = sum(a7bq7c) 
 bysort HHID: egen LS_oc12 = sum(a7bq8c) 
 gen LS_oc = LS_oc7 + LS_oc8 + LS_oc9 + LS_oc10 + LS_oc11 + LS_oc12
 

 collapse (mean) LS_oc, by(HHID)
 save "$temp/temp_ls.dta", replace
 
 ** Cattle
 use "$data/AGSEC6A.dta", clear
 keep if a6aq2 != 2 & a6aq3a != 0 & a6aq3a != . // We keep only those who own 
 gen cattle = a6aq14a*a6aq14b  if a6aq14a !=. & a6aq14a != 0  & a6aq14b !=. & a6aq14b !=0 
 //revenues = quantity * revenue by unit. Only for those who sell and report vale
 replace cattle = 0 if cattle ==.
 

 // Labor costs
 gen labor_c = . 
 replace labor_c = a6aq5c if a6aq5c >0 & a6aq5c != . 
 replace labor_c = 0 if labor_c ==. 
 
 collapse (sum) cattle (mean) labor_c, by(HHID)
 merge 1:1 HHID using "$temp/temp_ls.dta"
 
 replace cattle = 0 if cattle==. 
 replace labor_c = 0 if labor_c==.
 drop _merge
 save "$temp/temp_ls.dta", replace
 
 ** Small animals
 use "$data/AGSEC6B.dta", clear
  keep if a6bq2 != 2 & a6bq3a != 0 & a6bq3a != . // We keep only those who own 
  
 gen small =. 
 replace small = a6bq14a*a6bq14b  if a6bq14a !=. & a6bq14a != 0  & a6bq14b !=. & a6bq14b !=0 //revenues = quantity * revenue by unit
 replace small = 0 if small==.
 
 gen labor_s = . 
 replace labor_s = a6bq5c if a6bq5c >0 & a6bq5c != . 
 replace labor_s = 0 if labor_s ==. 
 
 collapse (sum) small (mean) labor_s, by(HHID)
 merge 1:1 HHID using "$temp/temp_ls.dta"
 drop _merge
 replace small = 0 if small ==.
 replace labor_s = 0 if labor_s ==.
 save "$temp/temp_ls.dta", replace

 ** Rabbits
 use "$data/AGSEC6C.dta", clear
   keep if a6cq2 != 2 & a6cq3a != 0 & a6cq3a != . // We keep only those who own 
  
 gen rabbits =.
 replace rabbits = a6cq14a*a6cq14b if a6cq14a !=. & a6cq14a != 0  & a6cq14b !=. & a6cq14b !=0
 //revenues = quantity * revenue by unit
 replace rabbits = 0 if a6cq14a==0
 
 gen labor_r = . 
 replace labor_r = a6cq5c if a6cq5c >0 & a6cq5c != . 
 replace labor_r = 0 if labor_r ==. 
 
 collapse (sum) rabbits (mean) labor_r, by(HHID)
 merge 1:1 HHID using "$temp/temp_ls.dta"
 replace rabbits = 0 if rabbits ==.
 replace labor_r = 0 if labor_r==.
 replace small = 0 if small ==. 
 replace labor_s = 0 if labor_s==.
 replace labor_c = 0 if labor_c ==. 
 replace cattle = 0 if cattle==. 
 replace LS_oc = 0 if LS_oc ==. 
 drop _merge
 

 gen Livestock = cattle + rabbits + small - labor_c - labor_r -labor_s - LS_oc
 save "$temp/temp_ls.dta", replace
 
 
 /********** Livestock product *************/
 
 // Meat
 use "$data/AGSEC8A.dta", clear

 gen Price_meat_t= .
 replace Price_meat_t = a8aq5/a8aq3 if a8aq1 != 0 & a8aq5 != 0 & a8aq5 !=. & a8aq3 != 0 & a8aq3 !=.
 
 //price = revenue/quantity only for those who slaughtered for meat, sell and report revenue
 bysort AGroup_ID: egen Price_meat = mean(Price_meat_t)

 gen meat =. 

 replace meat = Price_meat*((a8aq1*a8aq2)-a8aq3) + a8aq5 if a8aq5 !=. 
 replace meat = Price_meat *((a8aq1*a8aq2)-a8aq3) if a8aq5 == . 
 replace meat = a8aq5 if  ((a8aq1*a8aq2)-a8aq3) == 0 & a8aq5 !=.
 
 // Ones with missing meat have not slaughtered for meat. 
 replace meat = 0 if meat ==.
 collapse (sum) meat, by(HHID)
 save "$temp/temp_lsp.dta", replace

 ///
 ** Milk
 use "$data/AGSEC8B.dta", clear
gen Price_milk_t = .

// Everything is dayly wo we need to convert  to months
// For those who report selling daily more than average production, sales = production
gen daily_milk_prod = a8bq1* a8bq3 
replace daily_milk_prod = 0 if daily_milk_prod==.


replace a8bq5_1 = daily_milk_prod if a8bq5_1 > daily_milk_prod & a8bq5_1 != 0 & a8bq5_1 !=.
 // 7 people report selling more milk than they produce dayly. 
 
 replace a8bq7 = 0 if a8bq6==0 | a8bq6==.
 replace a8bq7 = a8bq6 if a8bq7>a8bq6 // For those who report selling more than they convert per day

 // Check for outliers and do something with them 

 replace a8bq5_1= daily_milk_prod if daily_milk_prod< a8bq5 & a8bq5_1 != 0 & a8bq9 != 0 & a8bq9 != . & a8bq6==0
  replace a8bq5 = 0 if daily_milk_prod< a8bq5 & a8bq5_1 != 0 & a8bq9 != 0 & a8bq9 != .


 // We need to get yearly sales of milk and dairy
 
replace a8bq5_1 = a8bq5_1 *30 * a8bq2


replace a8bq7 = a8bq7 * 30 *a8bq2


replace a8bq7 = 0 if a8bq5_1== a8bq1*a8bq2*30*a8bq3
 
replace Price_milk_t = a8bq9/(a8bq5_1+a8bq7) if a8bq1 != 0 & a8bq5_1 != 0 & a8bq5_1 !=.  & a8bq9 != 0 & a8bq9 !=.| a8bq1 != 0 & a8bq6 != 0 & a8bq6 != . & a8bq7 != 0 & a8bq7 !=. & a8bq9 != 0 & a8bq9 !=.
 

 //revenue/(quantity milk + quantity dairy) for those who milked, sold and earned or milked, converted to dairy, sold and earn. 
 bysort AGroup_ID: egen Price_milk = mean(Price_milk_t)
 
 replace a8bq2 = a8bq2*30 //Days were milked 
 gen Milk = a8bq1*a8bq2*a8bq3 //liters of milk = quantity cows * days * avg day production
 replace Milk = 0 if Milk ==. 

 gen milk = .
 replace a8bq7 = 0 if a8bq7 ==. 
 replace a8bq5_1 = 0 if a8bq5_1==. 
 gen net = (Milk-(a8bq5_1+a8bq7))
replace milk = Price_milk*(Milk-(a8bq5_1+a8bq7)) + a8bq9 if a8bq9 != . 
 replace milk = Price_milk*(Milk-(a8bq5_1+a8bq7)) if a8bq9 ==. 
 replace milk = a8bq9 if Milk-(a8bq5_1+a8bq7) == 0 &  a8bq9 != .  
 
 collapse (sum) milk, by(HHID)
 merge 1:1 HHID using "$temp/temp_lsp.dta"
 drop _merge
 replace milk=0 if milk==.
 save "$temp/temp_lsp.dta", replace
 
 ** Eggs
 use "$data/AGSEC8C.dta", clear 
 
 
 replace a8cq2 = a8cq2*4 //quantity eggs by year
 replace a8cq3 = a8cq3*4 //quantity sold by year
 replace a8cq5 = a8cq5*4 //revenue by year

 replace a8cq3=a8cq2 if a8cq3 >a8cq2
 
 gen Price_eggs_t = a8cq5/a8cq3 if a8cq1 != 0 & a8cq1 != 0 & a8cq2 !=. & a8cq2 !=0 
 
 bysort AGroup_ID: egen Price_eggs = mean(Price_eggs)

 gen Eggs =.
replace Eggs = Price_eggs*(a8cq2 - a8cq3) + a8cq5 if a8cq5 !=. 
 replace Eggs = Price_eggs*(a8cq2 - a8cq3) if a8cq5==. 
 
 
 // People with missing eggs have no animals with eggs
 replace Eggs=0 if Eggs==. 
 
 collapse (sum) Eggs, by(HHID)
 merge 1:1 HHID using "$temp/temp_lsp.dta"
 drop _merge
  foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 save "$temp/temp_lsp.dta", replace
 
 ** Dung
 use "$data/AGSEC11.dta", clear
 
 replace a11q1c = 0 if a11q1c==. 
 replace a11q5 = 0 if a11q5==.
 gen dung = a11q1c + a11q5 //revenues dung + revenues ploughing
  
 collapse (sum) dung, by(HHID)
 merge 1:1 HHID using "$temp/temp_lsp.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }

 gen Ls_product = meat + milk + Eggs + dung
 
 
 save "$temp/temp_lsp.dta", replace
 
 
 /* Renting in agricultural equipment and capital*/
 use "$data/AGSEC10.dta", clear
 
 rename a10q8 rentals //value rentals
 collapse (sum) rentals, by(HHID)
   
 merge 1:1 HHID using "$temp/temp.dta"
 drop _merge
 
 merge 1:1 HHID using "$temp/temp_ls.dta"
 drop _merge

 merge 1:1 HHID using "$temp/temp_lsp.dta"
 drop _merge 
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 gen Total_ANP = ag_net_prod + Livestock + Ls_product - rentals
 
 save "$temp/Total_ANP.dta", replace
 
 /////////////////////////////////////////////////////////////////////////////
 ************************************************************************************ 
 
 * Labor market income
 use "$data/GSEC8_1.dta", clear

 // Use question 53 
 
 gen Labor_inc1 = .
 replace h8q31a =  0 if h8q31a ==. 
 replace h8q31b =  0 if h8q31b ==. 
 
 
 
*replace Labor_inc1 = h8q31a + h8q31b // Cash + in kind of main job 
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
 replace Labor_inc = 0 if Labor_inc==. 
 collapse (sum) Labor_inc Labor_inc1 Labor_inc2, by(HHID)
 save "$temp/Labor_inc.dta", replace

 ////////////////////////////////////
 ************************************************************************************ 
 
 * Business income
 use "$data/gsec12.dta", clear
 rename hhid HHID
 
 replace h12q13 = 0 if h12q13 ==. 
 replace h12q16= 0 if h12q16==.
 replace h12q17 = 0 if h12q17 ==. 
 
 gen Bss_inc = .
 replace Bss_inc = h12q13 //month gross revenue
 replace Bss_inc= 0 if Bss_inc ==. 
 gen Bss_labor_cost = .
 replace Bss_labor_cost = h12q15 //month labor costs
 replace Bss_labor_cost= 0 if Bss_labor_cost ==.
 gen Bss_raw_cost = .
 replace Bss_raw_cost = h12q16 + h12q17 //month expenditure raw materials + others
 
 gen Bss_inc_y = (Bss_inc - Bss_labor_cost - Bss_raw_cost)*h12q12 //business income per year (ignore VAT)
 
 collapse (sum) Bss_inc_y, by(HHID)
 save "$temp/Bss_inc.dta", replace
 
 
 //
 ************************************************************************************ 
 
 * Other income sources
 use "$data/GSEC11A.dta", clear
 
 replace h11q5 = 0 if h11q5 ==. 
 replace h11q6 = 0 if h11q6 ==. 
 
 gen Other_inc = h11q5 + h11q6   
  
 collapse (sum) Other_inc, by(HHID)
 save "$temp/Other_inc.dta", replace

  
 merge 1:1 HHID using "$temp/Labor_inc.dta"
 drop _merge
  
 merge 1:1 HHID using "$temp/Bss_inc.dta"
 drop _merge

  
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID

 merge 1:1 HHID using "$temp/Total_ANP.dta"
 drop _merge 
 save "$temp/income.dta", replace



 
 /************** Agricultural second visit****/
 
 
 
// Crops 
 
 use "$data/AGSEC5B.dta", clear
 drop if cropID==.
 
 keep HHID parcelID plotID cropID a5bq6a a5bq6b a5bq6c a5bq6d a5bq16 a5bq7a a5bq7b a5bq7c a5bq7d a5bq8 a5bq10 a5bq5_2
 drop if a5bq6a==. & a5bq6d==. & a5bq16==. & a5bq7a==. & a5bq7d==. & a5bq8==. & a5bq10==. & a5bq5_2==2 // if no revenue but mature
 
 
  // Make sure weights are the same
 replace a5bq6d = a5bq7d if  a5bq6b == a5bq7b & a5bq6c== a5bq7c & a5bq6d != a5bq7d
 // Harvested crop
 gen harvest_t2 = .
 replace harvest_t2 = a5bq6a*a5bq6d if a5bq6d!=.
 replace harvest_t2  = a5bq6a if a5bq6c==1
 
 
 // Sales of crops 
 gen sold_harvest_t2 = .
 replace sold_harvest_t2 = a5bq7a*a5bq7d if a5bq7d!=.
 replace sold_harvest_t2 = 0 if a5bq7a==0
 
 
  replace sold_harvest_t2 = 0 if a5bq7a==0 
 replace sold_harvest_t2 = 0 if a5bq7a==. 
 replace sold_harvest_t2 = a5bq7a if a5bq7c==1
 
 gen net =  harvest_t2 - sold_harvest_t2
 
 replace sold_harvest_t2=harvest_t2 if net<0
 bysort HHID cropID: egen sold_harvest2 = sum(sold_harvest_t2) //quantity sold by HH and crop
  bysort HHID cropID: egen harvest2 = sum(harvest_t2) //quantity by HH and crop
  
 bysort HHID cropID: egen sold_harvest_tt2 = sum(a5bq8) //revenue by HH and crop

 gen Price_crop_t2 = (sold_harvest_t2/sold_harvest2)
 bysort cropID: egen Price_crop2 = mean(Price_crop_t2)
 
// value of kept crops 
 gen retained_crop2 = Price_crop2*(harvest2 - sold_harvest2)  //46 missings due to P==.
 
 replace retained_crop2 = 0 if retained_crop2 == . 
 replace sold_harvest_tt2 = 0 if sold_harvest_tt2 == . 

 // Need to subtract Costs
 //Transportation costs
 bysort HHID cropID: gen transport_costs2 = a5bq10 
 
 replace transport_costs2 = 0 if transport_costs2==. 
 
 collapse (mean)retained_crop2 transport_costs2 sold_harvest_tt2, by(HHID cropID) 
 collapse (sum) retained_crop2 transport_costs2 sold_harvest_tt2, by(HHID) 
 save "$temp/temp_second.dta", replace
 
 //Land rents are given as annual 

 // Hired labor
 use "$data/AGSEC3B.dta", clear
 bysort HHID parcelID plotID: gen labor2 = a3bq36
 replace labor2= 0 if labor2==. 
 // Pesticides and fertilizers
 bysort HHID parcelID plotID: gen fert1_2 = a3bq8 

 bysort HHID parcelID plotID: gen fert2_2 = a3bq18 

 bysort HHID parcelID plotID: gen fert3_2 = a3bq27 
 
 replace fert1_2 = 0 if fert1_2 == . 
 replace fert2_2 = 0 if fert2_2 == . 
 replace fert3_2 = 0 if fert3_2 == . 
 
 
 collapse (sum) labor2 fert*, by(HHID)
 merge 1:1 HHID using "$temp/temp_second.dta"
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 
 drop _merge
 save "$temp/temp_second.dta", replace
 
 *** Seeds
 use "$data/AGSEC4B.dta", clear
 bysort HHID parcelID plotID cropID: gen seeds2 = a4bq15 

 replace seeds2 = 0 if seeds2 ==. 
 collapse (sum) seeds, by(HHID)
 merge 1:1 HHID using "$temp/temp_second.dta"
 drop _merge
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 save "$temp/temp_second.dta", replace

 gen ag_net_prod2 = retained_crop2 + sold_harvest_tt2 - transport_costs2 - labor2 - fert1_2 - fert2_2 - fert3_2 - seeds2
 
 // Merge with previous data to get annual income 
  merge 1:1 HHID using "$temp/income.dta" // People who do not merge is because they have no ANP in second visit
  
  
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 generate income = ag_net_prod2 + Total_ANP + Labor_inc + Bss_inc_y + Other_inc
  
  
 drop _merge 
  save "$temp/income.dta", replace
  
 // We need to add transfers 
 
  /// Add transfers to icome section 15 received in kind free. question 10 and 11
  
 use "$data/GSEC15B.dta", clear
replace h15bq11 = 0 if h15bq11 ==. 

bysort HHID: egen transfers=sum(h15bq11)

 collapse (mean) transfers, by(HHID) 
 
  replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID
 
 merge 1:1  HHID using "$temp/income.dta"
 
 keep income HHID

 save "$temp/income.dta", replace
 
 
