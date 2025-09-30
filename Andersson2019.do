use 8963_data, clear

tsset Countryno year

///// Table 1 + 2, Figure 4 /////

synth CO2_transport_capita ///
GDP_per_capita gas_cons_capita vehicles_capita urban_pop ///
CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
trunit(13) trperiod(1990) ///
xperiod(1980(1)1989) ///
mspeperiod(1960(1)1989) ///
margin(.01) maxiter(999999) ///
figure keep("synth_data") nested replace

graph export figure4.png, replace

ereturn list
matrix V_matrix = e(V_matrix)
matrix list V_matrix
matrix table1 = e(X_balance)
matrix list table1
matrix table2 = e(W_weights)
matrix list table2


///// Figure 5 /////
rename year _time
drop if Countryno!=13
merge 1:1 _time using synth_data`country'
gen gap = _Y_treated - _Y_synthetic
twoway (line gap _time, sort lcolor(black)) || ///
(function y=0, range(_time) lcolor(gray) lwidth(med) lpattern(dash)), ///
legend(off)

graph export figure5.png, replace


///// Figure 7 Apppend Data /////
foreach country of numlist 1/14 {
	use  8963_data, clear
	tsset Countryno year
	
	synth CO2_transport_capita ///
	GDP_per_capita gas_cons_capita vehicles_capita urban_pop ///
	CO2_transport_capita(1989) CO2_transport_capita(1980) CO2_transport_capita(1970), ///
	trunit(`country') trperiod(1990) ///
	xperiod(1980(1)1989) ///
	mspeperiod(1960(1)1989) ///
	keep("synth_data`country'") nested replace
	
	keep if Countryno == `country'
	rename year _time
	merge 1:1 _time using synth_data`country'
	gen gap = _Y_treated - _Y_synthetic
	save x`country', replace
	
}

use "x1.dta"
forvalues i = 2/14 {
	append using "x`i'.dta"
}


///// Figure 7 Graph /////
twoway (line gap _time if Countryno==1, lcolor(gs8) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==2, lcolor(cyan) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==3, lcolor(cranberry) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==4, lcolor(emidblue) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==5, lcolor(dknavy) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==6, lcolor(sandb) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==7, lcolor(teal) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==8, lcolor(yellow) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==9, lcolor(eltblue) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==10, lcolor(emerald) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==11, lcolor(blue) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==12, lcolor(mint) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==13, lcolor(gold) lwidth(med) lpattern(solid)) ///
       (line gap _time if Countryno==14, lcolor(purple) lwidth(med) lpattern(solid)) ///
       (function y = 0, range(1960 2005) lcolor(red) lwidth(medium) lpattern(dash)) ///
    , legend(order(1 2 3 4 5 6 7 8 9 10 11 12 13 14) ///
             label(1 "Australia") ///
             label(2 "Belgium") ///
             label(3 "Canada") ///
             label(4 "Denmark") ///
             label(5 "France") ///
             label(6 "Greece") ///
             label(7 "Iceland") ///
             label(8 "Japan") ///
             label(9 "New Zealand") ///
             label(10 "Poland") ///
             label(11 "Portugal") ///
             label(12 "Spain") ///
             label(13 "Sweden") ///
             label(14 "Switzerland")) ///
    title("Overlay of Gap Lines by Country") ///
    xtitle("Time") ///
    ytitle("Gap") ///
    graphregion(color(white)) ///
    xline(1990, lcolor(black) lwidth(medium) lpattern(dash))



///// Figure 8 /////

use "aggregated_x.dta", clear

gen gap2=gap^2

bysort Countryno: egen pre_mspe=mean(gap2) if _time < 1990
bysort Countryno: egen post_mspe=mean(gap2) if _time >= 1990

collapse pre_mspe post_mspe, by(country)
bysort country: gen mspe_ratio = post_mspe/pre_mspe

tempfile sorted_data
sort mspe_ratio
save `sorted_data'

use `sorted_data', clear
graph bar mspe_ratio, over(country, gap(0)) ///
horizontal ///
title("Post-MSPE to Pre-MSPE Ratio by Country") ///
ytitle("Ratio") ///
blabel(bar, size(med)) ///
graphregion(color(white)) ///
bar(1, lcolor(black))

graph export figure8.png



