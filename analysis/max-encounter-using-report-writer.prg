drop program bgr_maxencounter_rpt go 
create program bgr_maxencounter_rpt 

prompt "Output to File/Printer/MINE" = "MINE"

;Request HNAM sign-on when executed from CCL on host 
if (validate(isOdbc, 0) = 0) execute cclseclogin endif 

set maxsecs = 0
if (validate(isOdbc, 0)) set maxsecs = 15 endif 

select into $1 
    p.person_id, 
    p.name_full_formatted, 
    e.encntr_id ";L", 
    encntr_type_disp = uar_get_code_display(e.encntr_type_cd)
from person p, encounter e 
plan p where p.person_id > 0
join e where p.person_id = e.person_id 

order by 
    p.person_id,  
    name_full_formatted,
    0 desc

head p.person_id
    name_full_formatted1 = substring(1, 30, p.name_full_formatted), 
    col 7 p.person_id
    col 22 name_full_formatted1
    col 54 e.encntr_id 
    col 69 encntr_type_disp

with maxred = 100, time = value(maxsecs), noheading, format = variable

end 
go 