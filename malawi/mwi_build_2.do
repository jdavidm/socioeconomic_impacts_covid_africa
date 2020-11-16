* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* renames variables
	* outputs panel data

* assumes
	* raw malawi data 

* TO DO:
	* update this section
	* split out waves 
	* add wave 3


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"
	global  fies 	= 	"$data/analysis/raw/Malawi"

* open log
	cap log 		close
	log using		"$logout/mal_build", append
	
* set local wave number & file number
	local			w = 2
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 
	
		
* ***********************************************************************
* 1a - reshape section on income loss wide data
* ***********************************************************************

* load income_loss data
	use				"$root/wave_0`w'/sect7_Income_Loss_r`w'", clear

* drop other source
	drop 			income_source_os
	
*reshape data
	reshape 		wide s7q1 s7q2, i(y4_hhid HHID) j(income_source)

* save temp file
	tempfile		tempa
	save			`tempa'


* ***********************************************************************
* 1b - reshape section on safety nets wide data
* ***********************************************************************

* load safety_net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/sect11_Safety_Nets_r`w'", clear

* reorganize difficulties variable to comport with section
	replace			s11q1 = 2 if s11q1 == .
	replace			s11q1 = 1 if s11q1 == .a

* drop other
	drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b s11q5 s11q6__1 ///
						s11q6__2 s11q6__3 s11q6__4 s11q6__5 s11q6__6 ///
						s11q6__7 s11q7__1 s11q7__2 s11q7__3 s11q7__4 ///
						s11q7__5 s11q7__6 s11q7__7

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safetyid)

* save temp file
	tempfile		tempb
	save			`tempb'



	
* ***********************************************************************
* 1c - get respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/sect12_Interview_Result_r`w'", clear

* drop all but household respondant
	keep			HHID s12q9

	rename			s12q9 PID

	isid			HHID

* merge in household roster
	merge 1:1		HHID PID using "$root/wave_0`w'/sect2_Household_Roster_r`w'.dta"
	keep if			_merge == 3
	drop			_merge

* drop all but gender and relation to HoH
	keep			HHID PID  s2q5 s2q6 s2q7

* save temp file
	tempfile		tempc
	save			`tempc'
	
	
* ***********************************************************************
* 1d - get household size and gender of HOH
* ***********************************************************************

* load data
	use			"$root/wave_0`w'/sect2_Household_Roster_r`w'.dta", clear

* rename other variables 
	rename 			PID ind_id 
	rename 			new_member new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem	
	
* generate counting variables
	gen			hhsize = 1
	gen 		hhsize_adult = 1 if age_mem > 18 & age_mem < .
	gen			hhsize_child = 1 if age_mem < 19 & age_mem != . 
	gen 		hhsize_schchild = 1 if age_mem > 4 & age_mem < 19 
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data
	collapse	(sum) hhsize hhsize_adult hhsize_child hhsize_schchild (max) sexhh, by(HHID)
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"

* save temp file
	tempfile		tempd
	save			`tempd'
	
	
* ***********************************************************************
* 1e - FIES score
* ***********************************************************************

* load data
	use				"$fies/MW_FIES_round`w'.dta", clear
	drop 			country round 
	
* save temp file
	tempfile		tempe
	save			`tempe'
	
	
* ***********************************************************************
* 1f - reshape section on coping wide data
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/sect10_Coping_r`w'", clear
	
* drop other shock
	drop			shock_id_os s10q3_os

* generate shock variables
	forval i = 1/9 {
		gen				shock_`i' = 1 if s10q1 == 1 & shock_id == `i'
	}

* collapse to household level	
	collapse (max) s10q2__1- shock_9, by(HHID y4_hhid)
	
* save temp file
	tempfile		tempf
	save			`tempf'
	
	
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/secta_Cover_Page_r`w'", clear

* merge formatted sections
	foreach 		x in a b c d e f {
	    merge 		1:1 HHID using `temp`x'', nogen
	}
	
