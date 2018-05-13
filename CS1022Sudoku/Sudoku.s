	AREA	Sudoku, CODE, READONLY
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8

start

	LDR	R0, =gridOne
	MOV	R1, #0
	MOV	R2, #0
	BL	sudoku
	LDR	R0, =gridOne
	BL printSolution

stop	B	stop



; getSquare subroutine
; Returns the byte size value of a digit in a given row and column
;		R0 = grid start address
; 		R1 = Word size value of row
;		R2 = Word size value of column
;		Return register R0 returns byte size value of digit in given location
getSquare
	STMFD sp!, {R4-R7, lr}	
	MOV R4, R1				;store parameters
	MOV R6, R0	
	MOV R7, R2
	MOV R5, #9				;row size value
	MUL R4, R5, R4			;index = row*row size
	ADD R4, R4, R7			;index = (row*rowsize) + column
	ADD R6, R6, R4			;add index to array start address
	LDRB R0, [R6]			;load value at that address
	LDMFD sp!, {R4-R7, pc}	;restore stack to original position

; setSquare subroutine
; Set the value of the square at the given row and column equal to the given byte size value
;		R0 = grid start address
; 		R1 = Word size value of row
;		R2 = Word size value of column
;		R3 = Byte size value that square should be set to
setSquare
	STMFD sp!, {R4-R8, lr}
	MOV R4, R1				;store parameters
	MOV R6, R0
	MOV R7, R3
	MOV R8, R2
	MOV R5, #9				;row size value
	MUL R4, R5, R4			;index = row*row size
	ADD R4, R4, R8			;index = (row*rowsize) + column
	ADD R6, R6, R4			;add index to array start address
	STRB R7, [R6]			;store passed value at that address
	LDMFD sp!, {R4-R8, pc}	;restore stack to original position



; isValid subroutine
; Return true if a given row and column has a valid answer in it otherwise return false
; 		R0 = grid start address
;		R1 = Word size value of row
;		R2 = Word size value of column
;		Return register R0 returns 1 for true and 0 for false
isValid
	STMFD sp!, {R4-R9, lr}
	MOV R4, R0				;store grid address
	MOV R5, R1				;stores row number
	MOV R6, R2				;store column number
	BL getSquare			;retrieve square value
	MOV R8, R0				;store value of that position in R8
	MOV R7, #0				;row counter
forRows
	CMP R7, #9				;check all addresses in this row
	BEQ forCols				;afterwards check all addresses in this column
	MOV R2, R7				;for each column address compare to passed row address
	CMP R6, R2				;
	BEQ skipSameAddress		;if the column and row address is equal to the passed address don't check if values at that address are equal
	MOV R0, R4				
	MOV R1, R5
	BL getSquare			;get value at this position
	MOV R9, R0				
	CMP R9, R8				;compare to value at given posoition
	BEQ returnFalse			;if they are equal this isn't valid solution
	ADD R7, R7, #1			
	B forRows
skipSameAddress
	ADD R7, R7, #1			;increment without comparing if address of values are equal
	B forRows
forCols
	MOV R7, #0				;count columns
for
	CMP R7, #9				;if all columns are checked branch to check subgrids
	BEQ grids				
	MOV R1, R7
	CMP R5, R1
	BEQ skipSameCol			;skip checking of same square
	MOV R0, R4
	MOV R2, R6
	BL getSquare			;get number of current square
	MOV R9, R0
	CMP R9, R8
	BEQ returnFalse			;if numbers equal return false
	ADD R7, R7, #1			;else increment
	B for
skipSameCol
	ADD R7, R7, #1
	B for
grids
	MOV R0, R4
	MOV R1, R5
	MOV R2, R6
	BL checksubgrids		;checksubgrids(grid, row, column);
	CMP R0, #0
	BEQ returnFalse			;if it returns false return false
	B returnTrue			;else return true

returnTrue
	MOV R0, #1
	LDMFD sp!, {R4-R9, pc}
returnFalse
	MOV R0, #0
	LDMFD sp!, {R4-R9, pc}
	
	

; checksubgrids subroutine
; Return true if a the subgrid of a given square follows the rules of sudoku
; 		R0 = grid start address
;		R1 = Word size value of row
;		R2 = Word size value of column
;		Return register R0 returns 1 for true and 0 for false
checksubgrids
	STMFD sp!, {R4-R12, lr}
	MOV R4, R0			;store grid address
	MOV R5, R1			;stores row number
	MOV R6, R2			;store column number
	BL getSquare
	MOV R9, R0
foreachsubgrid			;assign what subgrid a square is in based on its row and column
	CMP R5, #3
	BGE notfirstthree
	CMP R6, #3
	BLT subgridone
	CMP R6, #6
	BLT subgridtwo
	CMP R6, #9
	BLT subgridthree
notfirstthree
	CMP R5, #6
	BGE notsecondthree
	CMP R6, #3
	BLT subgridfour
	CMP R6, #6
	BLT subgridfive
	CMP R6, #9
	BLT subgridsix
