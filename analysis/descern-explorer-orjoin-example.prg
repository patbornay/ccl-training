; this query utilises the orjoin keyword 
; - creates an optional branching join 
;   enables result returns even when one of hte join paths fail to find matching records 
; without orjoin (normal join)
;   - all joins must succeed for a row to return 
;   - if an order has no comments OR no results, that entire order gets excluded
; with orjoin
;   - creates two separate join paths from the same starting point 
;   - if either path succeeds, the row is included in results
;   - both paths can succeed simultaneiously
select name = substring(1,30, p.name_full_formatted), 
    order_mnemonic = substring(1, 30, o.order_mnemonic),
    check = decode(oc.seq, "c", r.seq, "r","z"),
    result_id = decode(r.seq, r.result_id), 
    order_com_id = decode(oc.seq, oc.long_text_id) 
from person p 
    orders o, 
    order_comment oc, 
    result r, 
    dummyt d1, 
    dummyt d2
plan p where person_id > 0 
join o where o.person_id = p.person_id 
    and o.order_id > 0
join d1 
join (oc where oc.order_id = o.order_id) 
orjoin d2 
join (r where r.order_id = o.order_id) 

order p.person_id, 
    o.order_id, 
    check 
with maxqual(oc, 100) 
go
; dummy tables 
; d1 is used to join the order_comments table
; d2 creates the alternative branch leading to results 

; decode 
; basic syntax 
; DECODE(expression, 
;       value1, result1,
;       value2, result2,
;       value3, result3,
;       default_result)
; how It Works:
; 1. evaluates the expression
; 2. compares it to value1, if match → returns result1
; 3. if no match, compares to value2, if match → returns result2
; 4. continues through all value/result pairs
; 5. if no matches found → returns default_result (optional)

; examples from Your Query:
; example 1:
; cclcheck = decode(oc.seq, "c", r.seq, "r", "z")

; if oc.seq exists (not null) → return "c"
; if oc.seq is null but r.seq exists → return "r"
; if both are null → return "z"