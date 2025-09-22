; this query will return all persons
; and show their encounter ids, or null if no encounter id
; and show their order ids, if there is an encounter id

select 
    p.person_id,
    e.encntr_id,
    e_encntr_type_class_disp = uar_get_code_display(
        e.encntr_type_class_cd
    ),
    o.order_id,
    o.order_mnemonic
from person p,
    encounter e, 
    orders o 
plan p where p.person_id > 0
join e where outerjoin(p.person_id) = e.person_id
; "keep all persons, even if they have no encounters"
join o where outerjoin(e.encntr_id) = o.encntr_id
; "keep all encounters (from the previous step, even if htey have no encounters"
with format, maxrec = 100
; plan - indicates the main table which the other table will join to
; join - these tables are outer joining based on person_id  / encntr_id
; outerjoin - specifically creates a LEFT OUTER JOIN from the perspective of the 
; driving table, so all records from the driving table are preseved