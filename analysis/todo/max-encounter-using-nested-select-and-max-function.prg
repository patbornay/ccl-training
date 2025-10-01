drop program bgr_maxencounter go 
create program bgr_maxencounter 

prompt "Output to File/Printer/MINE" = MINE 

;Request HNAM sign-on when executed from CCL on host 
if (validate(IsOdbc, 0) = 0) execute cclseclogin endif 

set maxsecs = 0
if (validate(IsOdbc, 0)) set maxsecs = 15 endif 

select into $1 
    p.person_id, 
    p.name_full_formatted, 
    e.encntr_id, 
    encntr_type_disp = uar_get_code_display(e.encntr_type_cd) 
from person p, 
    encounter e 
plan p where p.person_id > 0 
join e where p.person_id = e.person_id 
    and e.encntr_id = (select max(e2.encntr_id) from encounter e2 
        where e2.person_id = p.person_id)
with maxrec = 100, time = value(maxsecs), noheading, format = variable
