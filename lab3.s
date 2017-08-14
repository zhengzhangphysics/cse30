@@@=============================================================================
@@@ SoftWare Interrupts (SWI)
@@@
.equ SWI_PrChr, 0x00    @ Write an ASCII char to Stdout
.equ SWI_RdChr, 0x01    @ Read an ASCII char 
.equ SWI_Exit,  0x11    @ Stop execution
.equ SWI_Open,  0x66    @ open a file
.equ SWI_Close, 0x68    @ close a file
.equ SWI_PrStr, 0x69    @ Write a null-ending string
.equ SWI_PrInt, 0x6b    @ Write an Integer
.equ SWI_RdInt, 0x6c    @ Read an Integer from a file
.equ Stdout,    1       @ Set output target to be Stdout


@@@=============================================================================
@@@ Echo input file to output file
@@@   input:   whatin.txt
@@@   output:  whatout.txt
@@@
.align   8
.global  read_write_echo_ARM
.type    read_write_echo_ARM, %function

read_write_echo_ARM:
   .fnstart
   
   ldr r0, =whatin_file_in 
   mov r1,#0
   swi SWI_Open   
   ldr r1, =InputFileHandle
   str r0, [r1]
   mov r2 , #0
RLoop:
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_RdInt 
   bcs EofReached
   add r2,r2,#1
   stmdb sp!, {r0}
   bal RLoop



EofReached:
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_Close
	ldr r0,=whatout_file_out
	mov r1,#1
	swi SWI_Open 
	ldr r1, =OutFileHandle
   str r0, [r1]
	mov r3, #4
	add r2, r2, #-1
	mul r7, r2, r3
printOut:
	ldr r1,[sp,r7]
	swi SWI_PrInt
	ldr r1, =SPACE
    swi SWI_PrStr
	add r7,r7,#-4
	add r2,r2,#-1
	cmp r2,#0
	bgt printOut

ExitPrint:
	ldr r1,[sp,r7]
	swi SWI_PrInt 
	ldr r0, =OutFileHandle
   ldr r0, [r0]
   swi SWI_Close 
    bx lr 
   .fnend

@@@=============================================================================
@@@ Read two 4x4 matrix
@@@   input:   matin.txt
@@@      
@@@   If the input file have the following 3x3 matrix:
@@@
@@@      1 2 3 4 5 6 7 8 9
@@@
@@@   The stack will have the following pattern:
@@@      
@@@      +-+
@@@      |7| <-- SP
@@@      +-+      
@@@      |8|   
@@@      +-+
@@@      |9|
@@@      +-+
@@@      |4|
@@@      +-+
@@@      |5|
@@@      +-+
@@@      |6|
@@@      +-+
@@@      |1|
@@@      +-+
@@@      |2|
@@@      +-+
@@@      |3|
@@@      +-+
@@@

.align   8
.global  matrix_read_ARM
.type    matrix_read_ARM, %function
matrix_read_ARM:
   .fnstart

   ldr r0, =matin_file_in
   mov r1, #0   
   swi SWI_Open
   ldr r1, =InputFileHandle
   str r0, [r1]
   mov r2 , #4
   mov r4, #1
   add sp, sp, #-4
RowLoop:
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_RdInt 
   bcs End
   add r2,r2,#-1
   mov r3, #-4
   mul r3, r2, r3
   str r0, [sp,r3]
   cmp r2, #0
   bne RowLoop
ChangeRow:
	mov r2, #4
	add r4, r4, #1
	cmp r4, #8
	bgt	End
	add sp, sp, #-16
	bal RowLoop

End:
   add sp, sp, #-12 
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_Close
   bx lr 

   .fnend

@@@=============================================================================
@@@ 4x4 matrix multiplication
@@@   input:   matin.txt
@@@   output:  matout.txt
@@@      
@@@   For example:
@@@
@@@ a =             b =
@@@   8   1   6       8   1   6
@@@   3   5   7       3   5   7
@@@   4   9   2       4   9   2
@@@
@@@ a * b = 
@@@       91    67    67
@@@       67    91    67
@@@       67    67    91
@@@
.align   8
.global  matrix_mult_ARM
.type    matrix_mult_ARM, %function

