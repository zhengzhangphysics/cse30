@pseudonoise sequence generator
@ repeats every 1023 outputs
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
BX lr