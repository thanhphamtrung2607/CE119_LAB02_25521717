.data
s1: .asciiz "(a+b)*[c-{d/e}]"
s2: .asciiz "f(x[i]{j}))"
s3: .asciiz "{[(])}"
s4: .asciiz "((a)"
s5: .asciiz ""
s6: .asciiz "no brackets here"
s7: .asciiz "]"
s8: .asciiz "([)]"
sP: .asciiz "([{([{([{()}])}])}])"
tbl: .word s1, s2, s3, s4, s5, s6, s7, s8, sP
sep: .asciiz " , "
nl:  .asciiz "\n"

.text
main:
    la   $s0, tbl
    li   $s1, 9              # s? chu?i
    
next:
    lw   $a0, 0($s0)
    jal  check_brackets
    move $s2, $v1            # gi? $v1 vì syscall in dùng $v0
    move $a0, $v0
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, sep
    syscall
    move $a0, $s2
    li   $v0, 1
    syscall
    li   $v0, 4
    la   $a0, nl
    syscall
    addi $s0, $s0, 4
    addi $s1, $s1, -1
    bgtz $s1, next
    li   $v0, 10
    syscall

check_brackets:
    move $t9, $sp            # m?c ng?n x?p r?ng
    move $t0, $a0            # con tr? ký t?
    li   $t1, 0              # con tro ki tu
loop:
    lb   $t2, 0($t0)
    beq  $t2, $zero, eos     # g?p byte 0: h?t chu?i
    addiu $t1, $t1, 1
    addiu $t0, $t0, 1

    li   $t3, '('
    beq  $t2, $t3, push
    li   $t3, '['
    beq  $t2, $t3, push
    li   $t3, '{'
    beq  $t2, $t3, push

    li   $t3, ')'
    li   $t4, '('            # ngo?c m? t??ng ?ng
    beq  $t2, $t3, close
    li   $t3, ']'
    li   $t4, '['
    beq  $t2, $t3, close
    li   $t3, '}'
    li   $t4, '{'
    beq  $t2, $t3, close
    j    loop                # ký t? khác: b? qua

push:
    addiu $sp, $sp, -4
    sw   $t2, 0($sp)
    j    loop

close:
    beq  $sp, $t9, err2      # ?óng khi ng?n x?p r?ng
    lw   $t5, 0($sp)
    bne  $t5, $t4, err1      # khac loai
    addiu $sp, $sp, 4        # pop
    j    loop

eos:
    bne  $sp, $t9, err3      # còn ngo?c m?
    li   $v0, 0
    li   $v1, 0
    j    done
err1:
    move $v0, $t1
    li   $v1, 1
    j    done
err2:
    move $v0, $t1
    li   $v1, 2
    j    done
err3:
    addiu $v0, $t1, 1        # ?? dài + 1
    li   $v1, 3
done:
    move $sp, $t9            # khôi ph?c $sp
    
    jr   $ra