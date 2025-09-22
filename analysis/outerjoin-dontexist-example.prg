; The dontexist option essentially turns this into a 'find people without encounters' 
; query rather than a typical left join
select p.person_id,
    name = substring(1, 20, p.name_last_key),
    e.encntr_id,
    etype = uar_get_code_meaning(e.encntr_type_cd)
from person p,
    encounter e, 
    dummyt d 
plan p where p.person_id > 0
join d 
join e where p.person_id = e.person_id 
    and e.encntr_type_cd > 0
with outerjoin = d, dontexist, maxrec = 1000
go 
; The dontexist keyword 
; - dontexist is a CCL-specific option that changes how the outer join behaves
; - without dontexist: if a person has any encounters, you get NO rows for that person
; - it essentially means "only show people who DONT have the matching encounters"

; How the execution works
; 1. Start with person table (plan p where p.person_id > 0)
; 2. Join to dummy table (join d) - every person gets paired with the dummy row
; 3. Try to join encounters (join e where p.person_id = e.person_id and e.encntr_type_cd > 0)

; The outerjoin = d, dontexist combination: 
; - outerjoin = d, preserves rows when the encounter join fails
; - dontexist, eliminates rows when the encounter join succeeds

; Results: 
; - Person has no encounters: Row is kept( due to outerjoin = d), encounter fields are NULL
; - Person has encounters: Row is dropped (due to dontexist)

; So this query returns: 
; - People who have NO encounters (with encounter_type_cd > 0)
; - Their encounter fields will be NULL/blank
; - Limited to 1000 records 