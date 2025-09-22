; - Queries for encounters from the last 30 days, ordered by registration date
; - Report: Uses CCL's reporting feature for formatting 
; - Gap filling: The while loop fills in missing date between encounters to show '0' counts

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
; fires when the 'updated' value changes (new date group)
foot updated 
    row + 1 ; spacing line
    ; predate - tracks the last date processed 
    ; updated - is the current encounter date from the 'foot updated' section
    ; if there's a gap the loop runs for the days between

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