matrix_mult_ARM:
    .fnstart   

   ldr r0, =matin_file_in
   mov r1,#0
   swi SWI_Open
  ldr r1, =InputFileHandle
  str r0, [r1]
   mov r2 , #4
   mov r4, #1
   add sp, sp, #-4
RowLoopmult:
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_RdInt 
   bcs EndMul
   add r2,r2,#-1
   mov r3, #-4
   mul r3, r2, r3
   str r0, [sp,r3]
   cmp r2, #0
   bne RowLoopmult
ChangeRowmult:
	mov r2, #4
	add r4, r4, #1
	add sp, sp, #-16
	cmp r4, #8
	bgt	EndMul
	bal RowLoopmult
EndMul:	
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_Close
   
	mov r7, #1
	mov r10, #0
	ldr r0,=matout_file_out
	mov r1,#1
	swi SWI_Open 
	ldr r1, =OutFileHandle
	str r0,[r1]

Cal:
	mov r2, #32
	mov r9, #4
	mul r2, r9,r2
	ldr r6, [sp,r2]
	add r2, r2, #-4
	ldr r5, [sp,r2]
	add r2, r2, #-4
	ldr r4, [sp,r2]
	add r2, r2, #-4
	ldr r3, [sp,r2]
	mul r11,r10,r9
	add r11, r11, r7
	mul r2,r9,r11	
	ldr r8, [sp,r2]
	mul r6, r8, r6
	add r11, r11, #4
	mul r2,r9,r11		
	ldr r8, [sp,r2]
	mul r5, r8, r5
	add r11, r11, #4
	mul r2,r9,r11
	ldr r8, [sp,r2]
	mul r4, r8, r4
	add r11, r11, #4
	mul r2,r9,r11
	ldr r8, [sp,r2]
	mul r3, r8, r3
	add r4,r5,r4
	add r4,r4,r6
	add r3,r4,r3
	mov r9, #4
	sub r11, r9,r7
	mov r9, #-4
	mul r11, r9,r11
	str r3,[sp,r11]



	mov r1,r3
	swi SWI_PrInt
	ldr r1, =SPACE
    swi SWI_PrStr
	add r7,r7,#1

	cmp r7, #5
    bne Cal 

cal_2:
	mov r7,#1
	add sp, sp, #-16
	add r10, r10,#1

	ldr r1, =NL
    swi SWI_PrStr

	cmp r10, #4
	bge Exit_mul 
	bal Cal

Exit_mul:
	add sp,sp,#4
   ldr r0, =OutFileHandle
   ldr r0, [r0]
   swi SWI_Close 
    bx lr

    .fnend

@@@============================================================================
@@@ compute the input count, median, sum, mean
@@@   input:   seq_in.txt
@@@
@@@  The solution will need to be push onto the stack as such:
@@@
@@@         +--------+        
@@@         | count  | <-- SP
@@@         +--------+
@@@         | median |
@@@         +--------+
@@@         | total  |
@@@         +--------+
@@@         | mean   |
@@@         +--------+
@@@
.align   8
.global  seq_ARM
.type    seq_ARM, %function

seq_ARM:

  .fnstart
  
   add sp,sp,#-4
   ldr r0, =seq_in 
   mov r1,#0
   swi SWI_Open
   ldr r1, =InputFileHandle
   str r0, [r1]
   mov r2, #0  @ count
   mov r3, #0	@total
   
RLoop2:
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_RdInt 
   bcs end2
   add r3,r3,r0
   cmp r2,#0
   beq begin
   mov r4, #4
   mul r4, r2,r4
   mov r6, #0

RLoop3:
	cmp r4, #0
	beq begin
	ldr r5, [sp, r4]
	cmp r0, r5
	blt RLoop4
	add r4,r4,#-4
	bal RLoop3
	

RLoop4:
@save and shift
	cmp r6,r4
	bge endshift
	add r6,r6,#4
	ldr r5,[sp,r6]
	add r6,r6,#-4
    str r5,[sp,r6]
    add r6,r6,#4
    bal RLoop4

endshift:
    str r0,[sp,r4]
	add sp,sp,#-4
	add r2,r2,#1
	bal RLoop2
	

end2:
	mov r4,r3
	mov r5,#0
	cmp r3,#0
	beq exit2
	mov r8,r2
	cmp r4,#0
	bge Division
	mov r0,#0
	sub r8,r0,r8
	
