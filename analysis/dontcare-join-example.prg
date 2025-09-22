; The dontcare option essentially creates a left join behviour for the person table 
select
    p.person_id,
    pname = substring (1,20, p.name_last),
    addid = decode (a.seq,a.parent_entity_id),
    address_D = decode(a.seq, substring(1,20,a.street_addr)),
    address = substring(1,20,a.street_addr),;no decode-invalid data
    o.order id,
    mne = substring(1,20,0.order_mnemonic)
from 
    person p,
    orders o,
    dummyt d1,
    dummyt d2,
    address a
plan p where p.person_id > 0
join d1
join a where p.person_id = a.parent_entity_id
    and a.parent_entity_name = "PERSON"
join d2
join o where p.person_id = o.person_id
    and o.order id > 0
with dontcare = a,
    maxrec = 3000
go
; the dontcare = a creates a specific joining behaviour that's different from both 
; inner joins and outer joins

; What dontcare = a does: 
; - it means 'dont worry about whether the address join succeeds or fails'
; - if person has an address - include the address data
; - if not - still include the person, but address fields are NULL
; - key diff from 'outerjoin' - the person record is preserved regardless of the address join result

; The joining structure 
; person -> dummyt d1 -> address (with dontcare)
; person -> dummyt d2 -> orders (regular join)

; Execution flow: 
; 1. Start with person records
; 2. Join through d1 to address table with dontcare = a
;       - person with address: gets address data
;       - person without: address fields become NULL, but person kept
; 3. Join through d2 to orders table (regular join)
;       - person must have orders to appread in final results

; Final results; 
; - person has orders AND address: shows person + addres + order data
; - person has oders BUT no address: shows person + NULL address + order data
; - person has no orders: excluded entirely (regardless of address)

; Highlight
; dontcare = a, makes the address join optional, but the orders join is still
; required. So you get "all people with orders, optionally showing their address if they have one"

; Dummy tables 
; 1. CCL's join limitation: in CCL, you can't directly specify multiple optional joins from the same driving
; table. You need an intermediary
; 2. Createing separate join paths: Each dummy table creats an independent join pathway:
;   - person -> d1 -> address (optional via dontcare)
;   - person -> d2 -> orders (required)
; 3. Controlling join behaviour: Each dummy table can have different join options applied to its branch
; The dummy table mechanism
; - dummyt contains exactly one row with minimal data
; - every person record joins to this one dummy row (1:1 relo)
; - this create a 'bridge' that preserves all person records
; - then you can apply different join behaviors (dontcare, outerjoin) to each branch

; Dummy Table sequential join chaining
; plan p                    -- Start with person
; join d1                   -- person → d1 
; join a where ...          -- d1 → address (inherits d1's join behavior)
; join d2                   -- person → d2 
; join o where ...          -- d2 → orders (inherits d2's join behavior)
; - each join statement connects to the most recent table in the chain
; - join a comes immediately after join d1, so address links through d1
; - join o comes immediately after join d2, so orders links through d2

; Why doesnt o and d2 join to d1 like a has? 
; - CLL creates a 'branching tree' structure, not a linear chain
; person (plan p)
; ├── d1 branch
; │   └── address (join a)
; └── d2 branch  
;     └── orders (join o)
; Why d2 doesn't chain through d1: 
; - When CCL encounders join d2 after the d1 -> address chain, it returns to the root (the plan table)
; rather than continuing from the last table in the chain
; Why this behaviour exists
; - CCL recognises that d2 (another dummy table) is likely meant to create a separate join path 
; - Dummy tables are typically used as 'branch creators' from the main table 
; - if you wanted d2 to chain from address, you'd need explicit join conditions
; "join d2 where a.some_field = d2.some_field"
;   then d2 would indeed chain from address, but with just join d2 (⭐⭐⭐ no WHERE clause), ccl assumes you
;   want a new branch from the plan table 

; Modern CCL alternative - Newer versions support more direct syntax buy many legacy systems still use the 
; dummy table for reliability and clarity about join behaviour