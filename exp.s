@@@ OPEN INPUT FILE, READ INTEGER FROM FILE, PRINT IT, CLOSE INPUT FILE
.equ SWI_PrChr, 0x00 @ Write an ASCII char to Stdout
.equ SWI_RdChr, 0x01 @Read an ASCII char 
.equ SWI_Exit,  0x11 @ Stop execution
.equ SWI_Open,  0x66 @open a file
.equ SWI_Close, 0x68 @close a file
.equ SWI_PrStr, 0x69 @ Write a null-ending string
.equ SWI_PrInt, 0x6b @ Write an Integer
.equ SWI_RdInt, 0x6c @ Read an Integer from a file
.equ Stdout, 1 @ Set output target to be Stdout
.global _start
.text
_start:
@ print an initial message to the screen
mov R0,#Stdout @print an initial message
ldr R1, =Message1 @ load address of Message1 label
swi SWI_PrStr @ display message to Stdout

@ == Open an input file for reading =============================
@ if problems, print message to Stdout and exit
ldr r0,=InFileName @ set Name for input file
mov r1,#0 @ mode is input
swi SWI_Open @ open file for input
bcs InFileError @ Check Carry-Bit (C): if= 1 then ERROR
@ Save the file handle in memory:
ldr r1,=InputFileHandle @ if OK, load input file handle
str r0,[r1] @ save the file handle

@ == Read integers until end of file =============================
RLoop:
ldr r0,=InputFileHandle @ load input file handle
ldr r0,[r0]
swi SWI_RdInt @ read the integer into R0   @CHANGED
@ldr r0,=OutFileName
@swi SWI_PrInt
bcs EofReached @ Check Carry-Bit (C): if= 1 then EOF reached
stmdb sp!, {r0}

@ print the integer to Stdout
mov r1,r0 @ R1 = integer to print
mov R0,#Stdout @ target is Stdout
@swi SWI_PrStr
@ldr r1, =SPACE
swi SWI_PrInt
mov R0,#Stdout @ print new line
ldr r1, =NL
swi SWI_PrStr
bal RLoop @ keep reading until end of file

@ == End of file ===============================================
EofReached:
mov R0, #Stdout @ print last message
ldr R1, =EndOfFileMsg
swi SWI_PrStr

@ == Close a file ===============================================
ldr R0, =outFileHandle @ get address of file handle
ldr R0, [R0] @ get value at address
@swi SWI_Close


Exit:
add sp, sp, #4
ldmdb sp!, {R5}
mov R0, #Stdout @ print last message
ldr r0,=OutFileName @ set Name for output file
mov r1,#1 @ mode is output

swi SWI_Open @ open file for output
@ldr R1, =OutFileHandle
@ldr R0, [R0]
mov r7, #0
PrintOut:
ldr r1, [sp, r7]@=ColonSpace
swi SWI_PrInt
ldr r1, =SPACE
swi SWI_PrStr
add r7, r7, #4
cmp r7, #24
bne PrintOut
@ldr r1, [sp, r7]
@swi SWI_PrInt
@ldr r1, R1;
@swi SWI_prStr
swi SWI_Exit @ stop executing


InFileError:
mov R0, #Stdout
ldr R1, =FileOpenInpErrMsg
swi SWI_PrStr
bal Exit @ give up, go to end


.data
.align
InputFileHandle: .skip 4  @added
InFileHandle: .skip 4
OutFileHandle: .skip 4
InFileName: .asciz "whatin.txt"
OutFileName: .asciz "whatout.txt"
FileOpenInpErrMsg: .asciz "Failed to open input file \n"
EndOfFileMsg: .asciz "End of file reached\n"
ColonSpace: .asciz ":"
NL: .asciz " \n " @ new line
SPACE: .asciz " "
Message1: .asciz "Hello World! \n"
.end