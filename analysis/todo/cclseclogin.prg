;cclseclogin go
select p.person_id, 
name = substring(1, 20, p.name_last)
e.encntr_id,
etype = uar_get_code_meaning(e.encntr_type_cd)
from person p, encounter e 
plan p where p.person_id > 0 
join e where outerjoin(p.person_id) = e.person_id 
with maxrec = 1000
go

; example of an adhoc query to see person's name, and any encounters
; it shows an outerjoin query 