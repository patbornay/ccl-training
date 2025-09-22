drop program ccl_review_exam go
create program ccl_review_exam
; lower case gets syntax highlighting 
; typical clearing a program to make sure we are starting fresh 

prompt "Output to File/Printer/MINE" = MINE ; this is shown in a pop up when executing a script from DVDev 
; or will be needed when executing a script from cli 

set MaxSecs = 0
if (IsOdbc) set MaxSecs = 15 endif 

select into $1 ; output destination #1, this is currently associated with the prompt "Output to file ...." line
p.name_full_formatted, 
sex_disp = uar_get_code_display(p.sex_cd), ; changed sex_cd to p.sex_cd as it was not clear where sex_cd came from
p.birth_dt_tm,
encntr_type_disp = uar_get_code_display(e.encntr_type_cd),
encntr_type_class_disp = uap_get_code_display(
    e.encntr_type_class_cd
),
patient_age = cnvtage(p.birth_dt_tm) ; this age conflicts with the built-in ccl age variable 'age'
; options, 1. change the age use to patient_age, 2 do "col 29 trim(age)", 3 do "col 29 'age'"
; going with option 1
; next ambiguous issue was that it was again redefined in the head p.person_id section 
; commenting out that line resolves the issue
from person p, encounter e 
plan p where p.person_id > 0 
join e where e.person_id = p.person_id 
and e.encntr_id > 0

order p.person_id 

head report 
row 2 col 47 "Example report"
row 4 col 7 "Date:"
curdate "mmm-dd-yyyy;;d"
row 5 col 7 "Time:"
curtime "hh:mm;;m"
row + 2

head page
row + 1
col 7 "Page:"
curpage "###"
row + 2
col 7 "Name:"
col 29 "Age:"
col 41 "Sex:"
col 54 "Encounter type:"
row + 2

head p.person_id 
row + 1 
;patient_age = cnvtage( p.birth_dt_tm )
sex_disp1 = substring( 1, 12, sex_disp), 
name_full_formatted1 = substring( 1, 20, p.name_full_formatted ),
col 7 name_full_formatted1
col 29 patient_age
col 41 sex_disp1
row + 2

detail 
if ((row + 4) >= maxrow) break endif
col 54 encntr_type_class_disp
row + 1

with 
maxrec = 200, maxcol = 500, time = value(MaxSecs), noheading, format = variable

end go
