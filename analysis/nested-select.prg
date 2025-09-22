; this select select person full formatted 
; from person table where the person id 
; equals the person id in the orders table 
; where the order_mnemonic = "BUN"
select p.name_full_formatted
from person p 
where p.person_id in 
    (select o.person_id 
     from orders o 
     where o.order_mnemonic = "BUN"
    )
go

; more efficient version 
; instead of comparing a p.person_id to each row in the inner select
; we check "does there exist AT LEAST ONE order record where the person_id
; matches this current person AND the ordermnemonic is BUN"?
select p.name_full_formatted
from person p 
where exists
    (select 1 
     from orders o
     where o.person_id = p.person_id
     and o.order_mnemonic = "BUN"
    )
go
; since were only selecting the p.name_full_formatted we only need one 
; order with the same person_id and order_mnemonic BUN to match and display
; the name_full_formatted for that person

; select 1 doesnt actually mean 1 its just a placeholder 
; IN will process all matching rows even if there are hundereds 

; memory
; - EXISTS doesn't build a list of values in memory
; - IN creates a list of all matching person_ids