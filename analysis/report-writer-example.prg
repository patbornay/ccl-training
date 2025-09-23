drop program inpats go
create program inpats 

/*
For the UAR functions to work you must login to the server.
The following command will prompt the user for a username,
password, and domain. The user only needs to login to the 
server once for each Discern Explorer session.
*/
execute cclseclogin 

;get the code value for inpatients
set inpatients = 0.0
set stat = uar_get_meaning_by_codeset(69, "INPATIENT", 1, inpatients)

/*
;if the encounter. encnt-type_class_cd is not filled out,
;try using the following select statement to set the inpatients
variable 
;then in the second select statement
;change: 
;   e.encntr_type_class_cd = inpatients and 
;to: 
;   e.encntr_type_cd = inpatients and 

select into "nl:"
    cv.code_value
from code_value cv
where cv.code_set = 71 and cv.display_key = "INPATIENT"
detail 
    inpatients = cv.code_value
with nocounter
*/

select 
    name            = substring(1, 45, p.name_full_formatted), 
    sex_disp        = uar_get_code_display( p.sex_cd),
    p.birth_dt_tm, 
    p.name_last_key, 
    encnty_type     = uar_get_code_display(e.encntr_type_cd),
    nurse_unit      = uar_get_code_display(e.loc_nurse_unit_cd),
    room            = uar_get_code_display(e.loc_room_cd),
    bed             = uar_get_code_display(e.loc_bed_cd),
    los             = datetimecmp(e.disch_dt_tm, e.reg_dt_tm),
    e.disch_dt_tm,
    e.reg_dt_tm
from 
    encounter e
    person p 
plan p 
join e where p.person_id = e.person_id and 
             e.encntr_type_class_cd = inpatients and 
             e.reg_dt_tm > cnvtdatetime("01-JAN-1900") and 
             e.disch_dt_tm > cnvtdatetime("01-JAN-1900") 
order nurse_unit, 
    p.name_last_key 

; Begin report writer section 
head report 
    room_bed        = fillstring(20, " ") ;store the room and bed 
    line_d          = fillstring(120, "=") ;print double line 
    line_s          = fillstring(120, "-") ;pring single line
    blank_line      = fillstring(120, " ") ;pring a blank line 

    macro (col_heads)
        col 0 "Name:"
        col 50 "Sex:"
        col 60 "Birth Date:"
        col 75 "Room-Bed:" 
        row -1
        col 95 "Length of Stay"
        row +1
        col 85 "In Days:"
    endmacro 

    ; Create title page 
    row 0 
    call center("*** CENER's INPATIENT REPORT***", 0, 120)
    col 0 "Report Date: ", curdate "MM/DD/YY;;D" 
    col 100 "Report Time: ", curtime "HH:MM;;M" 
    row +1 line_d 
    row +2

head page 
    col 0 "Page: "
    col 7 curpage "###;L"
    row +1 col_heads ;calls the col_heads macro.
    row +1 line_s 
    row +1 

head nurse_unit 
    row +1
    col 0 "Nursing Unit:"
    col +2 nurse_unit 
    row +2 
    ;col_heads ; uncomment if you want the column headings 
               ; at the top of each nursing unit
detail 
    if (row + 1 >= 57) ; verify there are enough blank rows left on the page for processing foot clauses
        break
    endif 
    col 0 name 
    col 50 ;sex_disp
    case(sex_disp)
        of "Male"       :"M"
        of "Female"     :"F"
        else "U"
    endcase 

    col 60 p.birth_dt_tm "MM/DD/YYYY;;D"
    if (room = " " and bed = " ")
        room_bed = "No room or bed" 
    elseif (room != " " and bed != " ")
        room_bed = build(room, "-", bed)
    elseif(room != " ")
        room_bed = build(room, "-No bed")
    else 
        room_bed = build("No room", bed)
    endif
    col 75 room_bed 
    col 95 los
    col +1 "dischared: ", e.disch_dt_tm
    col +1 "registered: ", e.reg_dt_tm

foot nurse_unit
    if (row + 5 >= 57) 
        break 
    endif 

    row +1 
    col 45 "    Total number of days for this nursing unit: "
    col 95 sum(los) 
    row +1
    col 45 "    Total number of patients for this nursing unit: "
    col 95 count(name) 
    row +1
    col 45 "    Patients with LOS > 5 for this nuring unit: "
    col count(name where los >5) 
    row +1 
    col 45 "    Average length of stay for this nuring unit: "
    col 95 avg(los) 
    row +1 

foot page 
    row 57
    col 0 line_s 
    row 58 
    col 0 "Report created by the Discern Explorer Program: INPATS" 
    row 59 
    col 0 line_s 

foot report 
    row +1      ;need row+1 to advance past the page break
    row -3
    col 0 blank_line
    row +1 
    col 0 blank_line
    row +1
    col 0 blank_line
    row +5
    call center("*** Grand totals for report ***", 0, 120)
    row +1 
    col 62 "    Total number of patients: "
    col 95 count(name)
    row +1 
    col 62 "    Total patients with LOS > 5: "
    col 95 count(name where los >5)
    row +1 
    col 62 "    Avg length of sta: "
    col 95 avg(los)
    row +5
    call center("*** End of report ***", 0, 120)

; *** End report writer section ***

with maxrec = 500
    maxcol = 250 

end 
go 

; todo run and comment on this ccl