Division_2:
	sub r4,r4,r8
	add r5,r5,#1
	cmp r4,r8
	bgt flip
	bal Division_2
	
flip: 
	mov r0,#0
	sub r5,r0,r5
	bal checkeven
 	
Division:
	sub r4,r4,r8
	add r5,r5,#1
	cmp r4,r8
	blt checkeven
	bal Division
	
begin:
	str r0,[sp]
	add sp,sp,#-4
	add r2,r2,#1
	bal RLoop2

checkeven:

	and r4, r2,#1
	cmp r4,#0
	bne odd
	mov r4,r2
	mov r4,r4,LSR #1
	mov r0,#4
	mul r4,r0,r4
	ldr r6,[sp,r4]
	add r4,r4,#4
	ldr r7,[sp,r4]
	add r4,r6,r7
	mov r4,r4,LSR #1
	bal exit2



odd:
	mov r4,r2
	mov r4,r4,LSR #1
	add r4,r4,#1
	mov r0,#4
	mul r4,r0,r4
	ldr r4,[sp,r4]
	
exit2:
	add sp,sp,#4
	mov r6,r5
	mov r5,r3	
	stmdb sp!, {r2,r4,r5,r6}
    ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_Close 
    bx lr
    .fnend


@@@============================================================================
.align 8
.text
.global encrypt_ARM
.type   encrypt_ARM, %function

encrypt_ARM:
 .fnstart
 
   bal rand_gen
LoopStart:
   ldr r0, =message_file_in 
   mov r1,#0
   swi SWI_Open   
   ldr r1, =InputFileHandle
   str r0, [r1]
   mov r2 , #0
RLoop5:
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_RdInt 
   bcs Read_Done
   add r2,r2,#1
   stmdb sp!, {r0}
   bal RLoop5


Read_Done:
	ldr R0, =InputFileHandle @ get address of file handle
	ldr R0, [R0] @ get value at address
	swi SWI_Close

   mov r7,#4
   add r3,r2,#-1
   cmp r3,#-1
   beq Exit_scram
   mul r9, r3,r7
   ldr r4,[sp,r9]
   eor r4,r4,#2  @ every first digit
   str r4,[sp,r9]
   add r8, r2,#1024
   add r6,r2,#-1
Sloop:
   mov r7,#4
   add r3,r3,#-1
   cmp r3,#-1
   beq Exit_scram
   mul r9, r3,r7
   ldr r4,[sp,r9] @second digit in sequence and first in rand_Gen
   add r8,r8,#-1
   cmp r8,r6
   beq reset
   mul r7,r8,r7
   ldr r5,[sp,r7]
   eor r4,r4,r5
   str r4,[sp,r9]
   bal Sloop
   
   
reset:
eor r4,r4,#8
str r4,[sp,r9]
add r8, r2,#1024
add r8,r8,#-2
bal Sloop

rand_gen:
MOV r0,#2  @start
MOV r1,r0  @a
MOV r7,#1024 @loop_ctr
LOOP:
MOV r6,r1,LSR #9
MOV r5,r1,LSR #6
EOR r5,r5,r6
AND r5,r5,#1
MOV r1,r1,LSL#1
ADD r1,r1,r5
MOV r2, #255
MOV r3, r2, LSL#2
ADD r3, r3,  #3
AND r1,r1, r3
STMDB sp!,{r1}
SUBS r7,r7,#1
BEQ  end
BAL LOOP
end:
BAL LoopStart

Exit_scram:
	ldr r0,=message_file_scram
	mov r1,#1
	swi SWI_Open 
	ldr  r1, =OutFileHandle
	str  r0,[r1]
	mov r3, #4
	add r2, r2, #-1
	mul r7, r2, r3
printOut_scram:
	ldr r1,[sp,r7]
	swi SWI_PrInt
	ldr r1, =SPACE
    swi SWI_PrStr
	add r7,r7,#-4
	add r2,r2,#-1
	cmp r2,#0
	bgt printOut_scram

ExitPrint_scram:
	ldr r1,[sp]
	swi SWI_PrInt 
	ldr R0, =OutFileHandle @ get address of file handle
	ldr R0, [R0] @ get value at address
	swi SWI_Close

    bx lr 
   .fnend

 
 @@@============================================================================
