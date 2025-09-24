;cclsource: ccl_global_local_exam1.prg
; this demonstrates how local and global names get prioritised
; in this example the disp global variable does not overwrite
; the disp value in the select, and continues to resolve to cv.display
; when disp is used in the following detail output
cclseclogin go  
drop program ccl_global_local go 
create program ccl_global_local 

declare disp = c48 
set disp = "Global variable" 

select disp = cv.display,
    cv.code_value 
from code_value cv 
where cv.code_set = 57 
    and cv.cdf_meaning = "MALE" 
detail
    col 0 cv.code_value 
    col +1 "TEST"
    col +2 disp ; shows the value of disp from select 
    disp2 = concat("**", disp, "**")
    col +2 disp2 ;shows the value of the global variable 
    row + 1
with counter
call echo(" ")

call echo ("The global var was NOT set equal to the local expression")
call echo  (concat("Disp =", disp))

end go 
ccl_global_local go