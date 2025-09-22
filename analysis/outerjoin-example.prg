; Selects person info with optional encounter details 
; Uses dummyt (dummy table) to create outer join behviour
; - All person records are shown
; - Encounter fields show as blank/null when no matching encounter exists
; - Limited to 1000 records 
select p.person_id,
    name = substring(1,29,p.name_last_key),
    e.encntr_id,
    etype = uar_get_code_meaning(e.encntr_type_cd)
from person p,
    encounter e, 
    dummyt d
; dummpt d - is a special system table that contains exactly one row with no meaningful data
; join d - every person record gets joined to this single dummy now, so every person
; record is preserved
; with outerjoin = d this tells the query engine: "if any subsequent join fail to find matches,
; ,don't drop the row, instead, reutrn NULL values for the unmatched tables"
plan p where p.person_id > 0
join d ; step1. person -> dummyt (1 to 1 mapping) 
join e where p.person_id = e.person_id ; step2. try to join to encounter
    and e.encntr_type_cd > 0 
with outerjoin = d, ; step3. if step2 fails, keep row anyway
    maxrec = 1000
go 
; What happens: 
; - Person has encounters: normal inner join behaviour, encounter data is populated 
; - Person has no encounters: the 'outerjoin = d' keeps the person + dummy row alive, 
; encounter field become NULL

; Why the dummy table is needed? In CCL, you can't directly outer join from the driving table 
; (person). The dummy table acts as an intermediary that ensures every person records 
; survives the join chain. 