notsecondthree
	CMP R6, #3
	BLT subgridseven
	CMP R6, #6
	BLT subgrideight
	CMP R6, #9
	BLT subgridnine
	
subgridone
	MOV R7, #0		;rowstart
	MOV R12, #3		;rowend
	MOV R8, #0		;columnstart
	MOV R10, #0		;columnreset
	MOV R11, #3		;columnend
	B check
subgridtwo
	MOV R7, #0		;rowstart
	MOV R12, #3		;rowend
	MOV R8, #3		;columnstart
	MOV R10, #3		;columnreset
	MOV R11, #6		;columnend
	B check
subgridthree
	MOV R7, #0		;rowstart
	MOV R12, #3		;rowend
	MOV R8, #6		;columnstart
	MOV R10, #6		;columnreset
	MOV R11, #9		;columnend
	B check
subgridfour
	MOV R7, #3		;rowstart
	MOV R12, #6		;rowend
	MOV R8, #0		;columnstart
	MOV R10, #0		;columnreset
	MOV R11, #3		;columnend
	B check
subgridfive
	MOV R7, #3		;rowstart
	MOV R12, #6		;rowend
	MOV R8, #3		;columnstart
	MOV R10, #3		;columnreset
	MOV R11, #6		;columnend
	B check
subgridsix
	MOV R7, #3		;rowstart
	MOV R12, #6		;rowend
	MOV R8, #6		;columnstart
	MOV R10, #6		;columnreset
	MOV R11, #9		;columnend
	B check
subgridseven
	MOV R7, #6		;rowstart
	MOV R12, #9		;rowend
	MOV R8, #0		;columnstart
	MOV R10, #0		;columnreset
	MOV R11, #3		;columnend
	B check
subgrideight
	MOV R7, #6		;rowstart
	MOV R12, #9		;rowend
	MOV R8, #3		;columnstart
	MOV R10, #3		;columnreset
	MOV R11, #6		;columnend
	B check
subgridnine
	MOV R7, #6		;rowstart
	MOV R12, #9		;rowend
	MOV R8, #6		;columnstart
	MOV R10, #6		;columnreset
	MOV R11, #9		;columnend
	B check

check
foreachrow
	CMP R7, R12
	BEQ truereturn		;return true if the end of rows is reached
foreachcol
	CMP R8, R11
	BEQ incrementrow
	MOV R0, R4
	MOV R1, R7
	MOV R2, R8
	BL getSquare 		;get value at current square
	CMP R0, #0			;if square equals zero skip this square
	BEQ incrementcol
	CMP R5, R7
	BNE notsame
	CMP R6, R8
	BNE notsame
	B incrementcol		;if addresses are the same increment and try next
notsame
	CMP R0, R9			
	BEQ falsereturn		;if values are equal then return false
incrementcol
	ADD R8, R8, #1		;if values aren't equal move to next column
	B foreachcol
incrementrow
	ADD R7, R7, #1		;if last column is reached increment rows
	MOV R8, R10
	B foreachrow
truereturn
	MOV R0, #1
	LDMFD sp!, {R4-R12, pc}
falsereturn
	MOV R0, #0
	LDMFD sp!, {R4-R12, pc}





; sudoku subroutine
; 		R0 = grid start address
;		R1 = Word size value of row
;		R2 = Word size value of column
;		Return register R0 returns 1 for true and 0 for false
sudoku
	STMFD sp!, {R4-R11, lr}
	MOV R4, R0			;store grid
	MOV R5, R1			;store row
	MOV R6, R2			;store col
	MOV R7, #0			;bool result = false
	ADD R10, R6, #1		; next column = col +1
	MOV R9, R5 			;next Row = row
	CMP R10, #8			;if (nxtcol > 8)				
	BLE lessthanorequal	
	MOV R10, #0			;nextcol = 0
	ADD R9, R9, #1		;nextrow++
lessthanorequal
	MOV R0, R4			
	MOV R1, R5
	MOV R2, R6
	BL getSquare		
	CMP R0, #0			;if ( getSquare(grid,row,col) != 0) {
	BEQ emptySquare
	CMP R5, #8
	BNE nextSquare
	CMP R6, #8
	BNE nextSquare		;if (row == 8 &&col == 8) 
	MOV R0, #1			;return true
	LDMFD sp!, {R4-R11, pc}
nextSquare
	MOV R0, R4			;else
	MOV R1, R9
	MOV R2, R10
	BL sudoku			;result = suduko(grid,nxtrow,nxtcol);
	MOV R7, R0
	B returnResult
emptySquare
	MOV R11, #1			;else
