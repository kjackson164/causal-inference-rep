/////// TABLE 1 ///////

*** NSW/Lalonde
use nsw.dta, clear
tabstat age education black hispanic married nodegree re75, by(treat) stats(mean semean)

*** RE74 subset
use nsw_dw.dta, clear
tabstat age education black hispanic married nodegree re74 re78, by(treat) stats(mean semean)

*** Comparison subset
local ne_data psid_controls psid_controls2 psid_controls3 cps_controls cps_controls2 cps_controls3

foreach data of local ne_data{
	use `data', clear
	quietly gen m=0
	append using nsw_dw
	quietly replace m=1 if treat==1
	
	matrix `data'_tab1 = J(2,8,0)
	matrix rowname `data'_tab1 = means SE
	matrix colname `data'_tab1 = age education black hispanic nodegree married re74 re75
	local i=1
	foreach c of varlist age education black hispanic nodegree married re74 re75 {
		quietly ttest `c', by(m)
		matrix `data'_tab1[1,`i'] = r(mu_1)
		matrix `data'_tab1[2,`i'] = r(se)
		local ++i
	}
	matrix list `data'_tab1
}

/////// TABLE 2 ///////

foreach panel in A B C {
	local ne_data psid_controls psid_controls2 psid_controls3 cps_controls cps_controls2 cps_controls3
	foreach data of local ne_data {
		matrix `data'_tab2`panel' = J(2,4,0)
		matrix rowname `data'_tab2`panel' = t_effect SE
		matrix colname `data'_tab2`panel' = col1 col2 col3 col4
		
		if "`panel'" == "A" use nsw, clear 
		else use nsw_dw, clear
		
		if "`data'" != "nsw" {
			quietly drop if treat==0
			quietly append using `data'
		}
		quietly gen age2 = age*age
		
		* Column 1
		quietly reg re78 treat 
		matrix `data'_tab2`panel'[1,1] = _b[treat]
		matrix `data'_tab2`panel'[2,1] = _se[treat]
		
		* Column 2
		if "`panel'" != "C" quietly regress re78 treat age age2 education nodegree black hispanic
		else quietly regress re78 treat age age2 education nodegree black hispanic re74
		matrix `data'_tab2`panel'[1,2] = _b[treat]
		matrix `data'_tab2`panel'[2,2] = _se[treat]
		
		* Column 3
		quietly reg re78 treat re75
		matrix `data'_tab2`panel'[1,3] = _b[treat]
		matrix `data'_tab2`panel'[2,3] = _se[treat]
		
		* Column 4
		if "`panel'" != "C" quietly regress re78 treat re75 age age2 education nodegree black hispanic
		else quietly regress re78 treat age age2 education nodeg black hispanic re74
		matrix `data'_tab2`panel'[1,4] = _b[treat]
		matrix `data'_tab2`panel'[2,4] = _se[treat]
		
		matrix list `data'_tab2`panel'
		
	}
}


/////// FIGURE 1 ///////

use nsw_dw, clear
drop if treat==0
append using psid_controls

gen u74 = (re74==0)
gen u75 = (re75==0)
gen u74b = u74*black
gen re74_sq = re74^2
gen re75_sq = re75^2
gen ed_sq = educ^2
gen age_sq = age^2
gen age_cu = age^3

logit treat age age_sq educ ed_sq married nodegree black hispanic re74 re75 re74_sq re75_sq u74 u74b
predict P

sum P if treat==1
drop if P<r(min)
drop if P>r(max)

gen P_sq = P^2
reg re78 P P_sq treat

twoway ///
(hist P if treat == 0, width(0.05) start(0) color(black)) ///
(hist P if treat == 1, width(0.05) start(0) fcolor(none) lcolor(red)), ///
legend(order(1 "Comparison" 2 "Treated"))

graph export figure1.png


/////// FIGURE 2 ///////
use nsw_dw, clear
drop if treat==0
append using cps_controls

gen u74 = (re74==0)
gen u75 = (re75==0)
gen u74b = u74*black
gen re74_sq = re74^2
gen re75_sq = re75^2
gen ed_sq = educ^2
gen age_sq = age^2
gen age_cu = age^3

logit treat age age_sq educ ed_sq married nodegree black hispanic re74 re75 re74_sq re75_sq u74 u74b
predict P

sum P if treat==1
drop if P<r(min)
drop if P>r(max)

gen P_sq = P^2
reg re78 P P_sq treat

twoway ///
(hist P if treat == 0, width(0.05) start(0) color(black)) ///
(hist P if treat == 1, width(0.05) start(0)  fcolor(none) lcolor(red)), ///
legend(order(1 "Comparison" 2 "Treated"))

graph export figure2.png


/////// TABLE 3 ///////

use nsw_dw, clear
drop if treat==0
append using psid_controls // swap out for each column //cps_controls //psid_controls

gen u74 = (re74==0)
gen u75 = (re75==0)
gen u74b = u74*black
gen re74_sq = re74^2
gen re75_sq = re75^2
gen ed_sq = educ^2
gen age_sq = age^2
gen age_cu = age^3

* Column 1
reg re78 treat

* Column 2
reg re78 treat age education nodegree married black hispanic re74 re75

* Column 3
logit treat age age_sq education ed_sq married nodegree black hispanic re74 re75 re74_sq re75_sq u74 u74b
predict P

sum P if treat==1

drop if P<r(min)
drop if P>r(max)

gen P_sq = P^2
reg re78 P P_sq treat

twoway ///
(hist P if treat == 0, width(0.05) start(0) color(black)) ///
(hist P if treat == 1, width(0.05) start(0) fcolor(none) lcolor(red)), ///
legend(order(1 "Comparison" 2 "Treated"))


* Column 7
teffects psmatch (re78) ///
(treat age age_sq education ed_sq married nodegree black hispanic re74 re75 re74_sq re75_sq u74 u74b), ///
atet gen(ms) control(0) tlevel(1) vce(iid)

/////// TABLE 4 ///////
levelsof ms1 if treat==1, local(matched_controls) separate(",")
di "`matched_controls'"
gen obs = _n
gen msample = 0
replace msample = 1 if inlist(obs, `matched_controls')
drop obs
ci means age education black hispanic nodegree married re74 re75 if msample==1
tabstat age education black hispanic nodegree married re74 re75 if msample==1
