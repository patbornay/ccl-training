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
; person table is the driving table with encounter being joined 
; via an inner join using 'join'
; the join conditions filter for inpatient encounters with valid 
; registration and discharge dates
; only persons with matching encounters that meet these 
; conditions are returned
plan p 
join e where p.person_id = e.person_id and 
             e.encntr_type_class_cd = inpatients and 
             e.reg_dt_tm > cnvtdatetime("01-JAN-1900") and 
             e.disch_dt_tm > cnvtdatetime("01-JAN-1900") 
order nurse_unit, 
    p.name_last_key 

; Begin report writer section 
; ==========================
; The report writer section controls the layout and formatting of the output
; It uses hierarchical sections (head/foot) that execute at different points

head report 
    ; HEAD REPORT: Executes once at the very beginning of the report
    ; Used to initialize variables and create title page elements
    
    room_bed        = fillstring(20, " ") ; Create a 20-character string filled with spaces to store room and bed info
    line_d          = fillstring(120, "=") ; Create a 120-character double line separator
    line_s          = fillstring(120, "-") ; Create a 120-character single line separator
    blank_line      = fillstring(120, " ") ; Create a 120-character blank line for spacing

    macro (col_heads) ; MACRO: Defines a reusable block of code that can be called later
        ; This macro prints column headers for the report
        col 0 "Name:"               ; COL: Sets the cursor to column position 0 and prints text
        col 50 "Sex:"               ; Move to column 50
        col 60 "Birth Date:"        ; Move to column 60
        col 75 "Room-Bed:"          ; Move to column 75
        row -1                      ; ROW -1: Move cursor up one row (to print on same line)
        col 95 "Length of Stay"     ; Continue headers on the same line
        row +1                      ; ROW +1: Move cursor down one row
        col 85 "In Days:"           ; Print sub-header
    endmacro                        ; ENDMACRO: Marks the end of macro definition

    ; Create title page 
    row 0                           ; ROW 0: Move cursor to row 0 (top of page)
    call center("*** CENER's INPATIENT REPORT***", 0, 120) ; CALL: Executes a subroutine (center) to center text between columns 0-120
    col 0 "Report Date: ", curdate "MM/DD/YY;;D"  ; CURDATE: Built-in function that prints current date with specified format
    col 100 "Report Time: ", curtime "HH:MM;;M"   ; CURTIME: Built-in function that prints current time
    row +1 line_d                   ; Move down 1 row and print the double line
    row +2                          ; Skip 2 rows for spacing

head page 
    ; HEAD PAGE: Executes at the top of each new page
    ; Used to print page numbers and column headers on every page
    
    col 0 "Page: "
    col 7 curpage "###;L"           ; CURPAGE: Built-in variable containing current page number, formatted as left-aligned number
    row +1 col_heads                ; Move down 1 row and call the col_heads macro defined earlier
    row +1 line_s                   ; Print single line separator
    row +1                          ; Add blank row

head nurse_unit 
    ; HEAD NURSE_UNIT: Executes once for each unique nurse_unit value (control break)
    ; Used to print section headers when the nurse_unit value changes
    ; The control break happens when the value of nurse_unit CHANGES between rows, not on every detail row.
    ; the ORDER keyword is critical!  It sorts all the records so that rows with the same nurse_unit are grouped together.
    ; head nurse_unit: Fires when entering a NEW nurse_unit group
    ; detail: Fires for EVERY row
    ; foot nurse_unit: Fires when LEAVING a nurse_unit group (when the value changes OR at the end of all data)
    row +1
    col 0 "Nursing Unit:"
    col +2 nurse_unit               ; COL +2: Move 2 columns to the right from current position, print nurse_unit value
    row +2 
    ;col_heads ; uncomment if you want the column headings 
               ; at the top of each nursing unit

detail 
    ; DETAIL: Executes once for each row returned by the SELECT query
    ; This is where individual patient records are printed
    
    if (row + 1 >= 57)              ; IF: Conditional statement checking if we're near bottom of page (row 57)
        break                       ; BREAK: Forces a page break to prevent overwriting footer
    endif                           ; ENDIF: Ends the if statement
    
    col 0 name                      ; Print patient name starting at column 0
    col 50 ;sex_disp                ; Move to column 50
    case(sex_disp)                  ; CASE: Multi-way conditional statement (like switch/case)
        of "Male"       :"M"        ; OF: Checks if sex_disp equals "Male", if so print "M"
        of "Female"     :"F"        ; Check for "Female", print "F"
        else "U"                    ; ELSE: Default case if no matches, print "U" for unknown
    endcase                         ; ENDCASE: Ends the case statement

    col 60 p.birth_dt_tm "MM/DD/YYYY;;D" ; Print birth date with specified format (;;D = date format)
    
    ; Logic to handle missing room or bed data
    if (room = " " and bed = " ")
        room_bed = "No room or bed" 
    elseif (room != " " and bed != " ")  ; ELSEIF: Additional conditional check
        room_bed = build(room, "-", bed) ; BUILD: Concatenates strings together
    elseif(room != " ")
        room_bed = build(room, "-No bed")
    else 
        room_bed = build("No room", bed)
    endif
    
    col 75 room_bed                 ; Print room_bed value
    col 95 los                      ; Print length of stay
    col +1 "dischared: ", e.disch_dt_tm    ; Print discharge datetime
    col +1 "registered: ", e.reg_dt_tm     ; Print registration datetime

foot nurse_unit
    ; FOOT NURSE_UNIT: Executes once at the end of each nurse_unit group
    ; Used to print summary statistics for each nursing unit
    
    if (row + 5 >= 57)              ; Check if there's room for footer (needs 5 rows)
        break                       ; Force page break if not enough room
    endif 

    row +1 
    col 45 "    Total number of days for this nursing unit: "
    col 95 sum(los)                 ; SUM: Aggregate function that totals los for current nursing unit group
    row +1
    col 45 "    Total number of patients for this nursing unit: "
    col 95 count(name)              ; COUNT: Aggregate function that counts records in current group
    row +1
    col 45 "    Patients with LOS > 5 for this nuring unit: "
    col count(name where los >5)    ; COUNT with WHERE: Conditional count of records meeting criteria
    row +1 
    col 45 "    Average length of stay for this nuring unit: "
    col 95 avg(los)                 ; AVG: Aggregate function that calculates average of los
    row +1 

foot page 
    ; FOOT PAGE: Executes at the bottom of each page
    ; Used to print page footers consistently on every page
    
    row 57                          ; Move to specific row 57 (bottom of page)
    col 0 line_s                    ; Print single line separator
    row 58 
    col 0 "Report created by the Discern Explorer Program: INPATS" 
    row 59 
    col 0 line_s 

foot report 
    ; FOOT REPORT: Executes once at the very end of the entire report
    ; Used to print grand totals and final summary information
    
    row +1      ; Need row+1 to advance past the page break
    row -3      ; Move up 3 rows to position output correctly
    col 0 blank_line
    row +1 
    col 0 blank_line
    row +1
    col 0 blank_line
    row +5
    call center("*** Grand totals for report ***", 0, 120) ; Center the grand totals header
    row +1 
    col 62 "    Total number of patients: "
    col 95 count(name)              ; Grand total count across all nursing units
    row +1 
    col 62 "    Total patients with LOS > 5: "
    col 95 count(name where los >5) ; Grand total conditional count
    row +1 
    col 62 "    Avg length of sta: "
    col 95 avg(los)                 ; Grand average across all records
    row +5
    call center("*** End of report ***", 0, 120)

with maxrec = 500
    maxcol = 250 

end 
go 

; todo run and comment on this ccl