.align 8
.text
.global decrypt_ARM
.type   decrypt_ARM, %function

decrypt_ARM:
 .fnstart
   bal rand_gen_2 
LoopStart_2:
   ldr r0, =message_file_scram
   mov r1,#0
   swi SWI_Open   
   ldr r1, =InputFileHandle
   str r0, [r1]
   mov r2 , #0
RLoop5_2:
   ldr r0, =InputFileHandle
   ldr r0, [r0]
   swi SWI_RdInt 
   bcs Read_Done_2
   @bcs Exit_scram_2
   add r2,r2,#1
   stmdb sp!, {r0}
   bal RLoop5_2




Read_Done_2:
	ldr R0, =InputFileHandle @ get address of file handle
	ldr R0, [R0] @ get value at address
	swi SWI_Close

   mov r7,#4
   add r3,r2,#-1
   cmp r3,#-1
   beq Exit_scram_2
   mul r9, r3,r7
   ldr r4,[sp,r9]
   eor r4,r4,#2  @ every first digit
   
   str r4,[sp,r9]
   add r8, r2,#1024
   add r6,r2,#-1
   
Sloop_2:
   mov r7,#4
   add r3,r3,#-1
   cmp r3,#-1
   beq Exit_scram_2
   mul r9, r3,r7
   ldr r4,[sp,r9] @second digit in sequence and first in rand_Gen
   add r8,r8,#-1
   cmp r8,r6
   beq reset_2
   mul r7,r8,r7
   ldr r5,[sp,r7]
   eor r4,r4,r5
   str r4,[sp,r9]
   bal Sloop_2
   
   
reset_2:
eor r4,r4,#8
str r4,[sp,r9]
add r8, r2,#1024
add r8,r8,#-2
bal Sloop_2

rand_gen_2:
MOV r0,#2  @start
MOV r1,r0  @a
MOV r7,#1024 @loop_ctr
LOOP_2:
MOV r6,r1,LSR #9
MOV r5,r1,LSR #6
EOR r5,r5,r6
AND r5,r5,#1
MOV r1,r1,LSL#1
ADD r1,r1,r5
MOV r2, #255
MOV r3, r2, LSL#2
ADD r3, r3,  #3
AND r1,r1, r3
STMDB sp!,{r1}
SUBS r7,r7,#1
BEQ  end_2
BAL LOOP_2
end_2:
BAL LoopStart_2

Exit_scram_2:
	ldr r0,=message_file_out
	mov r1,#1
	swi SWI_Open 
	ldr  r1, =OutFileHandle	
	str  r0,[r1]
	mov r3, #4
	add r2, r2, #-1
	mul r7, r2, r3
	cmp r7,#0
	blt ExitPrint_scram_2
printOut_scram_2:

	ldr r1,[sp,r7]
	swi SWI_PrInt
	ldr r1, =SPACE

    swi SWI_PrStr
	add r7,r7,#-4
	add r2,r2,#-1
	cmp r2,#0
	bgt printOut_scram_2

ExitPrint_scram_2:

	ldr r1,[sp]
	swi SWI_PrInt 
	ldr R0, =OutFileHandle @ get address of file handle
	ldr R0, [R0] @ get value at address
	swi SWI_Close
    bx lr 
   .fnend




@@@============================================================================
.align   8
.global  _start
.type    _start, %function

_start:
   .fnstart  
   

 
 bl matrix_read_ARM 



  bl seq_ARM
  bl matrix_mult_ARM  
bl encrypt_ARM 
  bl decrypt_ARM
  
 
bl read_write_echo_ARM
  swi  SWI_Exit 
   .fnend


.data
.align
InputFileHandle: .skip 4  @added
OutFileHandle: .skip 4
whatin_file_in:      .asciz "whatin.txt"
whatout_file_out:    .asciz "whatout.txt"
matin_file_in:        .asciz "matin.txt"
matout_file_out:     .asciz "matout.txt"
seq_in:     .asciz "seq_in.txt"
message_file_in: .asciz "message_in.txt"
message_file_scram: .asciz "message_scram.txt"
message_file_out: .asciz "message_out.txt"
SPACE: 				.asciz " "
NL: .asciz " \n " @ new line

.end