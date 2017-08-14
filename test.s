mov r1,#1
mov r2,#2
mov r3,#3
stmdb sp!,{r1-r3}
sub sp,sp,#-12
ldmdb sp!,{r4-r6}