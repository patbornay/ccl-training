drop program bgr_bun_lytes_rpt go 
create program bgr_bun_lytes_rpt 

declare bun = f8 
declare lytes = f8 

set bun = uar_get_code_by("displaykey", 200, "BUN")
set lytes = uar_get_code_by("displaykey", 200, "LYTES")

select distinct 
    p.person_id, 
    pname = substring(1, 20, p.name_last), 
    o.order_id, 
    disp = uar_get_code_display(o.catalog_cd),
    o.catalog_ch 
from person p, orders o 
plan p where p.person_id > 0
join o where p.person_id = o.person_id 
    and o.order_id > 0
    and o.catalog_cd in (bun, lytes) 
order p.person_id, o.catalog_cd, 0


head p.person_id 
    got_bun = "N"
    got_lytes = "N"
detail 
    if (o.catalog_cd = bun)
        got_bun = "Y"
    else 
        got_lytes = "Y"
    endif
foot p.person_id 
    if (got_bun = "Y" and got_lytes = "Y")
    col 10 pname 
    row +1
    endif 
with maxrec = 3000
end 
go 