forbytetry				;for(byte try = 1; try<=9 && !result; try++)
	CMP R11, #9
	BGT endforbyte
	CMP R7, #1
	BEQ endforbyte
	MOV R0, R4
	MOV R1, R5
	MOV R2, R6
	MOV R3, R11
	BL setSquare		;setSquare(grid, row, col, try)
	BL isValid			;if(isValid(grid, row, col))
	CMP R0, #0
	BEQ incrementAndTryAgain
	CMP R5, #8
	BNE notLastEntry
	CMP R6, #8
	BNE notLastEntry	;if(row == 8 && col ==  8)
	MOV R7, #1			;return true
	B returnResult
	B incrementAndTryAgain
notLastEntry
	MOV R0, R4			;else
	MOV R1, R9
	MOV R2, R10
	BL sudoku			;return sudoku(grid,nxxtrow,nxtcol);
	MOV R7, R0
incrementAndTryAgain
	ADD R11, R11, #1	;try++
	B forbytetry		
endforbyte
	CMP R7, #1			;if(!result)
	BEQ returnResult
	MOV R0, R4
	MOV R1, R5
	MOV R2, R6
	MOV R3, #0
	BL setSquare		;mistake was made setSquare(grid,row,col,0)
returnResult
	MOV R0, R7			;return result
	LDMFD sp!, {R4-R11, pc}



; printSolution subroutine
; 		R0 = grid start address
printSolution
	STMFD sp!, {R4-R9, lr}
	MOV R4, R0				;store grid address
	MOV R5, #0				;row counter
	MOV R6, #0				;column counter
	MOV R8, #9				;store row size
forRow
	CMP R5, #9
	BEQ endPrint
	MOV R6, #0				;column counter reset for this row
forColumns
	CMP R6, #9
	BEQ incrementRowCount
	MOV R7, R5				;index = row
	MUL R7, R8, R7			;index = row * row size
	ADD R7, R7, R6			;index = row * row size + col
	ADD R7, R7, R4			;load next value
	LDRB R0, [R7]		
	LDR R9,= 0
	ADD R9, R0, #0x30
	MOV R0, R9
	BL sendchar
	ADD R6, R6, #1
	B forColumns
incrementRowCount
	ADD R5, R5, #1
	MOV R0, #0x0A
	BL sendchar
	B forRow
endPrint
	LDMFD sp!, {R4-R9, pc}

	AREA	Grids, DATA, READWRITE

gridOne
		DCB	7,9,0,0,0,0,3,0,0
    	DCB	0,0,0,0,0,6,9,0,0
    	DCB	8,0,0,0,3,0,0,7,6
    	DCB	0,0,0,0,0,5,0,0,2
    	DCB	0,0,5,4,1,8,7,0,0
    	DCB	4,0,0,7,0,0,0,0,0
    	DCB	6,1,0,0,9,0,0,0,8
    	DCB	0,0,2,3,0,0,0,0,0
    	DCB	0,0,9,0,0,0,0,5,4

gridTwo
		DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,0,0,0,0,0,0,0,0

gridThree
		DCB	0,0,0,2,6,0,7,0,1
    	DCB	6,8,0,0,7,0,0,9,0
    	DCB	1,9,0,0,0,4,5,0,0
    	DCB	8,2,0,1,0,0,0,4,0
    	DCB	0,0,4,6,0,2,9,0,0
    	DCB	0,5,0,0,0,3,0,2,8
    	DCB	0,0,9,3,0,0,0,7,4
    	DCB	0,4,0,0,5,0,0,3,6
    	DCB	7,0,3,0,1,8,0,0,0
		
gridFour
		DCB	0,2,0,0,0,0,0,0,0
    	DCB	0,0,0,6,0,0,0,0,3
    	DCB	0,7,4,0,8,0,0,0,0
    	DCB	0,0,0,0,0,3,0,0,2
    	DCB	0,8,0,0,4,0,0,1,0
    	DCB	6,0,0,5,0,0,0,0,0
    	DCB	0,0,0,0,1,0,7,8,0
    	DCB	5,0,0,0,0,9,0,0,0
    	DCB	0,0,0,0,0,0,0,4,0
		
gridFive
		DCB	0,0,0,6,0,0,4,0,0
    	DCB	7,0,0,0,0,3,6,0,0
    	DCB	0,0,0,0,9,1,0,8,0
    	DCB	0,0,0,0,0,0,0,0,0
    	DCB	0,5,0,1,8,0,0,0,3
    	DCB	0,0,0,3,0,6,0,4,5
    	DCB	0,4,0,2,0,0,0,6,0
    	DCB	9,0,3,0,0,0,0,0,0
    	DCB	0,2,0,0,0,0,1,0,0
		
gridSix
		DCB	1,0,0,4,8,9,0,0,6
    	DCB	7,3,0,0,0,0,0,4,0
    	DCB	0,0,0,0,0,1,2,9,5
    	DCB	0,0,7,1,2,0,6,0,0
    	DCB	5,0,0,7,0,3,0,0,8
    	DCB	0,0,6,0,9,5,7,0,0
    	DCB	9,1,4,6,0,0,0,0,0
    	DCB	0,2,0,0,0,0,0,3,7
    	DCB	8,0,0,5,1,2,0,0,4
	END
