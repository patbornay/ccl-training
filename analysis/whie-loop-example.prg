drop program ccl_while_admit_cnt2 go 
create program ccl_while_admit_cnt2

; Typical pattern to prompt / with / select into parameter
prompt "Output to File/Printer/MINE" = "MINE" 
with OUTDEV

select into $OUTDEV
	updated = cnvtdate(e.reg_dt_tm), 
    e.reg_dt_tm 
from encounter e 
where e.reg_dt_tm 
    between cnvtdatetime(curdate - 30, 0) and 
    cnvtdatetime(curdate, curtime3)
order updated 

head report 
    predate = updated ; a variable setup
    ; center aligned heading 
    row 3 col 47 "Example Admit Count By Date Report"
    row + 1 ; spacing line
head page 
    row + 2 ; spacing line
    col 7 "Date:" ; left aligned heading cell
    col 41 "Count:" ; left center aligned heading cell 
    row + 1 ; spacing line
foot updated 
    row + 1 ; spacing line
    while (predate < updated - 1) 
        plusdate = predate + 1
        col 8 plusdate "mm/dd/yy;;d"
        row + 1
        predate = predate + 1
    endwhile
    col 8 e.reg_dt_tm ; display reg_dt_tm 
    col 40 count(e.seq) ; display count 
    predate = updated  ; set predate to updated 
end go 

; todo the while loop needs some analysis