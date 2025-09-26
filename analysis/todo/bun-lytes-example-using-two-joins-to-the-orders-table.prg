cclseclogin go

drop program bun_lytes_2_join go 
create program bun_lytes_2_join 

declare bun = f8 
declare lytes = f8 

set bun = uar_get_code_by("displaykey", 200, "BUN")
set lytes = uar_get_code_by("displaykey", 200, "LYTES") 

select distinct 
    p.person_id 
    pname = substring(1, 20, p.name_last), 
    o.order_id, 
    disp = uar_get_code_display(o.catalog_cd), 
    o.catalog_cd, 
    o2.order_id, 
    disp = uar_get_code_display(o2.catalog_cd), 
    o2.catalog_cd
from 
    person p, 
    orders o, 
    orders o2 
plan p where p.person_id > 0 
join o where p.person_id = o.person_id 
    and o.order_id > 0 
    and o.catalog_cd = bun 
join o2 where o2 where o.person_id = o2.person_id 
    and o2.order_id > 0 
    and o2.catalog_cd = lytes

order p.person_id, o.catalog_cd, 0
with maxrec = 3000 
end 
go 