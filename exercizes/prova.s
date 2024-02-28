fatt: addi sp, sp, -16 
    sd x1, 8(sp)
    sd x10,0(sp)
    addi x5, x10, -1
    bge x5, x0, L1
    addi x10, x0, 1
    addi sp, sp, 16
    jalr x0, 0(x1)
L1:
    addi x10, x10, -1
    jal x1, fatt
    addi x6, x10, 0
    ld x10, 0(sp)
    ld x1, 8(sp)
    add sp, sp, 16
    mul x10, x10, x6
    jalr x0, 0(x1)