* merge in other sections
	merge 1:1 		HHID using "$root/wave_02/sect3_Knowledge_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect4_Behavior_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect5_Access_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect6_Employment_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect6b_NFE_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect6c_OtherIncome_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect8_food_security_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect9_Concerns_r2.dta", nogen
	merge 1:1 		HHID using "$root/wave_02/sect12_Interview_Result_r2.dta", nogen

*rename variables inconsistent with other waves
	rename 			s3q8_1 gov_pers_1
	rename 			s3q8_2 gov_pers_2
	rename 			s3q8_3 gov_pers_3
	rename 			s3q8_4 gov_pers_4
	rename 			s3q8_5 gov_pers_5
	rename 			s3q8_6 gov_pers_6
	rename 			s3q8_8 gov_pers_7
	rename			s3q9 sup_rcvd
	rename			s3q10 sup_cmpln
	rename			s3q11 sup_cmpln_who
	rename			s3q12 sup_cmpln_done
	rename			s6q1 emp
	replace			emp = s6q1_1 if emp == .
	gen				emp_pre = s6q2_1 if s6q2_1 != .
	rename			s6q3a_1 emp_pre_why
	rename			s6q3b_1 emp_pre_act
	rename			s6q4a_1 emp_same
	rename			s6q4b_1 emp_chg_why
	rename			s6q4c_1 emp_pre_actc
	rename			s6q5_1 emp_act
	rename			s6q6_1 emp_stat
	rename			s6q7_1 emp_able
	rename			s6q8_1 emp_unable
	rename			s6q8a_1 emp_unable_why
	rename			s6q8b_1__1 emp_cont_01
	rename			s6q8b_1__2 emp_cont_02
	rename			s6q8b_1__3 emp_cont_03
	rename			s6q8b_1__4 emp_cont_04
	rename			s6q8c_1__1 contrct
	rename			s6q9_1 emp_hh
	rename			s6q15_1 farm_emp
	rename			s6q16_1 farm_norm
	rename			s6q17_1__1 farm_why_01
	rename			s6q17_1__2 farm_why_02
	rename			s6q17_1__3 farm_why_03
	rename			s6q17_1__4 farm_why_04
	rename			s6q17_1__5 farm_why_05
	rename			s6q17_1__6 farm_why_06
	rename			s6q17_1__96 farm_why_07
	rename			s6q17_1__7 farm_why_08
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename			wt_round`w' phw
	label var		phw "sampling weights"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */	
	
	



/*



asdf 



















	drop			

	

	drop			



	drop			





* SEC 9: concerns
	rename			s9q1 concern_01
	rename			s9q2 concern_02
	gen				have_symp = 1 if s9q3__1 == 1 | s9q3__2 == 1 | s9q3__3 == 1 | ///
						s9q3__4 == 1 | s9q3__5 == 1 | s9q3__6 == 1 | ///
						s9q3__7 == 1 | s9q3__8 == 1
	replace			have_symp = 2 if have_symp == .
	lab var			have_symp "Has anyone in your hh experienced covid symptoms?:cough/shortness of breath etc."
	order			have_symp, after(concern_02)

	drop			s9q3__1 s9q3__2 s9q3__3 s9q3__4 s9q3__5 s9q3__6 s9q3__7 s9q3__8

	rename 			s9q4 have_test
	rename 			s9q5 concern_03
	rename			s9q6 concern_04
	lab var			concern_04 "Response to the COVID-19 emergency will limit my rights and freedoms"
	rename			s9q7 concern_05
	lab var			concern_05 "Money and supplies allocated for the COVID-19 response will be misused and captured by powerful people in the country"
	rename			s9q8 concern_06
	lab var			concern_06 "Corruption in the government has lowered the quality of medical supplies and care"

* create country variables
	gen				country = 2
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country
	lab var			country "Country"

* save temp file
	save			"$root/wave_02/r2_sect_all", replace	
	
	
	
	
	
	
	
	
	
	