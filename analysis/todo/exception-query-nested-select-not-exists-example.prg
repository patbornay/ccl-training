; this example selects people without orders 
select p.person_id,
    p.name_full_formatted
from person p 
where not exists
    (select o.person_id 
     from orders o 
     where p.person_id = o.person_id)
with maxrec = 1000
go

; this example shows how to use a nested select with plan join clauses 
select p.name_full_formatted, 
    o.order_mnemonic 
from person p 
    orders o 
plan p 
join o where o.order_id = p.person_id 
    and not exists 
    (select r.order_id 
     from result r 
     where o.order_id = r.order_id)
go 