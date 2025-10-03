drop program ccl_into_file_exam go 
create program ccl_into_file_exam 

select into bgr_test 
    o.orig_order_dt_tm, 
    o.catalog_cd, 
    catalog_disp = uar_get_code_display(o.catalog_cd) 
from order o 
where o.orig_order_dt_tm between cnvdatetime(curdate - 7,0) 
    and cnvtdatetime(curdate, 235959) 
order cnvtdatetime(o.orig_order_dt_tm), 
    o.catalog_cd 
with format = pcformat, noheading 
end go 
ccl_into_file_exam go 